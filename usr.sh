#!/bin/sh
. "$PWD/libabmc.sh"

alta () {
	
	#useradd
	#-d especificar home
	#-m crear directorio especificado
	#-G grupo principal
	#-g grupo secundario
	#-c comentario
	#-s shell
	#login nombre de usuario

	#exitcodes
	#0 exito
	#1 cancelado

	#Login
	while true; do
		read -p "Ingrese nombre del nuevo usuario UNIX: " usr_name
		id -u $usr_name >/dev/null 2>/dev/null
		usr_exists=$?
		if [ $usr_exists -eq 0 ]; then
			yndialog "El usuario ya existe, repetir? (y/n):"
			case $? in
				1)
					return 1
					;;
			esac
		else
			break
		fi
	done

	#Directorio
	usr_od=false
	yncdialog "Desea especificar el directorio? (y/n/c): "
	case $? in
		0)
			read -p "Ingrese directorio 'home': " usr_dir
			usr_od=true
			;;
		2)
			return 1
			;;
	esac	
	
	#Crear Directorio
	usr_omd=false
	yncdialog "Desea crear el directorio? (y/n/c): "
	case $? in
		0)
			user_omd=true
			;;
		2)
			return 1
			;;
	esac

	#Grupo principal
	usr_oG=false
	yncdialog "Desea especificar el grupo principal? (y/n/c): "
	case $? in
		0)
			read -p "Ingrese el nombre del grupo: " usr_G
			usr_oG=true
			;;
		2)
			return 1
			;;
	esac
	
	#Grupo secundario
	usr_og=false
	yncdialog "Desea especificar el grupo secundario? (y/n/c): "
	case $? in
		0)
			read -p "Ingrese el nombre del grupo: " usr_g
			usr_og=true
			;;
		2)
			return 1
			;;
	esac

	#Comentario
	usr_oc=false
	yncdialog "Desea agregar un comentario? (y/n/c): "
	case $? in
		0)
			read -p "Ingrese el comentario: " usr_c
			usr_oc=true
			;;
		2)
			return 1
			;;
	esac
	
	#Shell
	usr_os=false
	yncdialog "Desea especificar el shell? (y/n/c): "
	case $? in
		0)
			read -p "Ingrese shell: " usr_s
			usr_os=true
			;;
		2)
			return 1
			;;
	esac

	final="useradd "
	if $usr_od; then
		final="$final -d $usr_dir"
		if $usr_omd; then
			final="$final -m"
		fi
	fi
	if $usr_oG; then
		final="$final -G $usr_G"
	fi
	if $usr_og; then
		final="$final -g $usr_g"
	
	fi
	if $usr_oc; then
		final="$final -c '$usr_c'"
	fi
	if $usr_os; then
		final="$final -s $usr_s"
	fi
	final="$final $usr_name"
	eval $final >/dev/null 2>/dev/null
	case $? in

		0)
			#0: success
			echo "Usuario creado correctamente."
			#Password
			yndialog "Desea agregar una clave de acceso? (y/n): "
			case $? in
				0)
					passwd $usr_name	
					;;
			esac
			;;
		1)
			#1: can't update password file
			echo "No se pudo actualizar archivo passwd."
			;;
		2)
			#2: invalid command syntax
			echo "Error en la sintaxis del comando."
			;;
		3)
			#3: invalid argument to option
			echo "Argumento invalido en una opcion."
			;;
		4)
			#4: UID already in use (and no -o)
			echo "ID de usuario en uso."
			;;
		6)
			#6: specified group doesn't exist
			echo "Grupo espesificado no existe."
			;;
		9)
			#9: username already in use
			echo "Nombre de usuario en uso."
			;;
		10)
			#10: can't update group file
			echo "No se pudo actualizar archivo de grupos."
			;;
		12)
			#12: can't create home directory
			echo "No se pudo crear directorio home."
			;;
		13)
			#13: can't create mail spool
			echo "No se pudo crear casilla de mail."
			;;
		14)
			#14: can't update SELinux user mapping
			echo "No se pudo actualizar mapeado SELinux."
			;;
	esac

	read -p "$ENTER_CONTINUE" in
	return 0	

}

