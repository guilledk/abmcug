end=0

while [ $end -eq 0 ]; do
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
			echo "Grupos"
			read
			;;
		0)
			clear
			end=1
			;;
		*)
			clear
			echo "Opcion no identificada."
			read
			;;

	esac
done
