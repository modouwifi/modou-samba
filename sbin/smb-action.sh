#!/bin/sh
CURDIR=$(cd $(dirname $0) && pwd)
PIDFILE_SET="$CURDIR/../custom_set.pid"
PIDFILE="$CURDIR/../custom.pid"
NEXTCONF="$CURDIR/../conf/next.conf"

smb_config()
{
    rm $NEXTCONF 1>/dev/null 2>&1
    $CURDIR/../sbin/smb-tp.sh config
    $CURDIR/../sbin/smb-tp.sh flush
    if [ -f $PIDFILE ]; then
        pid=`cat $PIDFILE 2>/dev/null`;
        kill -SIGUSR1 $pid >/dev/null 2>&1;
    fi
    custom $CURDIR/../conf/samba-custom-set.conf&
    echo $! > $PIDFILE_SET
    return 0;
}

smb_flush()
{
    $CURDIR/../sbin/smb-tp.sh flush
    if [ -f $PIDFILE ]; then
        pid=`cat $PIDFILE 2>/dev/null`;
        kill -SIGUSR1 $pid >/dev/null 2>&1;
    fi
    return 0;
}

smb_next()
{
    $CURDIR/../sbin/smb-tp.sh config
    nextcountfile=`cat $NEXTCONF`;
    if [ "${nextcountfile}" == "0" ]; then
        $CURDIR/../sbin/smb-tp.sh flush
        if [ -f $PIDFILE ]; then
            pid=`cat $PIDFILE 2>/dev/null`;
            kill -SIGUSR1 $pid >/dev/null 2>&1;
        fi
        if [ -f $PIDFILE_SET ]; then
            pid=`cat $PIDFILE_SET 2>/dev/null`;
            kill -9 $pid >/dev/null 2>&1;
        fi
    else
        if [ -f $PIDFILE_SET ]; then
            pid=`cat $PIDFILE_SET 2>/dev/null`;
            kill -SIGUSR1 $pid >/dev/null 2>&1;
        fi
    fi
    return 0;
}

smb_openmd()
{
    $CURDIR/../sbin/smb-tp.sh 'set' '1' 'matrix' 'guest'
    if [ -f $PIDFILE_SET ]; then
        pid=`cat $PIDFILE_SET 2>/dev/null`;
        kill -SIGUSR1 $pid >/dev/null 2>&1;
    fi
    return 0;
}

smb_passwd()
{
    # touch a tmp config file
    echo "yonghuming: " > $CURDIR/../conf/config.tmp
    echo "mima: " >> $CURDIR/../conf/config.tmp
    generate-config-file $CURDIR/../conf/config.tmp
    if [ "$?" != "0" ]; then
        return 0
    fi
    username=`head -n 1 $CURDIR/../conf/config.tmp | cut -d ' ' -f2-`;
    passwd=`head -n 2 $CURDIR/../conf/config.tmp | tail -n 1 | cut -d ' ' -f2-`;
    $CURDIR/../sbin/smb-tp.sh 'set' '2' $passwd $username
    if [ -f $PIDFILE_SET ]; then
        pid=`cat $PIDFILE_SET 2>/dev/null`;
        kill -SIGUSR1 $pid >/dev/null 2>&1;
    fi
    return 0;
}

smb_tp_start()
{
    $CURDIR/../sbin/smb-tp.sh flush
    custom $CURDIR/../conf/samba-custom.conf 1>/dev/null 2>&1 &
    echo $! > $PIDFILE
    return 0;
}

smb_server_start()
{
    $CURDIR/../init start
    $CURDIR/../sbin/smb-tp.sh flush
    if [ -f $PIDFILE ]; then
        pid=`cat $PIDFILE 2>/dev/null`;
        kill -SIGUSR1 $pid >/dev/null 2>&1;
    fi
    return 0;
}

smb_server_stop()
{
    $CURDIR/../init stop
    $CURDIR/../sbin/smb-tp.sh flush
    if [ -f $PIDFILE ]; then
        pid=`cat $PIDFILE 2>/dev/null`;
        kill -SIGUSR1 $pid >/dev/null 2>&1;
    fi
    return 0;
}


# main
case "$1" in
    "flush")
        smb_flush;
        exit 0;
        ;;
    "config")
        smb_config;
        exit 0;
        ;;
    "next")
        smb_next;
        exit 0;
        ;;
    "openmd")
        smb_openmd;
        exit 0;
        ;;
    "passwd")
        smb_passwd;
        exit 0;
        ;;
    "tpstart")
        smb_tp_start;
        exit 0;
        ;;
    "serverstart")
        smb_server_start;
        exit 0;
        ;;
    "serverstop")
        smb_server_stop;
        exit 0;
        ;;
    *)
        echo "nothing"
        exit 0;
        ;;
esac
