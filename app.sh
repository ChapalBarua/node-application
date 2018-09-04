#!/bin/bash


# The directory in which your application is installed
APPLICATION_DIR="/var/lib/jenkins/workspace/node"



# Storing the current time

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`


# ***********************************************
OUT_FILE="${APPLICATION_DIR}"/log/"${YEAR}"-"${MONTH}"-"${DAY}"-out.log
RUNNING_PID="${APPLICATION_DIR}"/RUNNING_PID
# ***********************************************

# colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

echoRed() { echo -e "${red}$1${reset}"; }
echoGreen() { echo -e "${green}$1${reset}"; }
echoYellow() { echo -e "${yellow}$1${reset}"; }

# Check whether the application is running.
# The check is pretty simple: open a running pid file and check that the process
# is alive.
isrunning() {
  # Check for running app

  if [ -f "$RUNNING_PID" ]; then
 proc=$(cat $RUNNING_PID);
   if /bin/ps --pid $proc 1>&2;
 then
	return 0
    fi
  fi
  return 1
}

start() {
  if isrunning; then
    echoYellow "The application is already running"
    return 0
  fi

  nohup node $APPLICATION_DIR/bin/www
  echo $! > ${RUNNING_PID}

  if isrunning; then
    echoGreen "Application started"
    exit 0
  else
    echoRed "The Application has not started - check log"
    exit 3
  fi
}

restart() {
  echo "Restarting Application"
  stop
  start
}

stop() {
  echoYellow "Stopping  Application"
  if isrunning; then
    kill `cat $RUNNING_PID`
    while isrunning; do
      sleep 1
    done
    rm $RUNNING_PID
  fi
}

status() {
  if isrunning; then
    echoGreen "Application is running"
  else
    echoRed "Application is either stopped or inaccessible"
  fi
}

case "$1" in
start)
    start
;;

status)
   status
   exit 0
;;

stop)
    if isrunning; then
        stop
        exit 0
    else
        echoRed "Application not running"
        exit 3
    fi
;;

restart)
    stop
    start
;;

*)
    echo "Usage: $0 {status|start|stop|restart}"
    exit 1
esac


