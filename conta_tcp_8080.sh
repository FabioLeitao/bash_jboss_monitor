#!/bin/bash
COMANDO=$0
ARGUMENTO=$1
FLAG=$2
CONTADOR=0
QUAL=`hostname -s`

JBCLI="/home/sc-tos-app/appServer_TOSP/bin/jboss-cli.sh"
JBCMD="/subsystem=datasources/data-source=tosp/statistics=pool:read-resource(include-runtime=true)"
SSCLI="/usr/sbin/ss"
WCCLI="/usr/bin/wc"
IPCLI="/usr/sbin/ip"
GREPCLI="/usr/bin/grep"
AWKCLI="/usr/bin/awk"
SELFIP=`${IPCLI} ad | ${GREPCLI} -A 2 UP | ${GREPCLI} eth0 | ${GREPCLI} inet | ${AWKCLI} -F"/" '{printf $1}' | ${AWKCLI} '{printf $2}'`


function check_service_(){
        jBossWeb=false
	CONN=`${SSCLI} -tn | ${GREPCLI} ESTAB | ${AWKCLI} '{print $4}' | ${GREPCLI} ${SELFIP}]:8080 | ${WCCLI} -l`
	ULTIMA=$?
	if [ ${ULTIMA} -ne 0 ] ; then
		echo "4:502:ERROR - Web connections invalid @${QUAL}."    # returncode 4 = Protocol Error - put sensor in DOWN status
		die_ ;
	else
		if [ ${CONN} == "connect" ] || [  ${CONN} == "" ] ; then		
			echo "5:404:ERROR - nao mediu as conexões web @${QUAL}."    # returncode 5 = Content Error - put sensor in DOWN status
			die_ ;
		else
			jBossWeb=true
			if [ ${CONN} -lt 1 ] ; then
				echo "0:${CONN}:ERROR - conexões web zeradas @${QUAL}."    # returncode 2 = ERROR - put sensor in DOWN status
				exit 2
			else
				if [ ${CONN} -lt 4 ] ; then
					echo "0:${CONN}:WARNING - conexões web baixas @${QUAL}."    # returncode 1 = WARNING - put sensor in Warn status
					exit 1
				else
					echo "0:${CONN}:OK - conexões web normais @${QUAL}."    # returncode 0 = OK - put sensor in OK status
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
