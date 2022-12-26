#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# delete all in games and teams
echo $($PSQL "TRUNCATE games, teams")
# read games, and while coma read data as variables 
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOAL OPPGOAL
do
  # skip the first line
  if [[ $YEAR != "year" ]]
  then
  WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if there is no winner country inside teams, insert
    WIN_IN=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    if [[ -z $WIN_IN ]]
    then
      INSERT_WIN=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WIN == "INSERT 0 1" ]]
      then
        echo inserted WIN: $WINNER
      fi
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # if there is no opponent country inside teams, insert
    OPP_IN=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPP_IN ]]
    then
      INSERT_OPP=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPP == "INSERT 0 1" ]]
      then
        echo inserted OPP: $OPPONENT
      fi
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  
  # insert row in games
  INSERT_ROW=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WINGOAL, $OPPGOAL)")
  if [[ $INSERT_ROW == "INSERT 0 1" ]]
  then
    echo inserted row: $ROUND "|" win: $WINNER, opp: $OPPONENT 
  fi

  fi
done