baja () {

	while true; do
		read -p "Ingrese login del usuario a borrar: " usr_name
		id -u $usr_name >/dev/null 2>/dev/null
		usr_exists=$?
		if [ $usr_exists -eq 0 ]; then
			break
		else
			yndialog "El usuario no existe, repetir? (y/n):"
			case $? in
				1)
					return 1
					;;
			esac
		fi
	done

	total=false
	yncdialog "Desea borrar 'home' del usuario? (y/n/c): "
	case $? in
		0)
			total=true
			;;
		2)
			return 1
			;;
	esac

	final="userdel "
	if $total; then
		final="$final -r"
	fi
	final="$final $usr_name"
	eval $final >/dev/null 2>/dev/null	
	case $? in
		0)
			#0: success
			echo "Usuario borrado correctamente."
			;;
		1)
			#1: can't update password file
			echo "No se pudo actualizar achivo passwd."
			;;
		2)
			#2: invalid command syntax
			echo "Sintaxis invalida."
			;;
		6)
			#6: specified user doesn't exist
			echo "El usuario no existe."
			;;
		8)
			#7: user currently logged in
			echo "El usuario esta logeado."
			;;
		10)
			#10: can't update group file
			echo "No se pudo actualizar archivo de grupos."
			;;
		12)
			#12: can't remove home directory
			echo "No se pudo borrar directorio 'home'."
			;;
	esac
	read -p "$ENTER_CONTINUE" in
	return 0

}

