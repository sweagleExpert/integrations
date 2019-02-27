# Script to transform a CSV formatted file (with header line) into JSON format
# To use it: awk -f csv2json-1key.awk <your csv file>

BEGIN{
  FS=","
  OFS=""

  # Initiate error log file
  errorFile = "./error-csv2json.log"
  print "" > errorFile

  getline #BEGIN runs before anything else, so grab the first line with the header right away
  nbColumns = NF
  for(i=1;i<NF;i++)
    header[i] = ($i)
  # manage last column, removing end of line chars
  sub("\r","",$i)
  header[i] = ($i)
  print "{"
}
{
  if (NF != nbColumns) {
    # Skip current record as number of columns is not correct
    print "ERROR: skip line ", NR >> errorFile
    next
  }
  if (NR>2) printf ","
  printf "\n\"%s\": {", ($1)
  for(i=1;i<NF;i++)
  {
    # remove double quotes
    gsub("\"","",$i)
    # escape backslash by double backslash
    gsub("\\","\\\\\\",$i)
    printf "\"%s\":\"%s\", ", header[i], ($i)
  }
  # manage last column
  sub("\r","",$i)
  printf "\"%s\":\"%s\" }", header[i], ($i)
}
END{
  print "}"
}
