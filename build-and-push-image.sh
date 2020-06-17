#!/bin/sh
FOLDER="$(realpath "$(dirname "$0")")"

if [ "" != "$(which dos2unix)" ]; then
	dos2unix $FOLDER/.env
	if [ -e $FOLDER/docker.env ]; then
		dos2unix $FOLDER/docker.env
	fi
fi

BRANCH=developer
TAG=latest

if [ -e $FOLDER/.env ]; then
	source $FOLDER/.env
	docker login -u $DOCKER_REPO_USER -p $DOCKER_REPO_PASSWORD $DOCKER_REPO_URL 2> /dev/null
fi

if [ "" != "$1" ]; then
	BRANCH="$1"
fi

if [ "" != "$2" ]; then
	TAG="$2"
fi

VARRGS=""
if [ -e $FOLDER/docker.env ]; then
	for argument in $(cat $FOLDER/docker.env); do
		if [ "" != "$(echo $argument|awk 'BEGIN {FS=OFS="="}{print $2}')" ]; then
			VARRGS="$VARRGS --build-arg $argument"
		fi
	done
fi

if [ "" != "$(docker image ls|awk 'BEGIN {FS=OFS=" "}{print $1":"$2}'| grep 'aangine'| grep "aangine-k8s-addson-config/${BRANCH}:${TAG}")" ]; then
	echo "Removing existing docker image ..."
	docker rmi -f registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${BRANCH}:${TAG}
fi

echo "Building aangine-k8s-addson-config rel. ${BRANCH} v. ${TAG} ..."
docker build --rm --force-rm --no-cache $VARRGS -t registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${BRANCH}:${TAG} .
EXIT=$?
if [ "0" = "$EXIT" ] || [ "127" = "$EXIT" ]; then
	if [ -e $FOLDER/.env ]; then
		docker push registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${BRANCH}:${TAG}
		if [ "" != "$DOCKER_BRANCHES" ]; then
			IFS=','; for otherBranch in $DOCKER_BRANCHES; do
				if [ "" != "${otherBranch}" ]; then
					echo "Pushing branch ${otherBranch} ..."
					docker tag "registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${BRANCH}:${TAG}"  "registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${otherBranch}:${TAG}"
					docker push "registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${otherBranch}:${TAG}"
					docker rmi "registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${otherBranch}:${TAG}"
				fi
			done
		fi
		docker logout $DOCKER_REPO_URL
		docker rmi registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/${BRANCH}:${TAG}
	fi
else
	echo "EXIT CODE=$EXIT"
	exit $EXIT
fi
exit 0
