#! /usr/bin/awk

# Script to transform a CSV formatted file (with header line) into JSON format
# To use it: awk -v nbKeys=<nb of key columns> -f csv2json.awk <your csv file>
# <nb of key columns> is optional with default value of 1, if not provided

BEGIN{
  # Put here your column separator , ; \t (for tab)
  FS="\t"
  OFS=""

  # Initiate error log file
  errorFile = "./error-csv2json.log"
  print "" > errorFile

  # Get nb of key columns
  delete key
  nbKeyColumns = 1
  if (nbKeys != "") nbKeyColumns = nbKeys
  print "NB KEYS: ", nbKeyColumns >> errorFile

  getline #BEGIN runs before anything else, so grab the first line with the header right away
  nbColumns = NF
  for(i=1;i<NF;i++) header[i] = ($i)
  # manage last column, removing end of line chars
  sub("\r","",$i)
  header[i] = ($i)
  print "{"
}
{
  if (NF != nbColumns) {
    # Skip current record as number of columns is not correct
    print "ERROR: wrong column number, skip line ", NR >> errorFile
    next
  }

  # Manage key columns
  for(i=1;i<=nbKeyColumns;i++) {
    if (key[i] == "") {
      printf "\n\"%s\": {", ($i)
      key[i] = ($i)
    } else {
      # If new key, end old node and create a new node
      if (key[i] != $i) {
        for(c=0;c<nbKeyColumns-i;c++) printf "}"
        printf ",\n\"%s\": {", ($i)
        # Reinitialize key array if we are at first column
        if (i==1) delete key
        key[i] = ($i)
      } else {
        # We are last column with same key, this is doublon
        if (i == nbKeyColumns) {
          print "ERROR: duplicate Key, skip line ", NR >> errorFile
          next
        }
      }
    }
  }

  # Manage value columns
  for(i=1;i<NF;i++) {
    # remove double quotes
    gsub("\"","",$i)
    # escape backslash by double backslash
    gsub("\\","\\\\\\",$i)
    printf "\"%s\":\"%s\", ", header[i], ($i)
  }

  # Manage last column
  sub("\r","",$i)
  printf "\"%s\":\"%s\" }", header[i], ($i)
}
END{
  for(c=0;c<nbKeyColumns;c++) printf "}"
}
