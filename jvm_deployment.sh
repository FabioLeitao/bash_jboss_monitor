#!/bin/bash
COMANDO=$0
ARGUMENTO=$1
FLAG=$2
CONTADOR=0
QUAL=`hostname -s`

JBCLI="/home/sc-tos-app/appServer_TOSP/bin/jboss-cli.sh"
JBCMD="/deployment=tosp.war:read-resource(include-runtime=true)"
IPCLI="/usr/sbin/ip"
GREPCLI="/usr/bin/grep"
AWKCLI="/usr/bin/awk"
SELFIP=`${IPCLI} ad | ${GREPCLI} -A 2 UP | ${GREPCLI} eth0 | ${GREPCLI} inet | ${AWKCLI} -F"/" '{printf $1}' | ${AWKCLI} '{printf $2}'`
#DISPONIVEL=`/home/sc-tos-app/appServer_TOSP/bin/jboss-cli.sh --connect --controller=${IP}:9990 --commands="/subsystem=datasources/data-source=tosp/statistics=pool:read-resource(include-runtime=true)" -u=adminTosp -p=Tosp@2021 | ${GREPCLI} -i available | ${AWKCLI} -F" " {'printf $3 '} | ${AWKCLI} -F"," {'printf $1'} `

function check_service_(){
        jBossPool=false
	DEPLOY=`${JBCLI} --connect --controller=${SELFIP}:9990 --commands="${JBCMD}" -u=adminTosp -p=Tosp@2021 | ${GREPCLI} -v time | ${GREPCLI} "enabled" | ${AWKCLI} '{printf $3}' | ${AWKCLI} -F"," '{printf $1}'`
	ULTIMA=$?
	if [ ${ULTIMA} -ne 0 ] ; then
		echo "4:502:ERROR - Connections invalid no jBoss @${QUAL}."    # returncode 4 = Protocol Error - put sensor in DOWN status
		die_ ;
	else
		if [ ${DEPLOY} == "connect" ] || [ ${DEPLOY} == "" ] ; then		
			echo "5:404:ERROR - nao contou o Pool no jBoss @${QUAL}."    # returncode 5 = Content Error - put sensor in DOWN status
			die_ ;
		else
			jBossPool=true
			if [ ${DEPLOY} == "true" ] ; then
				echo "0:200:OK - Deploy do TOSP.WAR completo e disponível no jBoss @${QUAL}."    # returncode 0 = OK - put sensor in OK status
			else
				echo "2:404:ERROR - Deploy do TOSP.WAR incompleta ou indisponível no jBoss @${QUAL}."    # returncode 2 = ERROR - put sensor in DOWN status
				exit 2
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
