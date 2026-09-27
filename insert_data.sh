#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
insert_teams() {
  $PSQL "INSERT INTO teams (name) VALUES ('$1') ON CONFLICT (name) DO NOTHING;"
}
insert_games() {
  $PSQL "INSERT INTO games (year,round,winner,opponent,winner_goals,opponent_goals) VALUES ($1, '$2', '$3', '$4', $5, $6)"
}

read_csv() {
  cat games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals; 
  do
    if [[ $year != "year" ]]
    then
      insert_teams "$winner"
      insert_teams "$opponent"

      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

      echo "Inserting: $year $round | $winner ($WINNER_ID) vs $opponent ($OPPONENT_ID)"
      $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);"
    fi
  done
}

read_csv
