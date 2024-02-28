#!/bin/bash
cd SourceBranchPath

if [ $? -ne 0 ];
then
    echo "Source Branch Path Not Found!!"
    exit 1
fi

SOURCE_COMMIT_ID=$(git log | grep commit | head -1 | tail -1 | awk '{print $2}')
echo "Source Branch Commit ID = $SOURCE_COMMIT_ID"
echo "SOURCE_COMMIT_ID=$SOURCE_COMMIT_ID" >> $GITHUB_ENV

cd ../TargetBranchPath
if [ $? -ne 0 ];
then
    echo "Target Branch Path Not Found!!"
    exit 1
fi

TARGET_COMMIT_ID=$(git log | grep commit | head -1 | tail -1 | awk '{print $2}')
echo "Target Branch Commit ID = $TARGET_COMMIT_ID"
echo "TARGET_COMMIT_ID=$TARGET_COMMIT_ID" >> $GITHUB_ENV