modificar () {

	#usermod
	#-c comentario
	#-d directorio home
	#-m mover archivos
	#-l login
	#-L bloquear
        #-U desbloquear
	#-u numero de usuario
	#-G lista de grupos adicionales
	#-g nombre o gid del grupo inicial del usuario	
	#-a hace que la opcion '-G' agrege los grupos en vez de setearlos
	#-s shell
	#login del usuario a modificar

	while true; do
		read -p "Ingrese login del usuario a modificar: " usr_name
		id -u $usr_name >/dev/null 2>/dev/null
		usr_exists=$?
		if [ $usr_exists -eq 0 ]; then
			break
		else
			yndialog "El usuario no existe, repetir? (y/n):"
			case $? in
				1)
					return 1
					;;
			esac
		fi
	done
	#flags para construir el comando
	usr_oc=false #comentario
	usr_od=false #home
	usr_om=false #mover los archivos al nuevo home
	usr_on=false #login
	usr_ol=false #bloquear/desbloquear
	usr_ou=false #uid
	usr_oG=false #lista de grupos
	usr_oa=false #agreagar al final
	usr_og=false #nombre o gid del grupo principal
	usr_os=false #shell

	usr_groups="" #lista de grupos a agregar
	while true; do
		clear

		passwd -S $usr_name | grep " L " -c >/dev/null 2>/dev/null
		locked=$?
		if [ $locked -eq 1 ]; then
			cat menus/user-mod-u
		else
			cat menus/user-mod-l
		fi
		shadow_line=$(grep "^${usr_name}:" /etc/shadow)
		pass=$(echo $shadow_line | cut -d: -f2)
		if [ "$pass" = "!" ] || [ "$pass" = "*" ]; then
			pprotected=false
			echo "Este usuario no tiene una clave asignada! se recomienda agregar una."
		else
			pprotected=true
		fi
		
		echo "Modificando: '$usr_name'"

		if $usr_oc || $usr_od || $usr_on || $usr_ol || $usr_ou || $usr_oG || $usr_og || $usr_os; then
			echo "[Tiene cambios sin aplicar]"
		fi
		read -p "~$ " op

		case $op in	
			0)
				break
				;;
			1)
				#comentario
				clear
				read -p "Ingrese nuevo comentario para el usuario: " usr_c
				usr_oc=true
				;;
			2)
				#home
				clear
				read -p "Ingrese nuevo 'home' para el usuario: " usr_d
				yncdialog  "Desea mover los archivos del usuario al nuevo 'home'? (y/n/c): "
				case $? in
					0)	
						usr_od=true
						usr_om=true
						;;
					1)
						usr_od=true
						;;
				esac
				;;
			3)
				#login
				clear
				read -p "Ingrese nuevo login para el usuario: " usr_n
				usr_on=true
				;;
			4)
				#bloquear/desbloquear
				if $pprotected; then
					if [ $locked -eq 0 ]; then
						yndialog "Desea desbloquear la cuenta? (y/n): "
					else
						yndialog "Desea bloquear la cuenta? (y/n): "
					fi
					case $? in
						0)
							usr_ol=true
							;;
					esac
				else
					clear
					echo "Esta cuenta no tiene una clave de acceso, por lo tanto no se puede bloquear/desbloquear."
					read -p "$ENTER_CONTINUE" cont
				fi
				;;
			5)
				#uid
				clear
				while true; do
					echo "El UID actual es: $(id -u $usr_name)"
					read -p "Ingrese nuevo uid para el usuario: " usr_uid
					if [ $usr_uid -eq $usr_uid ] 2>/dev/null; then
						usr_ou=true
						break
					else
						yndialog "El valor ingresado no es un numero valido, repetir? (y/n): "
						case $? in
							1)
								break
								;;
						esac
					fi
				done
				;;
			6)
				#lista de grupos
				clear
				new_groups=""
				if ! [ -z "$usr_groups" ]; then
					echo "Parece que se han ingresado grupos pero no se han aplicado."
					yndialog "Desea descartar los grupos anteriormente ingresados? (y/n): "
					case $? in
						0)
							usr_groups=""
							;;
					esac
				fi
				echo "A continuacion se pedira que ingrese los grupos uno a uno"
				group_num=1
				while true; do
					read -p "Ingrese grupo numero $group_num: " new_group
					if [ $(grep -c -E "^$new_group:" /etc/group) -eq 0 ]; then
						echo "Grupo '$new_group' no existe."
					else
						if ! [ -z "$new_groups" ]; then
							new_groups="$new_groups,$new_group"
						else
							new_groups="$new_group"
						fi
						group_num=$((group_num + 1))
					fi

					finish=false
					yncdialog  "Desea seguir agregando grupos? (y/n/c): "
					case $? in
						1)
							if ! [ -z "$new_groups" ]; then
								if ! [ -z "$usr_groups" ]; then
									usr_groups="$usr_groups,$new_groups"
								else
									usr_groups="$new_groups"
								fi
								usr_oG=true
							fi
							finish=true
							;;
						2)
							finish=true
							;;
					esac
					if $finish; then break; fi
				done
				if ! [ -z "$new_groups" ]; then
					echo "Los grupos ingresados son:"
					echo "			$usr_groups"
					echo "Desea que estos grupos sobreescriban los grupos actuales del usuario,"
					echo "			o simplemente desea agregarlos al final?"
					echo "[S] - Sobreescribir"
					echo "[A] - Agregar al final"
					while true; do
						read -p "~$ " op
						case "$op" in
							S)
								break
								;;
							A)
								usr_oa=true
								break
								;;
							*)
								echo "$SYNTAX_ERROR"
								;;
						esac
					done
				fi
				read -p "$ENTER_CONTINUE" in
				;;
			7)	
				#gid
				clear
				while true; do
					read -p "Ingrese nombre o gid del grupo inicial: " usr_group
					if [ $(grep -c -E "^$usr_group:" /etc/group) -eq 0 ] && [ $(grep -c -E ":$usr_group:" /etc/group) -eq 0 ]; then
						echo "Grupo '$usr_group' no existe."
						finish=false
						yndialog "Desea intentarlo de nuevo? (y/n): "
						case $? in
							1)
								finish=true
								;;
						esac
						if $finish; then break; fi
					else
						usr_og=true
						break
					fi
				done		
				read -p "$ENTER_CONTINUE" in				
				;;
			8)
				#shell
				clear
				read -p "Ingrese nueva shell para el usuario: " usr_s
				usr_os=true
				;;
			9)
				clear
				passwd $usr_name
				;;
			10)
				#evaluar cambios
				clear
				final="usermod "
				if $usr_oc; then
					echo "Comentario: $usr_c"
					final="$final -c '$usr_c'"
				fi
				if $usr_od; then
					echo "Home: $usr_d"
					final="$final -d $usr_d"
					if $usr_om; then
						echo "Se moveran los archivos del usuario."
						final="$final -m"
					fi
				fi
				if $usr_on; then
					echo "Login: $usr_n"
					final="$final -l $usr_n"
				fi
				if $usr_ol; then
					if [ $locked -eq 0 ]; then
						echo "Se desbloqueara la cuenta del usuario."
						final="$final -U"
					else
						echo "Se bloqueara la cuenta del usuario."
						final="$final -L"
					fi
				fi
				if $usr_ou; then
					echo "UID: $usr_uid"
					final="$final -u $usr_uid"
				fi
				if $usr_oG; then
					echo "Grupos: $usr_groups"
					final="$final -G '$usr_groups'"
					if $usr_oa; then
						echo "Se agregaran al final de los grupos existentes."
						final="$final -a"
					else
						echo "Se sobreescribiran los grupos existentes."
					fi
				fi
				if $usr_og; then
					echo "GID o nombre de grupo principal: $usr_group"
					final="$final -g $usr_group"
				fi
				if $usr_os; then
					echo "Shell: $usr_s"
					final="$final -s $usr_s"
				fi
				final="$final $usr_name"
				yndialog  "Desea aplicar los cambios? (y/n): "
				case $? in
					0)
						eval "$final" >/dev/null 2>/dev/null
						;;
				esac
				if $usr_on; then
					usr_name=$usr_n
				fi
				usr_oc=false #comentario
				usr_od=false #home
				usr_om=false #mover los archivos al nuevo home
				usr_on=false #login
				usr_ol=false #bloquear/desbloquear
				usr_ou=false #uid
				usr_oG=false #lista de grupos
				usr_oa=false #agregar o sobreescribir
				usr_groups=""
				usr_og=false #grupo inicial
				usr_os=false #shell
				;;
			*)
				#error
				echo "$SYNTAX_ERROR"
				read -p "$ENTER_CONTINUE" in
				;;	
		esac
	done

}

