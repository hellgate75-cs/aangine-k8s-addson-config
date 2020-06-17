#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "clone-repo.sh {git_url} {git_branch}"
	echo "  {git_url}    			GitHub or GitLab repository https or ssh url"
	echo "  {git_branch} 			GitHub or GitLab working branch"
}
if [ $# -lt 2 ]; then
	echo "Insufficient arguments: $# < 2"
	echo -e "$(usage)"
	echo "Exit!!"
	exit 1
fi

GIT_URL="$1"
GIT_BASE_FOLDER="$GIT_URL"
if [[ $GIT_BASE_FOLDER =~ '/' ]]; then
	GIT_BASE_FOLDER="$(echo $GIT_BASE_FOLDER|awk 'BEGIN {FS=OFS="/"}{print $NF}')"
fi
if [[ $GIT_BASE_FOLDER =~ '.' ]]; then
	GIT_BASE_FOLDER="$(echo $GIT_BASE_FOLDER|awk 'BEGIN {FS=OFS="."}{print $1}')"
fi
if [[ $GIT_BASE_FOLDER =~ ':' ]]; then
	GIT_BASE_FOLDER="$(echo $GIT_BASE_FOLDER|awk 'BEGIN {FS=OFS=":"}{print $NF}')"
fi
GIT_BRANCH="$2"

GIT_BASE_FOLDER="/root/repo/${GIT_BASE_FOLDER}"

echo " "
echo " "
echo "CLONE GITHUB/GITLAB REPOSITORY"
echo "======================================================="
echo "Parameters:"
echo "Using SVN repository: $GIT_URL"
echo "Using SVN branch: $GIT_BRANCH"
echo "Repository base folder: ${GIT_BASE_FOLDER}"
echo "======================================================="
echo " "
echo " "

if [ "" = "$GIT_URL" ] || [ "" = "$GIT_BRANCH" ]; then
	echo "Unable to parse SVN repository and/or branch: empty!!"
	exit 1
fi

if [ "yes" != "$RESTART_POLICY" ]; then
	if [ -e /root/.clone-complete ]; then
		if [ "yes" = "$(cat /root/.clone-complete)" ]; then
			echo "Restart policy disabled and script already executed!!"
			echo "Exit!!"
			exit 0
		fi
	fi
fi

cd /root/repo
echo "Starting cloning/updating SVN repository"
if [ ! -e $GIT_BASE_FOLDER ]; then
	BASE_CMD="git config --global user.name \"${GIT_USER}\" && git config --global user.email \"${GIT_EMAIL}\""
	echo "Cloning SVN repository: $GIT_URL ..."
	sh -c "${BASE_CMD} && cd /root/repo && git clone $GIT_URL"
	cd $GIT_BASE_FOLDER 
	echo "Switching SVN branch to: $GIT_BRANCH ..."
	sh -c "${BASE_CMD} && $GIT_BASE_FOLDER && git checkout origin $BRANCH"
else
	BASE_CMD="git config --global user.name \"${GIT_USER}\" && git config --global user.email \"${GIT_EMAIL}\" && cd $GIT_BASE_FOLDER"
	cd $GIT_BASE_FOLDER
	echo "Switching SVN branch to: $GIT_BRANCH ..."
	sh -c "BASE_CMD && git checkout origin $BRANCH"
	echo "Fetching SVN from branch: $GIT_BRANCH ..."
	sh -c "BASE_CMD && git fetch"
	echo "Pulling SVN from branch: $GIT_BRANCH ..."
	sh -c "BASE_CMD && git pull origin $GIT_BASE_FOLDER"
fi
echo "List of SVN repository content:"
ls -la
if [ -e /root ]; then
	echo "yes" > /root/.clone-complete
fi
echo "SVN CLONE complete!!"