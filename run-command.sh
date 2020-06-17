#!/bin/bash

FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "eun-command.sh {workdir} {command} {arg1} ... {argN}"
	echo "  {workdir}   			Script working folder"
	echo "  {command} 				Command to execute on the remote host"
	echo "  {arg1} ... {argN}		Script Arguments arg1 ... argN"
}

if [ $# -lt 2 ]; then
	echo "Insufficient arguments: $# < 2"
	echo -e "$(usage)"
	echo "Exit!!"
	exit 1
fi

COMMAND_WORKDIR="$1"
ARGS_LEN=${#@}
let LEN=ARGS_LEN-1
CMD="${@: 2: $LEN}"

echo " "
echo " "
echo "RUN COMMAND"
echo "======================================================="
echo "Parameters:"
echo "Using script workdir: $COMMAND_WORKDIR"
echo "Using commnd: $CMD"
echo "Using container script restart policy: $RESTART_POLICY"
echo "======================================================="
echo " "
echo " "

if [ "" = "$COMMAND_WORKDIR" ] || [ "" = "$CMD" ]; then
	echo "Unable to parse COMMAND workdir and/or command: empty!!"
	exit 1
fi

if [ "yes" != "$RESTART_POLICY" ]; then
	if [ -e /root/.command-complete ]; then
		if [ "yes" = "$(cat /root/.command-complete)" ]; then
			echo "Restart policy disabled and script already executed!!"
			echo "Exit!!"
			exit 0
		fi
	fi
fi

echo "Changing for wordir: $COMMAND_WORKDIR ..."
cd ${COMMAND_WORKDIR}
echo "Staring command ..."
eval "${CMD}"
if [ -e /root ]; then
	echo "yes" > /root/.command-complete
fi
echo "COMMAND Complete!!"