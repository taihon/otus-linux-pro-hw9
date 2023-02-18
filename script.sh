#!/bin/bash

LOGFILE="access.log"
LOCKFILE="/var/run/myscript.lock"
if [ ! -f $LOCKFILE ]
then
    touch $LOCKFILE
fi
#get file descriptor of lockfile
exec {FD}<>$LOCKFILE
trap "flock --unlock $FD;exit $?" 0 1 2 3 13 15
if ! flock -x -w 0 $FD; then
    echo -e "Failed to obtain lock\nRunning multiple instances is prohibited"
    exit 1;
else
    echo -e "Lock acquired\n"
    for f in `ls ./modules`; do source ./modules/$f ; done
    TRACKFILE="/usr/local/myscript.counter"
    if [ ! -f $TRACKFILE ]
    then
        touch $TRACKFILE
        fromline=0
        echo $fromline > $TRACKFILE
    else
        alreadyread=$(head -n 1 $TRACKFILE)
        fromline=$(($alreadyread + 1))
    fi
    #imitate currently logging application
    #read between 40 and 110 rows per batch
    #to read till the end of file - set
    #readcnt="all"
    readcnt=$(( $RANDOM%70+40 ))
    input=$(cat $LOGFILE|read_from_line $fromline| \
        read_n_lines $readcnt)
    lines_in_input=$(echo "$input"|wc -l)
    words_in_input=$(echo "$input"|wc -w)
    toline=$(( $fromline + $lines_in_input ))
    if [ $words_in_input -eq 0 ];
    then
        toline=$(($fromline - 1))
    fi
    fromdate=$(echo "$input"|head -n 1| \
        awk 'BEGIN {FS="["};{print $2}'| \
        awk 'BEGIN {FS="]"};{print $1}')
    todate=$(echo "$input"|tail -n 1| \
        awk 'BEGIN {FS="["};{print $2}'| \
        awk 'BEGIN {FS="]"};{print $1}')
    if [ $words_in_input -eq 0 ]; 
    then
        exit 0;
    fi
    echo "reading from $fromline to $toline"
    mbody=$(cat <<-EOF
        `echo "1. Top IPs by request count: "`
        `echo "$input"|select_ips|group_count_sort_desc|flip_val_count|top_limit 5`
        `echo "2. Top URN by request count: "`
        `echo "$input"|select_urls|group_count_sort_desc|flip_val_count|top_limit 5`
        `echo "3. Errors: "`
        `echo "$input"|select_any_errors`
        `echo "4. HTTP status codes: "`
        `echo "$input"|get_status_codes|group_count_sort_desc|flip_val_count`
        `echo "report built on log messages from $fromdate to $todate"`
EOF
    )
    sleep 60 &
    wait $!
    echo "$mbody"
    echo $toline > $TRACKFILE
    exit 0
fi