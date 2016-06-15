#!/bin/sh
. "$PWD/libabmc.sh"

alta () {

	#groupadd
	#-g GID
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
	if $grp_or; then
		final="$final -r"
	fi
	final="$final $grp_name"
	eval "$final" >/dev/null 2>/dev/null
	case $? in
		0)
			#0: success
			echo "Grupo creado con exito."
			#password
			yncdialog "Desea agregar una clave? (y/n): " 
			case $? in
				0)
					gpasswd $grp_name
					;;
			esac
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
				if ! grep -q "^${grp_nname}:" /etc/group; then
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
	final="$final $grp_name"
	eval "$final" >/dev/null 2>/dev/null
	case $? in
		0)
			#0: success
			echo "Grupo modificado con exito con exito."
			if $grp_on; then grp_name=$grp_nname; fi
			#passwd
			grp_op=false
			shadow_line=$(grep "^${grp_name}:" /etc/gshadow)
			pass=$(echo $shadow_line | cut -d: -f2)
			if [ "$pass" = "!" ] || [ "$pass" = "*" ]; then
				yndialog "Desea agregar una clave de acceso? (y/n): "
				case $? in
					0)
						gpasswd $grp_name
						;;
				esac
			else
				yndialog "Desea cambiar la clave de acceso? (y/n): "
				case $? in
					0)
						gpasswd $grp_name
				esac
			fi
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

consulta () {
	
	while true; do
		clear
		cat menus/group-con	
		read -p "~$ " op
		
		case $op in
				1)
					save=false
					yndialog "Desea guardar la informacion a un archivo? (y/n): "
					case $? in
						0)
							save=true
							read -p "Ingrese nombre del archivo (si no existe se creara): " save_name
							;;
					esac
					if ! $save; then
						while read -r line; do
							cur_grp_name=$(echo $line | cut -d: -f1)
							echo "--------------------------"
							echo "Nombre:      $cur_grp_name"
							shadow_line=$(grep "^${cur_grp_name}:" /etc/gshadow)
							pass=$(echo $shadow_line | cut -d: -f2)
							echo "Pass:        $(if [ "$pass" = "!" ] || [ "$pass" = "*" ]; then echo No; else echo Si; fi)"
							echo "GID:         $(echo $line | cut -d: -f3)"
							echo "Integrantes: $(echo $line | cut -d: -f4)"
							echo "--------------------------"
						done < /etc/group
					else
						while read -r line; do
							cur_grp_name=$(echo $line | cut -d: -f1)
							echo "--------------------------"
							echo "Nombre:      $cur_grp_name"
							shadow_line=$(grep "^${cur_grp_name}:" /etc/gshadow)
							pass=$(echo $shadow_line | cut -d: -f2)
							echo "Pass:        $(if [ "$pass" = "!" ] || [ "$pass" = "*" ]; then echo No; else echo Si; fi)"
							echo "GID:         $(echo $line | cut -d: -f3)"
							echo "Integrantes: $(echo $line | cut -d: -f4)"
							echo "--------------------------"
						done < /etc/group > $save_name
						cat $save_name
					fi
					read -p "$ENTER_CONTINUE" in
					;;
				2)
					read -p "Ingrese nombre del grupo a mostrar: " grp
					line=$(grep "^${grp}:" /etc/group)
					if [ $? -eq 0 ]; then
						echo "--------------------------"
						echo "Nombre:      $grp"
						shadow_line=$(grep "^${grp}:" /etc/gshadow)
						pass=$(echo $shadow_line | cut -d: -f2)
						echo "Pass:        $(if [ "$pass" = "!" ] || [ "$pass" = "*" ]; then echo No; else echo Si; fi)"
						echo "GID:         $(echo $line | cut -d: -f3)"
						echo "Integrantes: $(echo $line | cut -d: -f4)"
						echo "--------------------------"
					else	
						echo "Grupo no encontrado."
					fi			
		
					read -p "$ENTER_CONTINUE" in

					;;
				0)
					break
					;;
				*)
					echo "$SYNTAX_ERROR"
					read -p "$ENTER_CONTINUE" in
					;;
		esac
	done
	return 0

}

while true; do
	clear
	cat menus/group
	read -p "~$ " op

	case $op in
		0)
			break
			;;
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
		*)
			echo "$SYNTAX_ERROR"
			read -p "$ENTER_CONTINUE" in
			;;
	esac
done
