# File: ldif2csv.awk
# Create csv dump for whole database
#

BEGIN {
#        FS=":";RS=""; OFS=":"
        swLogin    = ""
        swName     = ""
        swEmail    = ""
        swPassword = "welcome!"
        swType     = "PERSON"
        swRole     = ""
        printf("swLogin,swName,swEmail,swPassword,swType,swRole\n");
}
gsub(": ",":")
/^DN/ {ndn=$2}
/^sn/ {swLogin=$2}
/^cn/ {swName=$2" "$3}
/^mail/ {swEmail=$2}
/^DN/ {
        if(swLogin != "" && swName != "") printf("%s,%s,%s,%s,%s,%s\n",swLogin,swName,swEmail,swPassword,swType,swRole)
        dn = ndn
        swLogin    = ""
        swName     = ""
        swEmail    = ""
        swPassword = "welcome!"
        swType     = "PERSON"
        swRole     = ""
}
# Capture last dn
END {
    if(swLogin != "" && swName != "") printf("%s,%s,%s,%s,%s\n",swLogin,swEmail,swPassword,swType,swRole)
}
