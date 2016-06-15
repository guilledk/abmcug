#!/bin/sh

SYNTAX_ERROR="Opcion invalida."
ENTER_CONTINUE="[ENTER] para continuar."

#deprecated
readpasswd () { #(1: display text) -> (void)
	stty -echo
	printf >&2 "$1"
	read pass
	stty echo
	printf >&2 "\n"
	echo $pass
}

yndialog () { #(1: display text) -> (0: yes, 1: no)
	while true; do
		read -p "$1" op
		case $op in
			y)
				return 0
				;;
			n)
				return 1
				;;
			*)
				echo "$SYNTAX_ERROR"
				;;
		esac
	done
}

yncdialog () { #(1: display text) -> (0: yes, 1: no, 2: cancel)
	while true; do
		read -p "$1" op
		case $op in
			y)
				return 0
				;;
			n)
				return 1
				;;
			c)
				return 2
				;;
			*)
				echo "$SYNTAX_ERROR"
				;;
		esac
	done
}
