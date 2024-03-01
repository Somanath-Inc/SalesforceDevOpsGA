if [ $# -ne 1 ];
then
    echo "Please provide username"
    exit 1
else
    USERNAME=$1
fi

if [ -f package/package.xml ];
then
    cmpTypeCount_Pkg=$(grep -c "<name>*</name>" package/package.xml)
fi
if [ -f package/destructiveChanges.xml ];
then
    cmpTypeCount_dePkg=$(grep -c "<name>*</name>" package/destructiveChanges.xml)
fi
echo "cmpTypeCount_Pkg : $cmpTypeCount_Pkg --------- cmpTypeCount_dePkg : $cmpTypeCount_dePkg ----------"
if [ $cmpTypeCount_Pkg -gt 0 ] || [ $cmpTypeCount_dePkg -gt 0 ];
then
    echo "Started Validation ---------------- "
    sfdx force:source:deploy --manifest package/package.xml --target-username $USERNAME --postdestructivechanges package/destructiveChanges.xml --checkonly --wait 0 --json > validation.json
    cat validation.json
    validationStatus=$(jq '.status' validation.json)
    deploymentId=$(jq '.result.id' validation.json | sed 's/"//g')
    echo "Validation Status: $validationStatus --------- DeploymentId: $deploymentId"
    if [ "$validationStatus" != 0 ];
    then
        errorMessage=$(jq '.result.message' validation.json)
        echo "*****Error***** Validation Failed ..... Error Message: $errorMessage"
        exit 1
    else
        echo "Validation Started with Deployment Id: $deploymentId"
        echo "DeploymentID=$deploymentId" >> $GITHUB_ENV
    fi
else
    echo "No Source backed components present in the package.xml. So, Validation failed to start"
fi