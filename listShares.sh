#!/bin/bash

# Author: Jason Brewer
# Version 1.0.0
# Written to to list shares, test for anonymous login, and run multiple rpcclient commands

# Sets color or NOTE to BOLD RED
REDNOTE='\033[1;31m'
NOCOLOR='\033[0m'

function warning {

	echo -e "\n${REDNOTE}Please run the 'parser.sh' script to generate a lists of hosts, which will be found under their respective directory\n${NOCOLOR}"
	exit

}

# Usage Menu | More functionality can be added to further simplify enumeration
function Usage {

	echo -e "\nUsage: ${0##*/} \n"
	echo -e "\n${REDNOTE}[NOTE]${NOCOLOR}\tUse the accompanying script 'parser.sh' to generate the lists of hosts found under each corresponding directory"
	echo -e "\t${0##*/} -e <Use this flag to use enum4linux to enumerate Windows and Samaba systems given a list of hosts>"
	echo -e "\t${0##*/} -f <Use this flag against a file containing a list of hosts to test for anonymous login>"
	echo -e "\t${0##*/} -H <Use this flag against a single IP to test for anonymous login>"
	echo -e "\t${0##*/} -r <Use this flag to use rpcclient running different commands for enumeration>"

}

# Function to test for anonymous login on a single system
# -H flag
function SAMBA_Anonymous {

	if [[ ! -d sambaHosts ]] || [[ ! -d smbHosts ]]
	then
	warning
	else
	echo -e "\nTesting $HOST\n" | tee -a sambaHosts/Anonymouslogin.txt ; smbclient -L $HOST <<< anonymous | tee -a sambaHosts/Anonymouslogin.txt
	fi

}

# Function to test for anonymous login give a file containing a list of hosts
# -f flag
function SAMBA_Anonymous_File {

	if [[ ! -d sambaHosts ]] || [[ ! -d smbHosts ]]
	then
	warning
	else
	touch sambaHosts/Anonymouslogins.txt smbHosts/Anonymouslogins.txt ; for ip in $(cat $FILE | cut -d"/" -f 1 | uniq); do echo -e "Trying $ip\n" ; timeout 4 smbclient -L $ip <<< anonymous ; echo -e "\n###########################\n"; done | tee -a sambaHosts/Anonymouslogins.txt | tee -a smbHosts/Anonymouslogins.txt 
	fi

}

# Function uses enum4linux to enumerate Windows and Samba Systems
# -e flag
function ENUM4Linux {

	if [[ ! -d sambaHosts ]] || [[ ! -d smbHosts ]]
	then
	warning
	else
	for ip in $(cat $FILE | cut -d"/" -f 1 | uniq); do echo -e "Trying $ip\n" ; timeout 4 enum4linux -a $ip ; echo -e "\n###########################\n" ; done | tee -a sambaHosts/enum4linuxEnumeration.txt | tee -a smbHosts/enum4linuxEnumeration.txt
	fi

}

# Function use rpcclient running multiple commands to run against Samba/SMB systems
# -r flag
function RPC {

	CMDS=("enumprivs" "querydominfo" "enumdomgroups" "enumdomains" "lsaquery"
	"dsroledominfo" "dsenumdomtrusts" "enumtrust" "lsaenumsid" "netshareenumall"
	"ntsvcs_getversion" "srvinfo")

	if [[ ! -d sambaHosts ]] || [[ ! -d smbHosts ]]
	then
	warning
	else
	cat $FILE | cut -d"/" -f 1 | uniq | while read ip1 ip2
	do
		prevIP=$ip2
		if [[ $ip1 == $ip2 ]]
		then
		continue
		else
		echo -e "Connecting to: $ip1\n" | tee -a sambaHosts/rpcclientResults.txt | tee -a smbHosts/rpcclientResults.txt; for cmd in "${CMDS[@]}" ; do echo -e "Command: $cmd\n" ; rpcclient -U "" -N $ip1 <<< $cmd ; echo -e "\n###########################\n" ; done | tee -a sambaHosts/rpcclientResults.txt | tee -a smbHosts/rpcclientResults.txt
		fi
		
	done
		
	#for ip in $(cat $FILE | cut -d"/" -f 1); do echo -e "Connecting to: $ip\n"; for cmd in "${CMDS[@]}" ; do echo -e "Command: $cmd\n" ; rpcclient -U "" -N $ip <<< $cmd ; echo -e "\n###########################\n" ; done ; done | tee -a sambaHosts/rpcclientResults.txt | tee -a smbHosts/rpcclientResults.txt

	fi

}

while getopts :e:f:H:p:r: args ; do

	HOST=""
	FILE=""

	case ${args} in 

		e)
			FILE=$OPTARG
			ENUM4Linux
			;;

		f)
			FILE=$OPTARG
			SAMBA_Anonymous_File
			;;	

		H)
			HOST=$OPTARG
			SAMBA_Anonymous
			;;
		
		r)
			FILE=$OPTARG
			RPC
			;;

		*)
			Usage
			;;

	esac
done
			
	
	
