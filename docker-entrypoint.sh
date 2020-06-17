#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "docker-entrypoint.sh {cmd} {arg1} ... {argN} ^^^ {cmd} {arg1} ... {argN}"
	echo "  {cmd}    				One of available commands (clone, script, command, mocked_data)"
	echo "  {arg1} ... {argN}		Command Arguments arg1 ... argN"
	echo "Any execution that will not be a command will be taken as shell command request"
}

function executeCommand() {
	ALEN=${#@}
	let SLEN=ALEN-1
	S_ARGS="${@: 2: $SLEN}"
	if [ "clone" = "$1" ]; then
		echo "CLONE REPO - executing: /root/scripts/clone-repo.sh $S_ARGS"
		bash -c "/root/scripts/clone-repo.sh $S_ARGS"  2> /dev/null
	elif [ "script" = "$1" ]; then
		echo "EXEC SCRIPT - executing: /root/scripts/run-script.sh $S_ARGS"
		bash -c "/root/scripts/run-script.sh $S_ARGS" 2> /dev/null
	elif [ "command" = "$1" ]; then
		echo "EXEC COMMAND - executing: /root/scripts/run-command.sh $S_ARGS"
		bash -c "/root/scripts/run-command.sh $S_ARGS" 2> /dev/null
	elif [ "sleep" = "$1" ]; then
		echo "EXEC COMMAND - sleep with arguments: $S_ARGS"
		if [ "infinity" == "$2" ] || [ "" == "$2" ]; then
			while (true); do
				sleep 365d
			done
		else
			sleep $2
		fi
	elif [ "mocked_data" = "$1" ]; then
		echo "EXEC COMMAND - mocked data at: /root/scripts/execute-api-calls.sh $S_ARGS"
		bash -c "/root/scripts/execute-api-calls $S_ARGS" 2> /dev/null
	else
		echo "RUN SHELL - executing: $@"
		eval "$@"
	fi
}

if [ $# -lt 1 ]; then
	echo "Insufficient arguments: $# < 1"
	echo -e "$(usage)"
	echo "Exit!!"
	exit 1
fi

if [ "yes" != "$RESTART_POLICY" ]; then
	if [ -e /root/.entrypoint-complete ]; then
		if [ "yes" = "$(cat /root/.entrypoint-complete)" ]; then
			echo "Restart policy disabled and script already executed!!"
			echo "Exit!!"
			exit 0
		fi
	fi
fi

ARGS=$@
INDEX=0
CMD="$@"
CMD_SEP='^^^'

if [[ $CMD =~ "$CMD_SEP" ]]; then
	IFS="$CMD_SEP"; for subCmd in $CMD; do
		if [ "" != "$subCmd" ]; then
			echo -e "$(eval "executeCommand $subCmd")"
		fi
	done
else
	echo -e "$(executeCommand $@)"
fi
if [ -e /root ]; then
	echo "yes" > /root/.entrypoint-complete
fi
echo "Complete!!"
exit 0