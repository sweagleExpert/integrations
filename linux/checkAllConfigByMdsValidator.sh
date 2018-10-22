#!/usr/bin/env bash
source $(dirname "$0")/sweagle.env

##########################################################################
#############
#############   CHECK ALL CONFIG STATUS FROM SWEAGLE FOR SPECIFIC MDS & VALIDATORS
#############
############# Input: MDS to check, VALIDATORS to use
############# Output: 0 if no errors, 1 if errors
##########################################################################

if [ "$#" -lt "2" ]; then
    echo "********** ERROR: NOT ENOUGH ARGUMENTS SUPPLIED"
    echo "********** YOU SHOULD PROVIDE 1-MDS"
    echo "********** YOU SHOULD PROVIDE 2-N-VALIDATORS SEPARATED BY <SPACES>"
    exit 1
fi
argMds=$1
# Remove first item from args to keep only validators list
shift;
argCustomValidators=("$@")
#echo ${argCustomValidators[@]}
validatorResult=0


echo -e "\n**********"
echo "*** First, check status with Sweagle standard validator"
$(dirname "$0")/checkStandardConfigByMds.sh $argMds
validatorResult=$(( validatorResult+$? ))

echo -e "\n**********"
echo "*** Second, check status with Sweagle custom validators"
for validator in "${argCustomValidators[@]}" ; do
  $(dirname "$0")/checkCustomConfigByMdsValidator.sh $argMds $validator
  validatorResult=$(( validatorResult+$? ))
done

echo -e "\n**********"
echo "*** Third, calculate global result"
if [ $validatorResult -ne 0 ]; then
  echo "********** ERROR: AT LEAST ONE VALIDATOR RETURNS WRONG STATUS"
else
  echo "No errors found for MDS: "$argMds
fi
exit $validatorResult
