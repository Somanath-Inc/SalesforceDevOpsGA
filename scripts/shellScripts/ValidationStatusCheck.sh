#!/bin/bash

if [ $# -eq 2 ];
then
    USERNAME=$2
    DEPLOYMENTID=$1
else
    echo "Please provide username and deployment ID"
    exit 1
fi

if [ -n $DEPLOYMENTID ];
then
    while true
    do
        sleep 10s
        sfdx force:data:record:get --sobjectid $DEPLOYMENTID --sobjecttype deployRequest --targetusername $USERNAME --usetoolingapix --json > validationStatus.json
        validationStatus=$(jq '.result.Status' validationStatus.json | sed 's/"//g' )
        echo "Validation Status: $validationStatus"
        if [ $validationStatus == "Succeeded" ];
        then
            totalComp=$(jq '.result.NumberComponentsTotal' validationStatus.json | sed 's/"//g')
            validatedComp=$(jq '.result.NumberComponentsDeployed' validationStatus.json | sed 's/"//g')
            failedComp=$(jq '.result.NumberComponentErrors' validationStatus.json | sed 's/"//g')
            echo "*************** Validation Successful *******************"
            echo "No of Components Validated: $validatedComp , Out of $totalComp Components, Failed Component counts : $failedComp "
            break
        elif [ $validationStatus == "Failed" ]
        then
            cat validationStatus.json
            errorMessage=$(jq '.result.message' validationStatus.json | sed 's/"//g')
            echo "############################ Oh!!! There are some issue in Code Validation . . Error Message : $errorMessage .Fix the issue and Come back ... GoodBye................"
            exit 1
        elif [ "$validationStatus" == "Canceled" ];
        then
            cat validationStatus.json
            canceledByUId=$(jq '.result.CanceledById' validationStatus.json | sed 's/"//g')
            echo "############################ Oh!!! Someone canceled your validation. It has been canceled by user ID : $canceledByUId .Please check with the user and Raise PR again and Come back ... GoodBye......"
            exit 1
        else
            totalTestClass=$(jq '.result.NumberTestsTotal' validationStatus.json | sed 's/"//g')
            executedTestClasses=$(jq '.result.NumberTestsCompleted' validationStatus.json | sed 's/"//g')
            failedTestClasses=$(jq '.result.NumberTestErrors' validationStatus.json | sed 's/"//g')
            totalComp=$(jq '.result.NumberComponentsTotal' validationStatus.json | sed 's/"//g')
            validatedComp=$(jq '.result.NumberComponentsDeployed' validationStatus.json | sed 's/"//g')
            failedComp=$(jq '.result.NumberComponentErrors' validationStatus.json | sed 's/"//g')
            echo "Validation in progress . . . . . . . "
            echo "No of Components Validated: $validatedComp , Out of $totalComp Components, Failed Component counts : $failedComp "
            echo "Number of Test Classes Executed: $executedTestClasses , Out of  $totalTestClass Tests, Failed Test Class count : $failedTestClasses"
            echo ""
            echo "########################################################################################"
            echo ""
        fi
    done
else
    echo "Validation Failed"
    exit 1
fi