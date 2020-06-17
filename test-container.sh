#!/bin/sh
FOLDER="$(realpath "$(dirname "$0")")"
REG_USERNAME=cs-infra
REG_PASSWORD=sWzvEEhpKP3ZZ-t5uwpC
REG_EMAIL=cs-infrastructure@continuoussoftware.ie
REG_URL=registry.gitlab.com
docker login -u $REG_USERNAME -p $REG_PASSWORD $REG_URL
PREFIX=""
if [ "" != "$(which winpty)" ]; then
	PREFIX="winpty "
fi
${PREFIX}docker volume create k8s_addson_volume
${PREFIX}docker run --rm -it --name k8s-addson --mount 'source=k8s_addson_volume,target=//mnt/disk' registry.gitlab.com/aangine/kubernetes/aangine-k8s-addson-config/qa:latest clone git@gitlab.com:aangine/devops/kubernetes-aangine-charts-config.git master ^^^ script //root/repo/kubernetes-aangine-charts-config //root/repo/kubernetes-aangine-charts-config/execute-config.sh //mnt/disk/kubernetes/config

docker logout $REG_URL
${PREFIX}docker volume rm -f k8s_addson_volume
