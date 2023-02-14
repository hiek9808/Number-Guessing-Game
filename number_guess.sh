#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
MIN=1
MAX=1000

RANDOM_NUMBER=$(( $RANDOM % $MAX + $MIN))

echo "Enter your username:"
read USERNAME
USERNAME_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME' ")

if [[ -z $USERNAME_ID_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USERS_RESULT=$($PSQL "INSERT INTO users(username) values ('$USERNAME')")
else
  # users exist
  USER_INFO_RESULT=$($PSQL "SELECT username, COUNT(*), MIN(guesses) FROM games INNER JOIN users USING(user_id) 
  WHERE user_id = '$USERNAME_ID_RESULT' GROUP BY username ")
  echo "$USER_INFO_RESULT" | sed 's/|/ /g' | while read USERNAME GAMES BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST_GAME guesses."
  done
fi
COUNT_GUESSES=1
echo -e "\nGuess the secret number between 1 and 1000:"
GUESS_NUMBER() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  read NUMBER

  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    GUESS_NUMBER "That is not an integer, guess again:"
  fi

  
  while [ ! $NUMBER -eq $RANDOM_NUMBER ]
  do
    if [[ $NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    else
      echo -e "\nIt's lower than that, guess again:"
    fi
    read NUMBER
    COUNT_GUESSES=$(( $COUNT_GUESSES + 1))
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]
    then
      GUESS_NUMBER "That is not an integer, guess again:"
    fi
  done

  
}

GUESS_NUMBER
USERNAME_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME' ")
GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES ($USERNAME_ID_RESULT, $COUNT_GUESSES)")
echo -e "\nYou guessed it in $COUNT_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
