#! /usr/bin/awk

# Script to transform a CSV formatted file (with header line) into JSON format
# To use it: awk -v nbKeys=<nb of key columns> -f tsv2json.awk <your csv file>
# <nb of key columns> is optional with default value of 1, if not provided

BEGIN{
  # Put here your column separator , ; \t (for tab)
  FS="\t"
  OFS=""

  # Initiate error log file
  errorFile = "./error-csv2json.log"
  print "" > errorFile

  # Get nb of key columns
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
  #print "\n****** DEBUG: CURRENT LINE=",NR >> errorFile

  # Manage key columns
  for(i=1;i<=nbKeyColumns;i++) {
    #printf "DEBUG: Column %s,  CurrentKey= %s, Value= %s", i, key[i], ($i) >> errorFile

    if (key[i] == "") {
      #print "*** DEBUG: GO OPTION 1 - NEW NODE" >> errorFile
      printf "\n\"%s\": {", ($i)
      key[i] = ($i)
    } else if (key[i] != $i) {
      # If new key, end old node and create a new node
      #print "*** DEBUG: GO OPTION 2 - RENEW NODE, CLOSE OLD ONE" >> errorFile
      for(c=i+1;c<=nbKeyColumns;c++) {
        # close current record and reinit array
        #print "*** DEBUG: REINIT ARRAY i=",i >> errorFile
        printf "}"
        key[c] = ""
      }
      printf ",\n\"%s\": {", ($i)
      key[i] = ($i)
    } else if (i == nbKeyColumns) {
      # We are last key column with same value, this is duplicate
      print "ERROR: duplicate Key, skip line ", NR >> errorFile
      next
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
  gsub("\"","",$i)
  gsub("\\","\\\\\\",$i)
  sub("\r","",$i)
  printf "\"%s\":\"%s\" }", header[i], ($i)
}
END{
  for(c=0;c<nbKeyColumns;c++) printf "}"
}
