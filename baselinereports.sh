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
	repo_url = "$1"
	
	echo "The following repository was found in your list but not in the $base directory:"
	echo -e "\t$repo_url"
	
	# Ask the user about cloning the repo (and repeat if input is invalid)
	ans=''
	while [[ $ans != 'y' ]] && [[ $ans != 'n' ]]; do
		read -rp "Would you like to clone it? (y/n) " ans
		if [[ $ans == '' ]]; then ans="y"; fi
		ans=$(echo "$ans" | tr '[:upper:] '[:lower:]')
	done
	
	# Clone the repo if the user answer is 'yes'
	if [[ $ans == 'y' ]]; then
		cd "$base"
		git clone "$repo_url"
		return
	fi
	
	# Ask the user if they'd like to remove that repo from the list
	ans=''
	while [[ $ans != 'y' ]] && [[ $ans != 'n' ]]; do
		read -rp "Would you like to remove this repo from your $list file? (y/n) " ans
		if [[ $ans == '' ]]; then ans="y"; fi
		ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
	done
	
	# If 'yes' then delete the line from the list of repos
	if [[ $ans == 'y' ]]; then
		user=$(echo "$repo_url" | awk -F/ '{print $(NF-1)}' | cut -d: -f2)
		repo=$(echo "$repo_url" | awk -F/ '{print $NF}')
		sed -i "/$user\/$repo/d" $list
	fi
	
}

# Iterate over the repos found in the list
for url in "${urls[@]}"; do
	counter=0
	echo "URL : $url"
	for dir in "${dirs[@]}"; do
		# Save the current number of elements in the dirs array
		num_dirs="${dirs[@]}"
		echo "DIRECTORY : $dir"
		cd "$dir"
		if [[ $url == $(git config --get remote.origin.url) ]]; then
			echo "Updating $(echo "$url" | awk -F/ '{print $NF}' | cut -d. -f1)..."
			git remote update
			git fetch
			git checkout $BRANCH
			git tag -a $releaseTag1 -m "$COMMENTS"
			git push origin $releaseTag1
			git checkout $releaseTag1
			git pull origin $releaseTag1
			newCommitID=$(git rev-parse HEAD)
			git checkout $releaseTag2
			git pull origin $releaseTag2
			oldCommitID=$(git rev-parse HEAD)
			repo=$(git config --get remote.origin.url | awk -F/ '{print $NF}' | cut -d. -f1)
			echo "git whatchanged -p $newCommitID...$oldCommitID --stat=200 --stat-name-width=150 --pretty=medium > 
				$WORKSPACE/$repo.txt"
			git whatchanged -p $newCommitID...$oldCommitID --stat=200 --stat-name-width=150 --pretty=medium > 
				$WORKSPACE/$repo.txt
			echo
			# Remove the found directory
			unset "untracked[$counter]"
			break
		fi
		counter=$((counter + 1 ))
	done
	if [[ $counter -ge $num_dirs ]]; then
		dir_not_found "$url"
		eho
	fi
done
			
			
			
			
			
			
