#!/usr/bin/env bash

##########################################################################
#############
#############   EXTRACT USEFUL CONFIG FROM SYSTEM FILES AND PUT IT IN JSON FORMAT
#############
############# Output: 0 if no errors, 1 + Details of errors if any
##########################################################################
if [ "$#" -lt "1" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-OUTPUT FILE"
    exit 1
fi
output=$1

# List of files to parse, put a line with empty value to remove it
#CONF_EXECS is an array of execs files to control vs a template configuration
CONF_EXECS=("/PATH/TO/EXECS1"
  "/PATH/TO/EXECS1")
CONF_GROUP=/etc/group
CONF_HOSTS=/etc/hosts
if  [ -f /etc/sssd ]; then
 CONF_LDAP=/etc/sssd
else
 CONF_LDAP=/etc/ldap/ldap.conf
fi
CONF_LIMITS=/etc/security/limits.conf
CONF_NETWORK=
CONF_NSSWITCH=/etc/nsswitch.conf
CONF_PASSWD=/etc/passwd
CONF_RESOLV=/etc/resolv.conf
CONF_SUDOERS=/etc/sudoers
CONF_SYSCTL=/etc/sysctl.conf

# helper to convert hex to dec (portable version)
function hex2dec(){
    [ "$1" != "" ] && printf "%d" "$(( 0x$1 ))"
}

# expand an ipv6 address
function expand_ipv6() {
    ip=$1

    # prepend 0 if we start with :
    echo $ip | grep -qs "^:" && ip="0${ip}"

    # expand ::
    if echo $ip | grep -qs "::"; then
        colons=$(echo $ip | sed 's/[^:]//g')
        missing=$(echo ":::::::::" | sed "s/$colons//")
        expanded=$(echo $missing | sed 's/:/:0/g')
        ip=$(echo $ip | sed "s/::/$expanded/")
    fi

    blocks=$(echo $ip | grep -o "[0-9a-f]\+")
    set $blocks

    printf "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n" \
        $(hex2dec $1) \
        $(hex2dec $2) \
        $(hex2dec $3) \
        $(hex2dec $4) \
        $(hex2dec $5) \
        $(hex2dec $6) \
        $(hex2dec $7) \
        $(hex2dec $8)
}


dir=$(dirname "${output}")
mkdir -p $dir

if [ -f /etc/redhat-release ]; then
    os="redhat"
else
    os=$(awk -F= '/^NAME/{print $2}' /etc/os-release | sed 's/"//g')
fi
case $os in
  "CentOS Linux"|"redhat")
    echo -e '{"os":{' > $output
    echo '"DISTRIB_DESCRIPTION":"'$(cat /etc/redhat-release)'",'  >> $output
    uname -a | awk '{print "\"uname\":\""$3"\","}' >> $output
    # replace last , by } to end json element
    sed -i '$ s/.$/}/' $output

    echo -e ',\n"packages":{' >> $output
    rpm -qa --qf "\"%{n}\":\"%{v}.%{r}\",\n" >> $output
    ;;
  "Ubuntu")
    echo -e '{"os":{' > $output
    cat /etc/lsb-release | awk 'BEGIN {FS="="}; {gsub(/\"/, "", $0); print "\""$1"\":\""$2"\","}' >> $output
    uname -a | awk '{print "\"uname\":\""$3"\","}' >> $output
    # replace last , by } to end json element
    sed -i '$ s/.$/}/' $output

    echo -e ',\n"packages":{' >> $output
    apt list --installed > $output.tmp
    # put only name of package = version in result
    # use getline to ignore first line as it contains a comment
    cat $output.tmp | awk '{getline
              print "\"" substr($1, 1, index($1, "/")-1) "\":\""$2"\","}' >> $output
    ;;
  *)
    echo "**** ERROR : OS $os not recognized"
    exit 1
    ;;
esac
# replace last , by } to end json element
sed -i '$ s/.$/}/' $output


if [ -n "$CONF_EXECS" ]; then
  # Do the execs list
  echo -e ',\n"execs":{' >> $output
  for dir in "${CONF_EXECS[@]}"
  do
    # Get list of exec files
    #This works only on recent linux: EXEC_FILES=($(find $dir -executable -type f  | xargs -n 1 basename))
    EXEC_FILES=($(find $dir -perm /111 -type f  | xargs -n 1 basename))
    echo '"'$dir'":[' >> $output
    echo '"'${EXEC_FILES[@]}'"' | awk '{ gsub (" ", "\",\"", $0); print}' >> $output
    echo '],' >> $output
  done
  # replace last , by } to end json element
  sed -i '$ s/.$/}/' $output
