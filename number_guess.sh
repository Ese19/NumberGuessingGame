#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

echo "Enter your username:"

read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_INFO=$($PSQL "SELECT COUNT(*), MIN(num_guesses) FROM users INNER JOIN guesses USING(user_id) WHERE user_id = $USER_ID")
  echo $USER_INFO | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
COUNT_GUESSES=0


GUESS_NUMBER () {  
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    (( COUNT_GUESSES += 1 ))
    echo "That is not an integer, guess again:"
    GUESS_NUMBER
  else

    if [[ $GUESS < $RANDOM_NUMBER ]]
    then
      (( COUNT_GUESSES += 1 ))
      echo "It's higher than that, guess again:"
      GUESS_NUMBER
    elif [[ $GUESS > $RANDOM_NUMBER ]]
    then
      (( COUNT_GUESSES += 1 ))
      echo "It's lower than that, guess again:"
      GUESS_NUMBER
    else
      (( COUNT_GUESSES += 1 ))
      echo "You guessed it in $COUNT_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
      GUESS_INSERT=$($PSQL "INSERT INTO guesses(user_id, num_guesses) VALUES($USER_ID, $COUNT_GUESSES)")
    fi

  fi
}

GUESS_NUMBER

