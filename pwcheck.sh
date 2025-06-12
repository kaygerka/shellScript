#!/bin/bash
FUNCTION: Actually checks the code ======================================================================
passwordChecker() {

  # gets arg
  arg=$1
  # get length of arg ${arg} give $1 
  LENGTH=${#arg}
  POINTS=0
  SPECIALCHAR=0
  NUM=0
  ALPHA=0


  # ERROR: PASSWORD LENGTH -----------------------------
  if [ $LENGTH -lt 6 ] || [ $LENGTH -gt 32 ]
  then
    printf "%-36s %-40s\n" "${arg:0:36}" "Error: Password length invalid."
    echo
    return
  else

    # password is correct length and adds the base number of points per char
    POINTS=$LENGTH

    # add points for each alpha char
    ALPHA=$(echo "$arg" | grep -o -E '[A-Za-z]' | wc -l)
    POINTS=$((POINTS+ALPHA))
  fi


  # ERROR: NO SPECIAL CHARACTER --------------------------
  if ! echo "$arg" | grep -qE '[#$+%@^*-/]';
  then
    printf "%-36s %-40s\n" "${arg:0:36}" "Error: Password should include at least one of \"#$+%@^*-/\""
    echo
    return

  # there are special char
  else
    SPECIALCHAR=$(echo "$arg" | grep -o -E '[#$%@^*-/]' | wc -l);
    POINTS=$((POINTS + 2 * SPECIALCHAR))
  fi




  # ERROR: NO NUMBER ------------------------------------
  if ! echo "$arg" | grep -qE '[ 0-9 ]'
  then
    printf "%-36s %-40s\n" "${arg:0:36}" "Error: Password should include at least one number \"0-9\""
    echo
    return

  # there are numbers
  else
    NUM=$(echo "$arg" | grep -o -E '[ 0-9 ]' | wc -l);
    POINTS=$((POINTS + 2 * NUM))
  fi



  # ERROR: NO CAPITAL OR NO LOWERCASE ----------------------
  if ! echo "$arg" | grep -qE '[A-Z]' || ! echo "$arg" | grep -qE '[a-z]'
  then
    #echo "$arg \t\t\t Error: Passwords should have at least one Uppercase and lowercase alphabetic character"
    printf "%-36s %-40s\n" "${arg:0:36}" "Error: Passwords should have at least one Uppercase and lowercase alphabetic character"
    echo
    return
  fi


  # REPEATED ALPHANUMERICS ------------------------------
  if echo "$arg" | grep -qE '([A-Za-z0-9])\1+'
    then
    POINTS=$((POINTS-10))
  fi



  # CONSECUTIVE LOWERCASE -------------------------------
  if echo "$arg" | grep -qE '[a-z][a-z][a-z]'
  then
    POINTS=$((POINTS-3))
  fi



  # CONSECUTIVE UPPERCASE --------------------------------
  if echo "$arg" | grep -qE '[A-Z][A-Z][A-Z]'
  then
    POINTS=$((POINTS-3))
  fi
  


  # CONSECUTIVE NUMBERS --------------------------------
  if echo "$arg" | grep -qE '[0-9][0-9][0-9]'
  then
    POINTS=$((POINTS-3))
  fi

  # Print password and score
  #echo -e "${arg:0:30}\t\t\t\t\t$POINTS"
  printf "%-36s %-40s\n" "${arg:0:36}" "$POINTS"
  echo
}
#=============================================================================================







# Before Checking code =======================================================================




# Printing out Format 0 -- LOOKED THIS PART UP --------------------
printf "%-36s %-40s\n" "Password" "Score/Error"
printf "%-36s %-40s\n" "---------------------" "------------"



# checks if there is not an argument -------------------------------
# $# = number of arg/parameters
if [ $# -lt 1 ]
then
  # ERROR: NO ARGUMENTS
  echo "./pwcheck.sh [-f passwordFile] [password1 password2 password3…]"
  echo
fi




# check if we are reading from a file -----------------------------
# $2 holds the file name, and checks if it is nonempty
if [ "$1" = "-f" ] && [ -n "$2" ]
then

  # read each line of the file (IFS deals with remaining white space)
  # sets each line as arg (aka a password) (-r prevents backslashes as being an escape char)
  while IFS= read -r arg
  do
    passwordChecker "$arg"
  # puts the file (and its content) into the while loop
  done < "$2"
  # shift arguments right 2 so now it can read if there are any arguments
  shift 2
fi





# if there are arguments ---------------------------
# $@ sets all arguments as seperate words
# $* all args as a single string that split on spaces 
for arg in $@
do
  passwordChecker "$arg"
done
