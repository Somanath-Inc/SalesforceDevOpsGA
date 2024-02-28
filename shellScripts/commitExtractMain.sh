#!/bin/bash

cd TargetBranchPath

if [ $? -ne 0];
then
    echo "Target Path Not Found"
    exit 1
fi

git branch

TARGET_COMMIT_ID=$(git log | grep commit | head -1 | tail -1  | awk '{print $2}')
echo "Target Branch Commit ID : $TARGET_COMMIT_ID"
echo "TARGET_COMMIT_ID=$TARGET_COMMIT_ID" >> $GITHUB_ENV   
cd ../