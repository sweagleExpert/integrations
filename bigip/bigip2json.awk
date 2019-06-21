  # Script to transform a bigip config file to json

  function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
  function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
  function trim(s)  { return rtrim(ltrim(s)); }

  BEGIN { FS=" "; RS="\n"; ORS="\n" }
  {

    maxLength=30
    # Manage first line
    if (NR == 1) {
      print "{"
      firstItem=0
      nodeIndex=0
    }

  #if (index($0, "file-blacklist")>0) {
  #    print "-------------------------------------"
  #    print "Nb of records=" NF
  #
  #    for (i=1; i<=NF; i++) {
  #      print "**** RECORD " i
  #      print "value="$i
  #    }
  #}

    $0=trim($0)

  #  if (($0 ~ /"\{/) && ($0 ~ /\}"/)) {
    if (($0 ~ /"/) && (index($0, "{") == 0 || index($0, "{") > index($0, "\""))) {
      # this is a key=value with specific character
      value=substr($0, index($0, "\""))
      if (firstItem == 0) {
        printf "\"%s\":%s", $1, value
        firstItem=1
      } else {
        printf ",\"%s\":%s", $1, value
      }

    } else if (($0 ~ / \{/) && ($0 ~ / \}/)) {
      # if record contains both a { and }, it is an array element
      nodeNameLength = index($0, " {")
      if (nodeNameLength>maxLength) {
        nodeIndex=nodeIndex+1
        arrayName=sprintf("%s-%i", substr($0, 1, maxLength), nodeIndex)
      } else {
        arrayName=substr($0, 1, nodeNameLength)
        #arrayName=substr($0, 1, index($0, "{")-1)
      }
      arrayValue=substr($0, index($0, "{"))
      # This is to build a JSON array (it is put in comment as complex to handle with too big values created as SWEAGLE node names)
      #if (index(arrayValue, "\"") > 0) {
      #  # if array values already contains ", don't add more
      #  gsub("{ ","[",arrayValue)
      #  gsub(" }","]",arrayValue)
      #  gsub("\" \"","\",\"",arrayValue)
      #} else {
      #  gsub("{ }","[]",arrayValue)
      #  gsub("{ ","[\"",arrayValue)
      #  gsub(" }","\"]",arrayValue)
      #  gsub(" ","\",\"",arrayValue)
      #}
      # manage MSM exception
      #gsub(" MSM ",",\"MSM\",",arrayValue)

      # Easier management of array as a single value
      gsub("\"","",arrayValue)
      gsub("{","\"[",arrayValue)
      gsub("}","]\"",arrayValue)

      if (firstItem == 0) {
        printf "\"%s\":%s", arrayName, arrayValue
        firstItem=1
      } else {
        printf ",\"%s\":%s", arrayName, arrayValue
      }

    } else if ($0 ~ / \{/) {
      # if record contains a {, it is a starting element
      nodeNameLength = index($0, " {")
      if (nodeNameLength>maxLength) {
        nodeIndex=nodeIndex+1
        nodeName=sprintf("%s-%i", substr($0, 1, maxLength), nodeIndex)
      } else {
        nodeName=substr($0, 1, nodeNameLength)
      }
      if (firstItem == 0) {
        printf("\"%s\": {\n", nodeName)
      } else {
        printf(",\"%s\": {\n", nodeName)
      }
      firstItem=0

    } else if ($0 ~ /\}/) {
      # if record contains } if is a end element
      print "}"

    } else if (NF == 2 ){
      # if there is only a key + value
      if (firstItem == 0) {
        printf "\"%s\":\"%s\"", $1, $2
        firstItem=1
      } else {
        printf ",\"%s\":\"%s\"", $1, $2
      }

    } else if (NF == 1 ){
      # if there is only a key
      if (firstItem == 0) {
        printf "\"%s\":\"\"", $1
        firstItem=1
      } else {
        printf ",\"%s\":\"\"", $1
      }
    }

  }
  END {
    print "}"
  }
