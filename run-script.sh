#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "eun-script.sh {workdir} {remote_script} {arg1} ... {argN}"
	echo "  {workdir}   			Script working folder"
	echo "  {remote_script} 		Remote repository action init script file"
	echo "  {arg1} ... {argN}		Script Arguments arg1 ... argN"
}

if [ $# -lt 2 ]; then
	echo "Insufficient arguments: $# < 2"
	echo -e "$(usage)"
	echo "Exit!!"
	exit 1
fi

SCRIPT_WORKDIR="$1"
SCRIPT_FILE="$2"
ARGS_LEN=${#@}
let LEN=ARGS_LEN-2
ARGS="${@: 3: $LEN}"

echo " "
echo " "
echo "RUN SCRIPT FILE"
echo "======================================================="
echo "Parameters:"
echo "Using script workdir: $SCRIPT_WORKDIR"
echo "Using script file file: $SCRIPT_FILE"
echo "Using script arguments: $ARGS"
echo "Using container script restart policy: $RESTART_POLICY"
echo "======================================================="
echo " "
echo " "

if [ "" = "$SCRIPT_WORKDIR" ] || [ "" = "$SCRIPT_FILE" ]; then
	echo "Unable to parse SCRIPT workdir and/or file: empty!!"
	exit 1
fi

if [ "yes" != "$RESTART_POLICY" ]; then
	if [ -e /root/.script-complete ]; then
		if [ "yes" = "$(cat /root/.script-complete)" ]; then
			echo "Restart policy disabled and script already executed!!"
			echo "Exit!!"
			exit 0
		fi
	fi
fi

echo "Changing for wordir: $SCRIPT_WORKDIR ..."
cd ${SCRIPT_WORKDIR}
echo "Staring script ..."
dos2unix $SCRIPT_FILE
chmod 777 $SCRIPT_FILE
sh -c "cd ${SCRIPT_WORKDIR} && $SCRIPT_FILE $ARGS"
if [ -e /root ]; then
	echo "yes" > /root/.script-complete
fi
echo "SCRIPT Complete!!"