#!/bin/bash
COMANDO=$0
ARGUMENTO=$1
FLAG=$2
CONTADOR=0
QUAL=`hostname -s`

JBCLI="/home/sc-tos-app/appServer_TOSP/bin/jboss-cli.sh"
JBCMD="read-attribute server-state"
IPCLI="/usr/sbin/ip"
GREPCLI="/usr/bin/grep"
AWKCLI="/usr/bin/awk"
SELFIP=`${IPCLI} ad | ${GREPCLI} -A 2 UP | ${GREPCLI} eth0 | ${GREPCLI} inet | ${AWKCLI} -F"/" '{printf $1}' | ${AWKCLI} '{printf $2}'`

function check_service_(){
        jBossIsRunning=false
	STAT=`${JBCLI} --connect --controller=${SELFIP}:9990 --commands="${JBCMD}" -u=adminTosp -p=Tosp@2021`
	ULTIMA=$?
	if [ ${ULTIMA} -eq 0 ] ; then
		if [ ${STAT} == "running" ] ;  then
			jBossIsRunning=true
			echo "0:200:OK - jBoss @${QUAL} is running."    # returncode 0 = OK - put sensor in OK status
		else
			echo "5:404:ERROR - jBoss @${QUAL} is not present or not running."    # returncode 5 = Content Error - put sensor in DOWN status
			exit 5
		fi
	else
		echo "4:502:ERROR - Connections invalid @${QUAL}."    # returncode 4 = Protocol Error - put sensor in DOWN status
		die_ ;
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
