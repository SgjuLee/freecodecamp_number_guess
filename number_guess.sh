#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Required Variables
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
BEST_GUESS=0

echo Enter your username:
read USER_NAME_INPUT

# Check user_name is in database
USER_NAME=$($PSQL "SELECT name FROM users WHERE name = '$USER_NAME_INPUT'")
if [[ -z $USER_NAME ]] 
then
  echo "Welcome, $USER_NAME_INPUT! It looks like this is your first time here."
  ADD_USER_INTO_DATABASE=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME_INPUT')")
  GAME_PLAYED=0
  BEST_GAME=0
else
  GAME_PLAYED=$($PSQL "SELECT number_of_game_played FROM users WHERE name = '$USER_NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USER_NAME'")
  echo "Welcome back, $USER_NAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Guessing start
echo $RANDOM_NUMBER
# echo $USER_NAME
echo Guess the secret number between 1 and 1000:
while true
do
  read GUESSING_NUMBER
  # Check if the user input is valid
  if [[ $GUESSING_NUMBER =~ ^[0-9]+$ ]]
  then
    # If user guesses right
    if [[ $GUESSING_NUMBER -eq $RANDOM_NUMBER ]]
    then
      (( BEST_GUESS ++ ))
      echo You guessed it in $BEST_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!
      # update game_played record
      (( GAME_PLAYED++ ))
      UPDATE_USER_RECORD1=$($PSQL "UPDATE users SET number_of_game_played = $GAME_PLAYED where name = '$USER_NAME_INPUT'")
      
      # update best record
      if [[ $BEST_GAME -eq 0 || $BEST_GUESS -lt $BEST_GAME ]]
      then
      UPDATE_USER_RECORD2=$($PSQL "UPDATE users SET best_game = $BEST_GUESS where name = '$USER_NAME_INPUT'")
      fi
      break
    # If user guess smaller than the value  
    elif [[ $GUESSING_NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      (( BEST_GUESS ++ ))

    # If user guess bigger than the value
    else
      echo "It's lower than that, guess again:"
      (( BEST_GUESS ++ ))
    fi

  # If the user input is not valid
  else
    echo That is not an integer, guess again:
    (( BEST_GUESS ++ ))
  fi
done

