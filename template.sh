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
cmd=""

name=`basename $0`
pid_file="/var/run/$name.pid"
lockfile="/var/lock/subsys/$name"

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && ps `get_pid` > /dev/null 2>&1
}

start() {
  if is_running; then
      echo "Already started"
  else
      echo "Starting $name"
      daemon --user $user "$exec $pidfile"
      retval=$?

      if ! is_running; then
          echo "Unable to start, see $stdout_log and $stderr_log"
          exit 1
      fi

      touch $lockfile
      return $retval
  fi
}

stop() {

  if is_running; then
      echo -n "Stopping $name.."
      killproc -p $pidfile -d 10 $name
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
          if [ -f "$pid_file" ]; then
              rm "$pid_file"
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
    status -p $pidfile $name
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
      rh_status_q && exit 0
      $1
      ;;
    stop)
      rh_status_q && exit 0
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
