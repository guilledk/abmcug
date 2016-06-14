#!/bin/sh
. "$PWD/libabmc.sh"

alta () {

	#groupadd
	#-g GID
	#-p passwd
	#-r grupo de sistema
	#group

	#group name
	while true; do
		read -p "Ingrese nombre del nuevo grupo UNIX: " grp_name
		if grep -q "^${grp_name}:" /etc/group; then
			yndialog "El grupo ya existe, repetir? (y/n): "
			case $? in
				1)
					break
					;;
			esac
		else
			break
		fi
	done
	
	#GID
	grp_og=false
	grp_oo=false
	yncdialog "Desea especificar el gid? (y/n/c): "
	case $? in
		0)
			while true; do
				read -p "Ingrese gid: " grp_gid
				repeat=false
				cut -d: -f3 /etc/group | grep -x "$grp_gid" >/dev/null 2>/dev/null
				if [ $? -eq 0 ]; then
					yncdialog "Se a detectado que el gid esta en uso, desea utilizar el gid no unico? (y/n/c)" 
					case $? in
						0)
							grp_oo=true
							;;
						1)
							repeat=true
							;;
						2)
							return 1
							;;
					esac
				fi
				if ! $repeat; then
					grp_og=true
					break
				fi
			done
			;;
		2)
			return 1
			;;
	esac

	#passwd
	grp_op=false
	yncdialog "Desea agregar una clave? (y/n/c): " 
	case $? in
		0)
			grp_pas=$(readpasswd "Ingrese clave: ")
			grp_op=true
			;;
		2)
			return 1
			;;	
	esac
	
	#system group
	grp_or=false
	yncdialog "Desea crear este grupo como grupo de sistema? (y/n/c): "
	case $? in
		0)
			grp_or=true
			;;
		2)
			return 1
			;;
	esac

	final="groupadd"
	if $grp_og; then
		final="$final -g $grp_gid"
		if $grp_oo; then
			final="$final -o"
		fi
	fi
	if $grp_op; then
		final="$final -p $grp_pas"
	fi
	if $grp_or; then
		final="$final -r"
	fi
	final="$final $grp_name"
	eval "$final" >/dev/null 2>/dev/null
	case $? in
		0)
			#0: success
			echo "Grupo creado con exito."
			;;
		2)
			#2: invalid command syntax
			echo "Sintaxis de comando invalida."
			;;
		3)
			#3: invalid argument to option
			echo "Argumento de opcion invalido."
			;;
		4)
			#4: GID not unique (when -o not used)
			echo "El gid ingresado no es unico y no se uso -o."
			;;
		9)
			#9: group name not unique
			echo "El nombre de grupo no es unico."
			;;
		10)
			#10: can't update group file
			echo "No se pudo actualizar archivo group."
			;;
	esac
	read -p "$ENTER_CONTINUE" in
	return 0

}

baja () {

	#groupdel
	#group

	#group name
	while true; do
		read -p "Ingrese nombre del grupo a borrar: " grp_name
		if ! grep -q "^${grp_name}:" /etc/group; then
			yndialog "El grupo no existe, repetir? (y/n): " 
			case $? in
				1)
					return 1
					;;
			esac
		else
			break
		fi
	done

	eval "groupdel $grp_name" >/dev/null 2>/dev/null
	case $? in
		0)
			#0: success
			echo "Grupo borrado con exito."
			;;
		2)
			#2: invalid command syntax
			echo "Sintaxis de comando invalida."
			;;
		8)
			#8: can't remove user's primary group
			echo "No se puede borrar grupo primario de usuario."
			;;
		10)
			#10: can't update group file
			echo "No se pudo actualizar archivo group."
			;;
	esac
	read -p "$ENTER_CONTINUE" in
	return 0
}

modificar () {

	#groupmod
	#-g GI
	#-o gid no unica
	#-n new name
	#-p passwd
	#group

	#group name
	while true; do
		read -p "Ingrese nombre del grupo a modificar: " grp_name
		if ! grep -q "^${grp_name}:" /etc/group; then
			yndialog "El grupo no existe, repetir? (y/n): " 
			case $? in
				1)
					return 1
					;;
			esac
		else
			break
		fi
	done
	
	#GID
	grp_og=false
	grp_oo=false
	yncdialog "Desea modificar el gid? (y/n/c): "
	case $? in
		0)
			while true; do
				read -p "Ingrese gid: " grp_gid
				repeat=false
				cut -d: -f3 /etc/group | grep -x "$grp_gid" >/dev/null 2>/dev/null
				if [ $? -eq 0 ]; then
					yncdialog "Se a detectado que el gid esta en uso, desea utilizar el gid no unico? (y/n/c)" 
					case $? in
						0)
							grp_oo=true
							;;
						1)
							repeat=true
							;;
						2)
							return 1
							;;
					esac
				fi
				if ! $repeat; then
					grp_og=true
					break
				fi
			done
			;;
		2)
			return 1
			;;
	esac

	#change name
	grp_on=false
	while true; do
		yncdialog "Desea modificar el nombre del grupo? (y/n/c):"
		case $? in
			0)
				read -p "Ingrese nuevo nombre para el grupo: " grp_nname
				if grep -q "^${grp_nname}:" /etc/group; then
					grp_on=true
					break
				else
					echo "Ya existe un grupo con ese nombre."
				fi
				;;
			1)
				break
				;;
			2)	
				return 1
				;;
		esac
	done
	
	#passwd
	grp_op=false
	shadow_line=$(grep -s $grp_name /etc/gshadow)
	echo $shadow_line | cut -d: -f2 | grep -x "!"
	case $? in
		0) #has passwd
			yncdialog "Desea cambiar la clave? (y/n/c): " 
			case $? in
				0)
					grp_pas=$("Ingrese nueva clave: ")
					grp_op=true
					;;
				2)
					return 1
					;;	
			esac
			;;
		1) #no passwd
			yncdialog "Desea agregar una clave? (y/n/c): " 
			case $? in
				0)
					grp_pas=$(readpasswd "Ingrese clave: ")
					grp_op=true
					;;
				2)
					return 1
					;;	
			esac
			;;
	esac

	final="groupmod "
	if $grp_og; then
		final="$final -g $grp_gid"
		if $grp_oo; then
			final="$final -o"
		fi
	fi
	if $grp_on; then
		final="$final -n $grp_nname"
	fi
	if $grp_op; then
		final="$final -p $grp_pas"
	fi
	eval "$final" >/dev/null 2>/dev/null
	case $? in
		0)
			#0: success
			echo "Grupo creado con exito."
			;;
		2)
			#2: invalid command syntax
			echo "Sintaxis de comando invalida."
			;;
		3)
			#3: invalid argument to option
			echo "Argumento de opcion invalido."
			;;
		4|6)
			#bug en man? dos exitcodes espesifican el mismo error.
			#4 and 6: GID not unique (when -o not used)
			echo "El gid ingresado no es unico y no se uso -o."
			;;
		9)
			#9: group name not unique
			echo "El nombre de grupo no es unico."
			;;
		10)
			#10: can't update group file
			echo "No se pudo actualizar archivo group."
			;;
	esac
	read -p "$ENTER_CONTINUE" in
	return 0

}

while true; do
	clear
	cat menus/group
	read -p "~$ " op

	case $op in
		1)
			clear
			alta
			;;
		2)
			clear
			baja
			;;
		3)
			clear
			modificar
			;;
		4)
			clear
			consulta
			;;
		0)
			clear
			break
			;;
		*)
			clear
			echo "$SYNTAX_ERROR"
			read
			;;
	esac
done
