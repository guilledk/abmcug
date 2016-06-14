#!/bin/sh

while true; do
	clear
	cat menus/main
	read -p "~$ " op

	case $op in

		1)
			clear
			./usr.sh
			;;
		2)
			clear
			./grp.sh
			read
			;;
		0)
			clear
			break
			;;
		*)
			clear
			echo "Opcion no identificada."
			read
			;;

	esac
done
