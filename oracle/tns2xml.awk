# Script to transform a tnsnames.ora file into XML format
# To use it: awk -f tns2xml.awk <your tns file>

BEGIN { FS="="; RS=""; ORS="\n" }
{
    delete tag
    counter = 0
    tnsnames = ""

    if (NR == 1) {
      tnsnames = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?><TNSNAMES>"
    }

    # trim the value
    gsub(/[ \t\n]+/,"",$1)
    tnsnames = tnsnames "<" $1 ">"
    tag[counter] = "</" $1 ">"

    #print "-------------------------------------"
    #print "Name=" $1
    #print "Nb of records=" NF

    for (i=2; i<=NF; i++) {
      #print "**** RECORD " i
      #print "Initial value="$i
      # trim the value
      gsub(/[ \t\n]+/,"",$i)

#      if ($i ~ /^\(/) {
#        print "*** IDENTIFY START TAG"
#        # if record starts with (, it is a starting TAG
#        # remove (, and store tag
#        sub(/\(/,"",$i)
#        counter = counter + 1
#        tag[counter] = "</" $i ">"
#        $i = "<" $i ">"
#      }


      if ($i ~ /^\"/) {
        #print "*** IT IS A VALUE"
        # remove first char
        value = substr($i,2)
        # check if it has not been splitted in multiple lines"
        while ( index(value,"\"") == 0  && i<=NF) {
            #print "it seems ko, no other double quotes"
            i = i+1
            value = value "=" $i
        }
        sub(/\"/, "", value)
        $i = value
      }

      if ($i ~ /\)/) {
        # if record contains a ), it contains a value
        #print "*** IDENTIFY END TAG"
        # replace each ) by corresponding end tag
        while ( index($i,")") > 0 ) {
          sub(/\)/, tag[counter], $i)
          counter = counter - 1
        }
      }

      if ($i ~ /\(/) {
        # if record contains a (, it is a starting TAG, get it
        #print "*** IDENTIFY START TAG"
        startTAG = substr($i,index($i,"(")+1)

        # replace ( by corresponding start tag
        sub(/\(/, "<", $i)
        $i = $i ">"
        #print "*** IDENTIFY START TAG"
        counter = counter + 1
        tag[counter] = "</" startTAG ">"
      }

      tnsnames = tnsnames $i
      #print "*** TNSNAMES=" tnsnames
    }

    tnsnames = tnsnames tag[0]
    print tnsnames
}
END {
  print "</TNSNAMES>"
}
