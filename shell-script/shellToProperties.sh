if [ "$#" -lt "1" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1- SOURCE FILE"
    exit 1
fi

SOURCE_FILE=$1

# This is to get filename without extension: FILENAME=$(basename "${SOURCE_FILE%.*}")
# Here we want to keep extension
FILENAME=$(basename "${SOURCE_FILE}")
TARGET_DIR=$(dirname "${SOURCE_FILE}")
TARGET_FILE="$TARGET_DIR/$FILENAME.properties"

# remove empty lines
awk 'NF' $SOURCE_FILE > $TARGET_FILE.tmp

# Transtorm file into properties format
awk '{printf("LINE%04d=%s\n", NR, $0)}' $TARGET_FILE.tmp > $TARGET_FILE
rm -Rf $TARGET_FILE.tmp