fi


if [ -n "$CONF_GROUP" ]; then
  # Do the group file
  echo -e ',\n"group":{' >> $output
  cat $CONF_GROUP > $output.tmp
  # this could also be getent passwd
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  # Transform into awk file by replacing first : or tab by <pspace>
  sed -i -r 's/(:)/ /' $output.tmp
  cat $output.tmp | awk '{print "\""$1"\":\""$2"\","}' >> $output
  # replace last , by } to end json element
  sed -i '$ s/.$/}/' $output

  # Do the group file, only sudo
  # cat $output.tmp | grep sudo | awk 'BEGIN {FS=":"}; {print ",\n\"sudo\":{\"sudo\":\""$3"\"}"}' >> $output
fi


if [ -n "$CONF_HOSTS" ]; then
  # Do the hosts file
  echo -e ',\n"hosts":{' >> $output
  cat $CONF_HOSTS > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  # Transform into properties file by replacing first space or tab by =
  sed -i -r 's/( |\t)/=/' $output.tmp
  while IFS='=' read -r col1 col2
  do
    # Check if it is an IPv6 address
    if [[ $col1 == *":"* ]]; then
      # If IPv6, then expand it so that SWEAGLE import works betters
      echo $(expand_ipv6 "$col1") "=" $col2 | awk 'BEGIN {FS="="}; {gsub(/(\t)/, "", $0); gsub("  ","",$0); print "\""$1"\":\""$2"\","}' >> $output
    else
      echo "$col1 = $col2" | awk 'BEGIN {FS="="}; {gsub(/(  |\t)/, "", $0); print "\""$1"\":\""$2"\","}' >> $output
    fi
  done < $output.tmp
  # replace last , by } to end json element
  sed -i '$ s/.$/}/' $output
fi


if [ -n "$CONF_LDAP" ]; then
  # Do the ldap.conf file
  echo -e ',\n"ldap":{' >> $output
  cat $CONF_LDAP > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  if [ -s $output.tmp ]; then
    # There are still lines in conf file, put them in json format
    # Transform into properties file by replacing first space or tab by =
    sed -i -r 's/( |\t)/==/' $output.tmp
    cat $output.tmp | awk 'BEGIN {FS="=="}; {print "\""$1"\":\""$2"\","}' >> $output
    # replace last , by ] to end json array
    sed -i '$ s/.$/}/' $output
  else
    # no lines in conf file, replace last character ({) by empty json element ""
    sed -i '$ s/.$/\"\"/' $output
  fi
fi


if [ -n "$CONF_LIMITS" ]; then
  # Do the limits.conf file
  echo -e ',\n"limits":{' >> $output
  cat $CONF_LIMITS > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  if [ -s $output.tmp ]; then
    # There are still lines in conf file, put them in json format
    cat $output.tmp | awk 'BEGIN {FS="\t"};
        {print "\""NR"\":{\"domain\":\""$1"\",\"type\":\""$2"\",\"item\":\""$3"\",\"value\":\""$4"\"},"}' >> $output
    # replace last , by } to end json element
    sed -i '$ s/.$/}/' $output
  else
    # no lines in conf file, replace last character ({) by empty json element ""
    sed -i '$ s/.$/\"\"/' $output
  fi
fi


if [ -n "$CONF_NSSWITCH" ]; then
  # Do the nsswitch.conf file
  echo -e ',\n"nsswitch":{' >> $output
  cat $CONF_NSSWITCH > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  # Trim spaces and tabs
  sed -i -e 's/^\s*//' -e '/^$/d' -e '/\t/d' $output.tmp
  # Transform into properties file by replacing first : by ==
  sed -i -r 's/(:)/==/' $output.tmp
  cat $output.tmp | awk 'BEGIN {FS="=="}; {gsub(/  /, "",$0); print "\""$1"\":\""$2"\","}' >> $output
  # replace last , by ] to end json array
  sed -i '$ s/.$/}/' $output
fi


if [ -n "$CONF_RESOLV" ]; then
  # Do the resolv.conf file
  echo -e ',\n"resolv":{' >> $output
  cat $CONF_RESOLV > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  # Transform into properties file by replacing first space or tab by =
  sed -i -r 's/( |\t)/=/' $output.tmp
  cat $output.tmp | awk 'BEGIN {FS="="};
    {print "\""NR"\":{\""$1"\":\""$2"\"},"}' >> $output
  # replace last , by ] to end json array
  sed -i '$ s/.$/}/' $output
