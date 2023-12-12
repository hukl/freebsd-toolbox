#!/bin/sh

# This was tested from ZSH - not sure if the glob is auto expanded in other shells

unset TARBALL

usage() {
  echo "USAGE: quicketc -h | -t <path/to/tarfile> directory_or_glob_pattern"
  exit 1
}

while getopts j:t:h opt; do
    case $opt in
        t)      TARBALL=$OPTARG
                ;;
        h)      echo $USAGE
                exit 0
                ;;
        '?')    echo "$0: invalid option -$OPTARG" >&2
                usage
                ;;
    esac done
    shift $((OPTIND - 1))

# Check if TARBALL arg was provided
[ -z "$TARBALL" ] && usage

# Go through list of Jail from expanded glob pattern and build internal list
NUMBER_OF_JAILS=0
NUMBER_OF_JAIL_ARGS=$#
JAILS=""

while [ $NUMBER_OF_JAILS -lt $NUMBER_OF_JAIL_ARGS ]
do
    JAILS="$JAILS$1 "
    NUMBER_OF_JAILS=$(($NUMBER_OF_JAILS+1))
    shift
done

# Build Tarball if specified file does not yet exist
if [ -f $TARBALL ]
then
    echo "Found existing Tarball at $TARBALL"
else
    echo "Generate Source Tarball $TARBALL"
    etcupdate build $TARBALL
fi

# Loop through each subdirectory in JAIL_DIR
for jail_sub_dir in $JAILS; do
    # Check if the directory exists
    if [ -d "$jail_sub_dir" ]; then
        # Run etcupdate commands with the current subdirectory
        echo "Updating: $jail_sub_dir"
        etcupdate -t $TARBALL -D "$jail_sub_dir"
        etcupdate resolve -D "$jail_sub_dir"
    fi
done
