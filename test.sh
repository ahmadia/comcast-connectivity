#!/bin/bash

GW=$(netstat -nr | grep default | head -1 | awk '/default/ { print $2 }')
checkdns=$(cat /etc/resolv.conf | awk '/nameserver/ {print $2}' | awk 'NR == 1 {print; exit}')
checkdomain=google.com

#some functions

function portscan
{
   echo "Starting port scan of $checkdomain port 80"; 
  if nc -z -w 2 $checkdomain  80; then
     echo "Port scan good, $checkdomain port 80 available"; 
  else
    echo "Port scan of $checkdomain port 80 failed."
  fi
}

function pingnet
{
  #Google has the most reliable host name. Feel free to change it.
   echo "Pinging $checkdomain to check for internet connection." && echo; 
  ping -c 4 -t 3 $checkdomain

  if [ $? -eq 0 ]
    then
       echo && echo "$checkdomain pingable. Internet connection is most probably available."&& echo ; 
      #Insert any command you like here
    else
      echo && echo "Could not establish internet connection. Something may be wrong here." >&2
      #Insert any command you like here
#      exit 1
  fi
}

function pingdns
{
  #Grab first DNS server from /etc/resolv.conf
   echo "Pinging first DNS server in resolv.conf ($checkdns) to check name resolution" && echo; 
  ping -c 4 -t 3 $checkdns
    if [ $? -eq 0 ]
    then
       echo && echo "$checkdns pingable. Proceeding with domain check."; 
      #Insert any command you like here
    else
      echo && echo "Could not establish internet connection to DNS. Something may be wrong here." >&2
      #Insert any command you like here
#     exit 1
  fi
}

function httpreq
{
   echo && echo "Checking for HTTP Connectivity"; 
  case "$(curl -s --max-time 2 -I $checkdomain | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23])  echo "HTTP connectivity is up";;
  5) echo "The web proxy won't let us through"; exit 1;;
  *)echo "Something is wrong with HTTP connections. Go check it."; exit 1;
  esac
#  exit 0
}


#Ping gateway first to verify connectivity with LAN
 echo "Pinging gateway ($GW) to check for LAN connectivity" && echo; 
if [ "$GW" = "" ]; then
    echo "There is no gateway. Probably disconnected..."; 
#    exit 1
fi

ping -c 4 -t 3 $GW

if [ $? -eq 0 ]
then
   echo && echo "LAN Gateway pingable. Proceeding with internet connectivity check."; 
  pingdns
  pingnet
  #portscan
  httpreq
  exit 0
else
  echo && echo "Something is wrong with LAN (Gateway unreachable)"
  pingdns
  pingnet
  #portscan
  httpreq

  #Insert any command you like here
#  exit 1
fi


