if [ $# -ne 1 ];
then
    echo "Please provide username"
    exit 1
else
    USERNAME=$1
fi

if [ -f package/package.xml ];
then
    cmpTypeCount_Pkg=$(grep -c "<name>.*</name>" package/package.xml)
    if [ -f package/destructiveChanges.xml ];
    then
        cmpTypeCount_dePkg=$(grep -c "<name>.*</name>" package/destructiveChanges.xml)
    fi
fi
echo "cmpTypeCount_Pkg : $cmpTypeCount_Pkg --------- cmpTypeCount_dePkg : $cmpTypeCount_dePkg ----------"
if [ $cmpTypeCount_Pkg -gt 0 ] || [ $cmpTypeCount_dePkg -gt 0 ]
then
    echo "Started Deployment ---------------- "
    sfdx force:source:deploy --manifest package/package.xml --targetusername $USERNAME --postdestructivechanges package/destructiveChanges.xml --wait 0 --json > deployment.json
    cat deployment.json
    deploymentStatus=$(jq '.status' deployment.json)
    deploymentId=$(jq '.result.id' deployment.json | sed 's/"//g')
    echo "Validation Status: $deploymentStatus --------- DeploymentId: $deploymentId"
    if [ "$deploymentStatus" != 0 ];
    then
        errorMessage=$(jq '.result.message' validation.json)
        echo "*****Error***** Deploymnet Failed ..... Error Message: $errorMessage"
        exit 1
    else
        echo "Deployment Started with Deployment Id: $deploymentId"
        echo "DEPLOYMENTID=$deploymentId" >> $GITHUB_ENV
    fi
else
    echo "No Source backed components present in the package.xml. So, Deployment failed to start"
fi
