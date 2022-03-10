#!/bin/bash

# Author: Jason Brewer
# Written to quickly parse out data from nmap files
# Version 1.0.2

# Sets color or NOTE to BOLD RED
REDNOTE='\033[1;31m'
NOCOLOR='\033[0m'

# Help menu
function Usage {

	echo -e "\n${REDNOTE}[NOTE]${NOCOLOR} Every argument creates its own directory structure with a corresponding text file\n" 
	echo -e "Usage: ${0##*/} supply an argument to parse out relevant data\n"
	echo -e " -h				\tHelp Menu: dir = input directory"
	echo -e " -H		input dir	\tShow systems with open HTTP ports"
	echo -e " -S 		input dir	\tShow systems with open SSL/HTTPS ports"
	echo -e " -k		input dir	\tShow systems with Kubernetes"
	echo -e " -l		input dir	\tShow systems with ldap"
	echo -e " -r 		input dir	\tShow systems running RDP"
	echo -e " -v		input dir 	\tShow systems running VNC"
	echo -e " -o-samba	input dir	\tShow systems running samaba"
	echo -e " -o-smb 	input dir	\tShow systems running smb"
	echo -e " -o-ssh 	input dir	\tShow systems using ssh"
	echo ""

}

# Global variable used in each function
fileWritten="\n[+++] File written to "

# Function to grab all HTTP servers 
function HTTP {

	httpDir="httpHosts"
	httpHosts="httpHostsFile.txt"
	if [[ -d $httpDir ]]
	then
	grep -Er "open +http" $inPutDir | grep -v "${0##*/}" | tee -a $PWD/$httpDir/$httpHosts
	elif [[ ! -d $httpDir ]]
	then
	grep -Er "open +http" $inPutDir >/dev/null
	if [ $? -eq 0 ]
	then
	# Get All IPs
	getHTTPHostIPs=$(grep -Er "open +http" $inputDir | grep -v '^./[a-zA-Z]' | awk -F"[/:]" '{print$1}' | sort | uniq)
	mkdir $httpDir ; touch $httpHosts
	grep -Er "open +http" $inPutDir | grep -v "${0##*/}" | grep -v '^./[a-zA-Z]' | tee -a $PWD/$httpHosts >/dev/null ; mv $PWD/$httpHosts $httpDir/
	echo -e $fileWritten $PWD/$httpDir/$httpHosts
	echo "$getHTTPHostIPs" | tee -a $PWD/$httpDir/httpHostIPs.txt > /dev/null 
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi
	fi

}

# Function to grab all SSL servers
function SSL {

	sslDir="sslHosts"
	sslHosts="sslHostsFile.txt"
	if [[ -d $sslDir ]]
	then
	grep -Er "open +ssl" $inPutDir | grep -v "${0##*/}"* | tee -a $PWD/$sslDir/$sslHosts
	elif [[ ! -d $sslDir ]]
	then
	grep -Er "open +ssl" $inPutDir | grep -v "${0##*/}"* >/dev/null
	if [ $? -eq 0 ]
	then
	# Get All IPs
	getSSLHosts=$(grep -Er "open +ssl" $inPutDir | grep -v "${0##*/}"* | grep -v '^./[a-zA-Z]' | awk -F"[/:]" '{print $2}' | sort | uniq)
	mkdir $sslDir ; touch $sslHosts
	grep -Er "open +ssl" $inPutDir | grep -v "${0##*/}"* | grep -v '^./[a-zA-Z]' | tee -a $PWD/$sslHosts >/dev/null; mv $PWD/$sslHosts $sslDir/ 
	echo -e $fileWritten $PWD/$sslDir/$sslHosts
	echo "$getSSLHosts" | tee -a $PWD/$sslDir/sslHostIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi
	
	fi

}

# Function to grab all Samba Servers
function SAMBA {

	sambaDir="sambaHosts"
	sambaHosts="sambaHostsFile.txt"
	if [[ -d $sambaDir ]]
	then
	grep -Er "ttl +[0-9][0-9] Samba smbd" $inputDir | grep -v "${0##*/}" || grep -Er "ttl +[0-9][0-9][0-9] Samba smbd" $inputDir | grep -v "${0##*/}" | tee -a $PWD/$sambaDir/$sambaHosts
	elif [[ ! -d $sambaDir ]]
	then
	grep -Er "ttl +[0-9]{2,3} Samba smbd" $inputDir | grep -v "${0##*/}" >/dev/null
	if [ $? -eq 0 ]
	then
	# Get All IPs
	getSambaIPs=$(grep -Er "ttl +[0-9]{2,3} Samba smbd" . | grep -v '^./[a-zA-Z]' | awk -F"[/:]" '{print $2}' | sort | uniq)
	mkdir $sambaDir ; touch $sambaHosts
	grep -Er "ttl +[0-9]{2,3} Samba smbd" $inputDir | grep -v "${0##*/}" | grep -v $sambaHosts | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | tee -a $PWD/$sambaHosts >/dev/null ; mv $PWD/$sambaHosts $sambaDir/ 2>/dev/null #|| grep -Er "ttl +[0-9][0-9][0-9] Samba smbd" $inputDir | grep -v "${0##*/}" | grep -v $sambaHosts | grep -v '^./[a-zA-Z]' | tee -a $PWD/$sambaHosts >/dev/null ; mv $PWD/$sambaHosts $sambaDir/ 2>/dev/null
	echo -e $fileWritten $PWD/$sambaDir/$sambaHosts
	echo "$getSambaIPs" | tee -a $PWD/$sambaDir/sambaHostIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi
	fi

}

