#!/bin/bash
COMANDO=$0
ARGUMENTO=$1
FLAG=$2
CONTADOR=0
QUAL=`hostname -s`

JBCLI="/home/sc-tos-app/appServer_TOSP/bin/jboss-cli.sh"
JBCMD="/core-service=platform-mbean/type=memory:read-attribute(name=heap-memory-usage)"
IPCLI="/usr/sbin/ip"
GREPCLI="/usr/bin/grep"
AWKCLI="/usr/bin/awk"
SELFIP=`${IPCLI} ad | ${GREPCLI} -A 2 UP | ${GREPCLI} eth0 | ${GREPCLI} inet | ${AWKCLI} -F"/" '{printf $1}' | ${AWKCLI} '{printf $2}'`

function check_service_(){
        jBossWReqs=false
	CHEAP=`${JBCLI} --connect --controller=${SELFIP}:9990 --commands="${JBCMD}" -u=adminTosp -p=Tosp@2021 | ${GREPCLI} "committed" | awk '{printf $3}' | ${AWKCLI} -F"L" '{printf $1}'`
	ULTIMA=$?
	if [ ${ULTIMA} -ne 0 ] ; then
		echo "4:502:ERROR - Connections invalid no jBoss @${QUAL}."    # returncode 4 = Protocol Error - put sensor in DOWN status
		die_ ;
	else
		if [ ${CHEAP} == "connect" ] || [  ${CHEAP} == "" ] ; then		
			echo "5:404:ERROR - nao contou o Pool no jBoss @${QUAL}."    # returncode 5 = Content Error - put sensor in DOWN status
			die_ ;
		else
			jBossWReqs=true
			if [ ${CHEAP} -gt 55000000000 ] ; then
				echo "2:${CHEAP}:ERROR - Heap commited quase estourado no jBoss @${QUAL}."    # returncode 2 = ERROR - put sensor in DOWN status
				exit 2
			else
				if [ ${CHEAP} -gt 42000000000 ] ; then
					echo "1:${CHEAP}:WARNING - Heap commited enchendo no jBoss @${QUAL}."    # returncode 1 = WARNING - put sensor in Warn status
					exit 1
				else
					echo "0:${CHEAP}:OK - Heap commited normal no jBoss @${QUAL}."    # returncode 0 = OK - put sensor in OK status
				fi
			fi
		fi
	fi
}

function die_(){
        exit 999
}

function preparation_(){
	if [ ! -x ${JBCLI} ] ; then
                echo "3:500:ERROR - command jboss-cli not found."   # returncode 3 = System Error - put sensor in DOWN status
                die_ ;
        fi
}

#function atua_no_flag_(){
#}

function ajuda_(){
        echo "2:500:ERROR - Usage: ${COMMAND} [-h|--help]" >&2 ;  # returncode 2 = Error - put sensor in DOWN status
        die_ ;
}

function main_(){
#        atua_no_flag_ ;
        preparation_;
        check_service_;
}

main_ ;
exit 0
