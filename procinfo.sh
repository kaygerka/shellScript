#!/bin/bash
# procinfo [-t secs] pattern
#
# prints PID, CMD, USER, Memory Usage, CPU time, and number of threads 
# of processes with a command # that matches "pattern"
#
# If the [-t secs] option is passed, then it will loop and print the information
# every "secs" secods.
#
# If no pattern is given, it prints an error that a pattern is missing.
#


echo
# CHECK: 0 args -----------------------
if [ $# -eq 0 ]
then
  echo "Error: pattern missing"
  echo
  exit 1
fi

# CHECK: CORRECT args ------------------
if [ "$1" = "-t" ]
then
  # more than -t
  if [ $# -lt 3 ]
  then
    echo "Error: Not enough arguments"
    echo
    exit 1
  fi
  
  SECS=$2
  PATTERN=$3

# NO -t in args 
else
  if [ $# -ne 1 ]
  then 
    echo "Invalid number of arguments"
    echo
    exit 1
  fi
  PATTERN=$1
fi


# HELPER FUNCTION ------------------------------------------
process() {

  echo
  printf "%-8s %-30s %-10s %-15s %-10s %-10s\n" "PID" "CMD" "USER" "MEM" "CPU" "THREADS"

  # PROC: has a long list of PID as directories, go thru numbers
  for PID in /proc/[0-9]*
  do
    # PID: retrieved
    PID=${PID##*/}

    # CHECK: if comm and status files are readable
    if [ -r "/proc/$PID/comm" ] && [ -r "/proc/$PID/status" ]
    then

      # CHECK: if CMD matches PATTERN
      CMD=$(cat "/proc/$PID/comm")
      if [[ "$CMD" == "$PATTERN" ]]
      then


        # UID: get user id from status file
        USERID=$(awk '/^Uid:/{print $2}' "/proc/$PID/status")

        # look up the user id in password (getent is the retrieve command
        # cuts off before the :
        USERNAME=$(getent passwd $USERID | cut -d: -f1)



        # MEM: get memory from status file and calc to megabytes
        KB=$(awk '/VmRSS:/{print $2}' "/proc/$PID/status")

        # convert to megabytes
        MB=$(( (KB + 512) / 1024 ))



        # CPU: get times in clock ticks per second in stat
        CPUT=$(awk '{print $14, $15, $16, $17}' "/proc/$PID/stat")
        read utime stime cutime cstime <<< $CPUT
        TOTALCPUT=$((utime + stime + cutime + cstime))

        # retrieve teh clock ticks per second
        TICKPSEC=$(getconf CLK_TCK)

        # convert to secs (use decimals for near 0 seconds time)
        CPUTIME=$(echo "scale=2; $TOTALCPUT / $TICKPSEC" | bc)



        #THREAD: retrieved
        THREADS=$(awk '/^Threads:/{print $2}' "/proc/$PID/status")

        printf "%-8s %-30s %-10s %-15s %-10s %-10s\n" "$PID" "($CMD)" "$USERNAME" "${MB} MB" "${CPUTIME} secs" "${THREADS} Thr"
      fi
    fi
  done
}

# MAIN -------------------------------------
# SET UP LOOP AS LONG AS SECONDS
# -n checks if it is not empty
if [ -n "$SECS" ]
then
  # -t process 
  while true
  do
    process

    sleep "$SECS"
  done
else
  # no -t
  # gather code
  process
fi

