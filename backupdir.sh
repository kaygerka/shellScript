#!/bin/bash
echo
# CHECK: num of arguments ---------------------
if [ $# -ne 3 ]
then
  echo "$0 needs three arguments"
  echo
  exit 1
fi

# set arguments
DIR=$1
BACKUPDIR=$2
MAXBACKUPS=$3
NEXTSEQ=0;


# CHECK: DIR exists---------------------
if [ ! -d "$DIR" ]
then
  echo "Directory $DIR does not exist"
  echo
  exit 1
fi


# CHECK: BACKUPDIR exists -----------
if [ ! -d "$BACKUPDIR" ]
then

  # Does NOT exist BACKUPDIR, create one
  if ! mkdir -p "$BACKUPDIR"
  then
    echo "Failed to Backup"
    echo
    exit 1
  fi
fi

# CHECK: MAXBACKUPS is a number ---------------------
if ! echo "$MAXBACKUPS" | grep -q -e '^[1-9][0-9]*$'
then
  echo "Max Backups should be a positive integer"
  echo
  exit 1
fi


# CHECK: incr NEXTSEQ --------------------------------
  # FINDS THE DIR THAT DOESNT EXIST
while [ -d "$BACKUPDIR/$DIR.$NEXTSEQ" ]
do
  # if backup dir w/NEXT SEQUENCE DOESN'T EXIST
  NEXTSEQ=$((NEXTSEQ + 1)) 
done







# CHECK: if dir has been modified ---------------

# CHECK: timestampE //
# -l = longlist which includes timestampes, file permission, etc
# -a = entries that start with a dot .
# -R = recursive
DIRTIME=$(ls -laR "$DIR")

LASTTIME=$(ls -d "$BACKUPDIR"/$DIR.* 2>/dev/null | tail -n 1)


# CHECK: different timestamps---------------------

#CHECKS: if there is a backup
if [ -n "$LASTTIME" ]
then
  BACKUPTIME=$(ls -laR "$LASTTIME")
  # CHECK: if the contents changed
  if diff -qr "$DIR" "$LASTTIME" > /dev/null 2>&1
  then
    # NO CHANGE
    echo "No backup necessary"
    echo
    exit 0
  fi
fi



# CREATE a NEW ORIGINAL DIR (mydir.#)  // -R means recursive -------------
NEWOGDIR="$BACKUPDIR/$DIR.$NEXTSEQ"
mkdir -p "$NEWOGDIR" || { echo "Error: Failed to create backup directory"; exit 1; }
cp -R "$DIR"/* "$NEWOGDIR" || { echo "Error: Failed to copy files to backup directory"; exit 1; }
echo

#CHECK: if maxed out dir
# lists the directories in path, count
NUMBACKUPS=$(ls -d "$BACKUPDIR"/$DIR.* | wc -l) || { echo "Error: Failed to count backups"; exit 1; }
while [ "$NUMBACKUPS" -gt "$MAXBACKUPS" ]
do

  # NUM BACKUPS > MAX
  # lists the directories in path, sort numerically, and selects the first
  OLDESTTIME=$(ls -d "$BACKUPDIR"/$DIR.* | sort -n | head -n 1) || { echo "Error: Failed to find oldest backup"; exit 1; }
  rm -r -f "$OLDESTTIME" || { echo "Error: Failed to remove oldest backup"; exit 1; }
  NUMBACKUPS=$((NUMBACKUPS-1))
done