# Function to grab all SMB servers
function SMB {

	smbDir="smbHosts"
	smbHosts="smbHostsFile.txt"
	if [[ -d $smbDir ]]
	then
	grep -r "445/tcp" $inputDir | grep -v '^./[a-z]*' | tee -a $PWD/$smbDir/$smbHosts
	elif [[ ! -d $smbDir ]]
	then
	grep -r "445/tcp" $inputDir >/dev/null
	if [ $? -eq 0 ]
	then
	# Get ALL IPs
	getSMBHostIPs=$(grep -r "445/tcp" $inputDir | grep -v '^[a-zA-Z]' | grep -v '^./[a-zA-Z]' | awk -F"[/:]" '{print $1}' | sort | uniq)
	mkdir $smbDir ; touch $smbHosts
 	grep -r "445/tcp" $inputDir | grep -v "${0##*/}" | grep -v $smbHosts | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | tee -a $PWD/$smbHosts >/dev/null ; mv $PWD/$smbHosts $smbDir/
	echo -e $fileWritten $PWD/$smbDir/$smbHosts
	echo "$getSMBHostIPs" | tee -a $PWD/$smbDir/smbHostIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi
	fi	
	

}

# Function to grab all RDP servers
function RDP {

	rdpDIR="rdpHosts"
	rdpHosts="rdpHostsFile.txt"
	if [[ -d $rdpDIR ]]
	then
	grep -Er "open +ms-wbt-server" $inPutDir | grep -v "${0##*/}" | tee -a $PWD/$rdpDIR/$rdpHosts
	elif [[ ! -d $rdpDir ]]
	then
	grep -Er "open +ms-wbt-server" $inPutDir | grep -v "${0##*/}" >/dev/null
	if [ $? -eq 0 ]
	then
	# Get All IPs
	getrdpHostsIPs=$(grep -Er "open +ms-wbt-server" $inPutDir | grep -v "${0##*/}" | grep -v $rdpHosts | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | awk -F"[/:]" '{print $2}' | sort | uniq)
	mkdir $rdpDIR ; touch $rdpHosts
	grep -Er "open +ms-wbt-server" $inPutDir | grep -v "${0##*/}" | grep -v $rdpHosts | grep -v '^./[a-zA-Z]' | tee -a $PWD/$rdpHosts >/dev/null ; mv $PWD/$rdpHosts $rdpDIR/
	echo -e $fileWritten $PWD/$rdpDIR/$rdpHosts
	echo "$getrdpHostsIPs" | tee -a $PWD/$rdpDIR/rdpHostsIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	exit
	fi
	fi	

}

# Function to grab all SSH servers
function SSH {

	sshDIR="sshHosts"
	sshHosts="sshHostsFile.txt"
	if [[ -d $sshDIR ]]
	then
	grep -Er "open +ssh" $inputDir | grep -v "${0##*/}" | tee -a $PWD/$sshDIR/$sshHosts 
	elif [[ ! -d $sshDir ]] 
	then
	grep -Er "open +ssh" $inputDir | grep -v "${0##*/}" >/dev/null
	if [ $? -eq 0 ]
	then
	# Get ALL IPs
	getsshHostsIPs=$(grep -Er "open +ssh" $inputDir | grep -v "${0##*/}" | grep -v $sshHosts | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | awk -F "[/:]" '{print $1}' | sort | uniq)
	mkdir $sshDIR ; touch $sshHosts
	grep -Er "open +ssh" $inputDir | grep -v "${0##*/}" | grep -v $sshHosts | grep -v '^./[a-zA-Z]' | tee -a $PWD/$sshHosts >/dev/null ; mv $PWD/$sshHosts $sshDIR/
	echo -e $fileWritten $PWD/$sshDIR/$sshHosts
	echo "$getsshHostsIPs" | tee -a $PWD/$sshDIR/sshHostsIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi
	fi

}

