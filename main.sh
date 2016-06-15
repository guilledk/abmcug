#!/bin/sh

. "$PWD/libabmc.sh"

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
			;;
		0)
			clear
			break
			;;
		*)
			echo "Opcion no identificada."
			read -p "$ENTER_CONTINUE" in
			;;

	esac
done