fi


if [ -n "$CONF_SUDOERS" ]; then
  # Do the sudoers file
  echo -e ',\n"sudoers":{' >> $output
  cat $CONF_SUDOERS > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r '/^(#.*)$/d' $output.tmp
  sed -i -r '/^   /d' $output.tmp
  sed -i -r '/\\$/d' $output.tmp
  # Transform into awk file by replacing first <space> by ==
  # and removing quote
  sed -i -r 's/(\t| )/==/' $output.tmp
  cat $output.tmp | awk 'BEGIN {FS="=="};
    {gsub(/\"/, "", $0); gsub(/(\t|  )/, "", $0); print "\""NR"\":{\""$1"\":\""$2"\"},"}' >> $output
  # replace last , by } to end json element
  sed -i '$ s/.$/}/' $output
fi


if [ -n "$CONF_SYSCTL" ]; then
  # Do the sysctl.conf file
  echo -e ',\n"sysctl":{' >> $output
  cat $CONF_SYSCTL > $output.tmp
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  if [ -s $output.tmp ]; then
    # There are still lines in conf file, put them in json format
    cat $output.tmp | awk 'BEGIN {FS="="}; {gsub(/ /, "", $0); print "\""$1"\":\""$2"\","}' >> $output
    # replace last , by } to end json element
    sed -i '$ s/.$/}/' $output
  else
    # no lines in conf file, replace last character ({) by empty json element ""
    sed -i '$ s/.$/\"\"/' $output
  fi
fi


if [ -n "$CONF_PASSWD" ]; then
  # Do the list of users = passwd file
  echo -e ',\n"passwd":{' >> $output
  cat $CONF_PASSWD > $output.tmp
  # this could also be getent passwd
  # Remove all empty or commented lines
  sed -i -r '/^$/d' $output.tmp
  sed -i -r  '/^(#.*)$/d' $output.tmp
  # Transform into properties file by replacing first : or tab by =
  sed -i -r 's/(:)/=/' $output.tmp
  cat $output.tmp | awk 'BEGIN {FS="="}; {gsub(/\"/,"",$0); print "\""$1"\":\""$2"\","}' >> $output
  # replace last , by } to end json element
  sed -i '$ s/.$/}/' $output
  # Replace all other occurence of : by space to avoid INI escaping
  #sed -i -r 's/:/ /g' $output.tmp
fi

if [ -n "$CONF_NETWORK" ]; then

# Do the ifconfig
#INTERFACES=($(ls /sys/class/net))

INTERFACES=($(ls -d /sys/class/net/*/ | awk 'BEGIN {FS="/"}; {print $5}'|tr '\n' ' '))

#echo INT=$INTERFACES
echo -e ',\n"network":{' >> $output
for network in "${INTERFACES[@]}"
do
  echo -e '"'$network'":{' >> $output
  ifconfig -a $network > $output.tmp
  cat $output.tmp | grep 'inet ' | awk 'BEGIN {FS=":"}; {print "\"inet\":\""$2"\","}'|sed -r 's/\s+.+$//' >> $output
  cat $output.tmp | grep 'inet6' | awk '{print "\"inet6\":\""$2"\","}' >> $output
  cat $output.tmp | grep 'netmask' | awk '{print "\"netmask\":\""$4"\","}' >> $output
  cat $output.tmp | grep 'Mask' | awk 'BEGIN {FS=":"}; {print "\""$4"\","}'|sed -r 's/\s+.+$//' >> $output
  cat $output.tmp | grep 'broadcast' | awk '{print "\"broadcast\":\""$6"\","}' >> $output
  cat $output.tmp | grep 'Bcast' | awk 'BEGIN {FS=":"}; {print "\"broadcast\":\""$3"\","}'|sed -r 's/\s+.+[^"]//' >> $output
  cat $output.tmp | grep 'mtu' | awk '{print "\"mtu\":\""$4"\","}' >> $output
  if [ $network = "lo" ]; then
    cat $output.tmp | grep 'txqueuelen' | awk '{print "\"txqueuelen\":\""$3"\"},"}' >> $output
  else
    cat $output.tmp | grep 'txqueuelen' | awk '{print "\"txqueuelen\":\""$4"\"},"}' >> $output
  fi
done
# replace last , by } to end json element
sed -i '$ s/.$/}/' $output

fi

# End the JSON file
echo -e '\n}' >> $output
rm $output.tmp
