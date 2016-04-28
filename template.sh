#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO
# Source function library.
. /etc/rc.d/init.d/functions

user=""
exec=""
name=`basename $0`

pidfile="/var/run/squirro/youtube/youtubed.pid"
lockfile="/var/lock/subsys/$name"

is_running() {
    if [[ -f "$pidfile" ]]; then
	ps `cat $pidfile` > /dev/null 2>&1
	return  0
     else
        return 1
     fi
}

start() {

  [ -x $exec ] || exit 5

  if is_running; then
      echo "Already started"
  else
      echo -n "Starting $name"
      daemon --user $user "$exec $pidfile"
      retval=$?

      [ $retval -eq 0 ] && touch $lockfile

      sleep 0.30

      if ! is_running; then
          echo "Unable to start"
          exit 1
      fi

      touch $lockfile
  fi
  echo ""
  return $retval
}

stop() {
  if is_running; then
      echo -n "Stopping $name.."
      killproc -p $pidfile -d 10 $exec
      retval=$?

      for i in {1..10}
      do
          if ! is_running; then
              break
          fi

          echo -n "."
          sleep 1
      done
      echo

      if is_running; then
          echo "Not stopped; may still be shutting down or shutdown may have failed"
          exit 1
      else
          echo "Stopped"
          if [ -f "$pidfile" ]; then
              rm "$pidfile"
              rm "$lockfle"
          fi
      fi
  else
      echo "Not running"
  fi
  return $retval
}

restart () {
  $0 stop
  if is_running; then
      echo "Unable to stop, will not attempt to start"
      exit 1
  fi
  $0 start
}

status () {
  if is_running; then
      echo "Running"
  else
      echo "Stopped"
      exit 1
  fi
}

reload() {
    false
}

rh_status() {
    echo status
    status -p $pidfile $name
}

rh_status_q() {
   rh_status >/dev/null 2>&1
}

case "$1" in
    start)
      start
      rh_status_q && exit 0
      $1
      ;;
    stop)
      rh_status_q || exit 0
      $1
      ;;
    restart)
      $1
      ;;
    status)
      rh_status
      ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