# Function to grab all Kuberentes 
function KUBE {

	kubeDir="kubeHosts"
	kubeHosts="kubeHostsFile.txt"
	if [[ -d $kubeDir ]]
	then
	ls $inputDir | grep -irE "DNS:*kube" | awk -F"[/:]" '{print $2}' | cut -d"." -f 1-4 | sort | uniq  | tee -a  $PWD/$kubeDir/$kubeHosts
	elif [[ ! -d $kubeDir ]]
	then
	grep -irE "DNS:*kube" $inputDir | awk -F"[/:]" '{print $2}' | cut -d"." -f 1-4 | sort | uniq >> /tmp/kube.txt || grep -irE "kube" | awk -F"[/:]" '{print $2}' | grep -v "${0##*/}" | uniq >> /tmp/kube.txt
	CNT=$(wc -l < /tmp/kube.txt)
	if [ $CNT -ne 0 ]
	then 
	mkdir $kubeDir ; touch $kubeHosts
	ls $inputDir | grep -irE "DNS:*kube" | awk -F"[/:]" '{print $2}' | cut -d"." -f 1-4 | sort | uniq | tee -a  $PWD/$kubeHosts >/dev/null ; mv $PWD/$kubeHosts $kubeDir/ 2>/dev/null || grep -irE "kube" $inputDir | awk -F"[/:]" '{print $2}' | sort | uniq  | tee -a  $PWD/$kubeHosts >/dev/null ; mv $PWD/$kubeHosts $kubeDir/ 2>/dev/null
	echo -e $fileWritten $PWD/$kubeDir/$kubeHosts
	else
	echo -e "\n[!!!] Nothing Found\n"
	rm /tmp/kube.txt
	fi
	fi
	
}

# Function to grab all VNC servers
function VNC {

	vncDir="vncHosts"
	vncHosts="vncHostsFile.txt"
	if [[ -d $vncDir ]]
	then
	grep -Er "open +vnc" $inPutDir | grep -v "${0##*/}" | tee -a $PWD/$vncDir/$vncHosts
	elif [[ ! -d $vncDir ]]
	then
	grep -Er "open +vnc" $inPutDir | grep -v "${0##*/}" >/dev/null
	if [ $? -eq 0 ]
	then
	# Get ALL IPs
	getvncHostIPs=$(grep -Er "open +vnc" $inPutDir | grep -v "${0##*/}" | grep -v $vncHosts | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | awk -F"[/:]" '{print $2}' | sort | uniq )	
	mkdir $vncDir ; touch $vncHosts
	grep -Er "open +vnc" $inPutDir | grep -v "${0##*/}" | grep -v $vncHosts | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | tee -a $PWD/$vncHosts >/dev/null; mv $PWD/$vncHosts $vncDir/
	echo -e $fileWritten $PWD/$vncDir/$vncHosts
	echo "$getvncHostIPs" | tee -a $PWD/$vncDir/vncHostIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi	
	fi
}

# Function to grab all LDAP
function LDAP {

	ldapDir="ldapHosts"
	ldapHosts="ldapHostsFile.txt"
	if [[ -d $ldapDir ]]
	then
	egrep -re "open +ldap" -re "open +ssl/ldap" $inPutDir | grep -v "${0##*/}" | tee -a $PWD/$ldapDir/$ldapHosts
	elif [[ ! -d $ldapDir ]]
	then
	egrep -re "open +ldap" -re "open +ssl/ldap" $inPutDir | grep -v "${0##*/}" >/dev/null
	if [ $? -eq 0 ]
	then
	# GET All IPs
	getldapHostIPs=$(egrep -re "open +ldap" -re "open +ssl/ldap" $inPutDir | grep -v "${0##*/}" | grep -v '^./[a-zA-Z]' | grep -v '^[a-zA-Z]' | awk -F"[/:]" '{print $2}' | sort -r | uniq )
	mkdir $ldapDir ; touch $ldapHosts
	egrep -re "open +ldap" -re "open +ssl/ldap" $inPutDir | grep -v "${0##*/}" | grep -v '^./[a-zA-Z]' | tee -a $PWD/$ldapHosts >/dev/null; mv $PWD/$ldapHosts $ldapDir/
	echo -e $fileWritten $PWD/$ldapDir/$ldapHosts
	echo "$getldapHostIPs" | tee -a $PWD/$ldapDir/ldapHostIPs.txt > /dev/null
	else
	echo -e "\n[!!!] Nothing Found\n"
	fi	
	fi

}

cmdVALUES=()
for values in ${@}; do cmdVALUES+=("$values") ; done

while getopts :H:S:k:l:o:r:v: arg ; do 

	inPutDir=""
	case ${arg} in

		H)	inPutDir=$OPTARG
			HTTP
			;;

		S)      inPutDir=$OPTARG 
			SSL
			;;

		k)
			inPutDir=$OPTARG
			KUBE
			;;
		
		l)
			inPutDir=$OPTARG
			LDAP
			;;

		r)      inPutDir=$OPTARG 
			RDP
			;;

		o)      inPutDir=$OPTARG 
			if [[ "${cmdVALUES[-2]}" =~ "-o-ssh" ]]
			then
			SSH
			elif [[ "${cmdVALUES[-2]}" =~ "-o-smb" ]]
			then
			SMB
			elif [[ "${cmdVALUES[-2]}" =~ "-o-samba" ]]
			then
			SAMBA
			fi
			;;
		
		v)
			inPutDir=$OPTARG
			VNC
			;;

		*)
			Usage

	esac
done

