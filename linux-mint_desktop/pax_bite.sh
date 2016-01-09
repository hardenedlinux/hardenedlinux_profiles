#!/bin/bash

echo "=====================[ Add/delete PaX flags ]===================="
echo "###########################################################################"

echo " Monkey-coder: Shawn the R0ck,<citypw@gmail.com>"
echo " GPL'ed...."

echo " This is free software, and you are welcome to redistribute it
 under the terms of the GNU General Public License.  See LICENSE file
 for details about using this software."  

echo "###########################################################################"
echo "----------------------------------------------"
show_help()
{
	echo "$0 -h[help] -e[enable] -d[disable] -v[view] [PaX_file_list]"
	exit 1
}

enable_pax_flags()
{
while read line; do
	IFS=';' read -r BIN FLAGS <<< "$line"
	$PAXCTL -d $BIN
	$PAXCTL -C $BIN
	$PAXCTL -$FLAGS $BIN
done < $FILE
}

disable_pax_flags()
{
while read line; do
	IFS=';' read -r BIN FLAGS <<< "$line"
	$PAXCTL -d $BIN
done < $FILE
}

view_pax_flags()
{
while read line; do
	IFS=';' read -r BIN FLAGS <<< "$line"
	$PAXCTL -v $BIN
done < $FILE
}

FILE=$2
if [ ! -f $FILE ]; then
	echo "PaX flags file list not found!"
	exit 1
fi

PAXCTL=`which paxctl-ng`
if [ $? -eq 0 ]; then
	echo -e "*- elfix package:\e[92m OK\e[0m"
else
        echo -e "*- elfix package:\e[91m FAILED\e[0m, plz check..."
	exit 1
fi

while getopts "h?edv:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    e)  enable_pax_flags
        ;;
    d)  disable_pax_flags
        ;;
    v)  view_pax_flags
	;;
    esac
done



