if [ $# -ne 2 ];
then
    echo "Please Input the file Names"
    exit 1
fi
echo "Passed"
SOURCE_BRANCH=$1
TARGET_BRANCH=$2
echo "SOURCE_BRANCH=${ SOURCE_BRANCH }" >> $GITHUB_ENV
echo "TARGET_BRANCH=${ TARGET_BRANCH }" >> $GITHUB_ENV