consulta () {

	while true; do
		clear
		cat menus/user-con
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
					echo "--------------------------"
					while read -r line; do
						echo "Login:      $(echo $line | cut -d: -f1)"
						echo "UID:        $(echo $line | cut -d: -f3)"
						echo "GID:        $(echo $line | cut -d: -f4)"
						echo "Comentario: $(echo $line | cut -d: -f5)"
						echo "Home:       $(echo $line | cut -d: -f6)"
						echo "Shell:      $(echo $line | cut -d: -f7)"
						echo "--------------------------"
					done < /etc/passwd
				else
					echo "--------------------------" > $save_name
					while read -r line; do
						echo "Login:      $(echo $line | cut -d: -f1)"
						echo "UID:        $(echo $line | cut -d: -f3)"
						echo "GID:        $(echo $line | cut -d: -f4)"
						echo "Comentario: $(echo $line | cut -d: -f5)"
						echo "Home:       $(echo $line | cut -d: -f6)"
						echo "Shell:      $(echo $line | cut -d: -f7)"
						echo "--------------------------"
					done < /etc/passwd > $save_name
					cat $save_name
				fi
				read -p "$ENTER_CONTINUE" in
				;;
			2)
				read -p "Ingrese login usuario a mostrar: " usr
				line=$(grep "^${usr}:" /etc/passwd)
				if [ $? -eq 0 ]; then
					echo "--------------------------"
					echo "Login:      $(echo $line | cut -d: -f1)"
					echo "UID:        $(echo $line | cut -d: -f3)"
					echo "GID:        $(echo $line | cut -d: -f4)"
					echo "Comentario: $(echo $line | cut -d: -f5)"
					echo "Home:       $(echo $line | cut -d: -f6)"
					echo "Shell:      $(echo $line | cut -d: -f7)"
					echo "--------------------------"
				else
					echo "Usuario no encontrado."
				fi			
	
				read -p "$ENTER_CONTINUE" in
				;;
			0)
				clear
				break
				;;
			*)	
				echo "$SYNTAX_ERROR"
				read -p "$ENTER_CONTINUE" in
				;;
		esac
	done

}

while true; do
	clear
	cat menus/user
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
			echo "$SYNTAX_ERROR"
			read -p "$ENTER_CONTINUE" in
			;;
	esac
done
