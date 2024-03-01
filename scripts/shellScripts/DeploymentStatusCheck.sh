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
        sfdx force:data:record:get --sobjectid $DEPLOYMENTID --sobjecttype deployRequest --targetusername $USERNAME --usetoolingapix --json > DeploymentStatus.json
        DeploymentStatus=$(.jq '.result.Status' DeploymentStatus.json | sed 's/"//g' )
        echo "Deployment Status: $DeploymentStatus"
        if [ $DeploymentStatus == "Succeeded" ];
        then
            totalComp=$(jq '.result.NumberComponentsTotal' DeploymentStatus.json | sed 's/"//g')
            DeployedComp=$(jq '.result.NumberComponentsDeployed' DeploymentStatus.json | sed 's/"//g')
            failedComp=$(jq '.result.NumberComponentErrors' DeploymentStatus.json | sed 's/"//g')
            echo "*************** Deployment Successful *******************"
            echo "No of Components Deployed: $DeployedComp , Out of $totalComp Components, Failed Component counts : $failedComp "
            break
        elif [ $DeploymentStatus == "Failed" ]
        then
            cat DeploymentStatus.json
            errorMessage=$(jq '.result.message' DeploymentStatus.json | sed 's/"//g')
            echo "############################ Oh!!! There are some issue in Code Deployment . . Error Message : $errorMessage .Fix the issue and Come back ... GoodBye................"
            exit 1
        elif [ "$DeploymentStatus" == "Canceled" ];
        then
            cat DeploymentStatus.json
            canceledByUId=$(jq '.result.CanceledById' DeploymentStatus.json | sed 's/"//g')
            echo "############################ Oh!!! Someone canceled your Deployment. It has been canceled by user ID : $canceledByUId .Please check with the user and Raise PR again and Come back ... GoodBye......"
            exit 1
        else
            totalTestClass=$(jq '.result.NumberTestsTotal' DeploymentStatus.json | sed 's/"//g')
            executedTestClasses=$(jq '.result.NumberTestsCompleted' DeploymentStatus.json | sed 's/"//g')
            failedTestClasses=$(jq '.result.NumberTestErrors' DeploymentStatus.json | sed 's/"//g')
            totalComp=$(jq '.result.NumberComponentsTotal' DeploymentStatus.json | sed 's/"//g')
            DeployedComp=$(jq '.result.NumberComponentsDeployed' DeploymentStatus.json | sed 's/"//g')
            failedComp=$(jq '.result.NumberComponentErrors' DeploymentStatus.json | sed 's/"//g')
            echo "Deployment in progress . . . . . . . "
            echo "No of Components Deployed: $DeployedComp , Out of $totalComp Components, Failed Component counts : $failedComp "
            echo "Number of Test Classes Executed: $executedTestClasses , Out of  $totalTestClass Tests, Failed Test Class count : $failedTestClasses"
            echo ""
            echo "########################################################################################"
            echo ""
        fi
    done
else
    echo "Deployment Failed"
    exit 1
fi