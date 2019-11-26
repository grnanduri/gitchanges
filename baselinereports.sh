!/usr/bin/env bash
############################################################################
## Title :              baselinereports.sh
## Description:         Find all the repo's based on the repolist.txt file
##                      Tag the latest commit and find the differences with   
##                      the last release commit. (Tag version)
## Author:              Nanduri
## Created:             11/26/19
## Dependencies:        bash (v4.0+), git
############################################################################

# Setup
base=/app/jenkins/workspace/
list=$WORKSPACE/repolist.txt
releaseTag1=$RELEASE_TAG1 # This is input from a jenkins job
releaseTag2=$RELEASE_TAG2 # This is input from a jenkins job
echo $COMMENTS # This is input from a jenkins job 
echo $releaseTag1
echo $releaseTag2

# Get the list of Git repos in repolist.txt
readarray -t urls < $list
echo "GIT REPO URLs : ${urls[@]}"

# Get the list of directories in $base
dirs=( $(find $base -maxdepth 1 -mindepth 1 -type d) )
untracked=("${dirs[@]}")
echo $dirs

function dir_not_found {
  
}
