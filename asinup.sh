# /bin/sh -
#
# asinup.sh
#
# Script permettant la sauvegarde des fichiers du répertoire $origine, vers
# $destination, toutes les $espacetemps minutes, avec fichier d'archive 
# toutes les $latence minutes.

#####
## LICENCE
###

#                LICENCE PUBLIQUE RIEN À BRANLER
#                      Version 1, Mars 2009
#
# Copyright (C) 2010 Olivier DOSSMANN
#  <blankoworld@wanadoo.fr>
# 
# La copie et la distribution de copies exactes de cette licence sont
# autorisées, et toute modification est permise à condition de changer
# le nom de la licence. 
#
#         CONDITIONS DE COPIE, DISTRIBUTON ET MODIFICATION
#               DE LA LICENCE PUBLIQUE RIEN À BRANLER
#
#  0. Faites ce que vous voulez, j’en ai RIEN À BRANLER.

#####
## VARIABLES
###

# Initialisation des variables
CODEEXIT=0
PROGRAMME=`basename $0`
VERSION=0.0

#ESPACE_TEMPS=2
#LATENCE=8

faire_archive=0
origine=
destination=

#####
## FONCTIONS
###

# Basique

erreur( )
{
	echo "$@" 1>&2
	utilisation_puis_sortie 1
}

utilisation( )
{
	echo "Utilisation: $PROGRAMME [--?] [--help] [--version] origine \
destination"
}

utilisation_puis_sortie( )
{
	utilisation
	exit $1
}

version( )
{
	echo "$PROGRAMME version $VERSION"
}

warning( )
{
	echo "$@" 1>&2
	CODEEXIT=`expr $CODEEXIT + 1`
}

#####
## TESTS
###

while test $# -gt 0
do
	case $1 in
	-a )
		faire_archive=1
		;;
	--help | -hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
		utilisation_puis_sortie 0
		;;
	--version | --versio | --versi | --vers | --ver | -ve | --v | \
	-version | -versio | -versi | -vers | -ver | -ve | -v )
		version
		exit 0
		;;
	-*)
		erreur "Option non reconnue : $1"
		;;
	*)
		break
		;;
	esac
	shift
done

# Enregistrement des deux variables $origine et $destination
origine="$1"
test $# -gt 0 && shift
destination="$1"

# Multiples tests avant de commencer quoique ce soit
if test -z "$origine"
then
	erreur La variable origine est absente ou vide
elif test -z "$destination"
then
	erreur La variable destination est absente ou vide
elif ! test -d "$origine"
then
	erreur Le dossier origine est un fichier ou le répertoire n\'existe pas
elif ! test -d "$destination"
then
	erreur Le dossier de destination est un fichier ou le répertoire \
n\'existe pas
fi

#####
## DÉBUT
###

### On procède à notre traitement (ENFIN!)
# Création d'un répertoire "fichiers" si aucun existant actuellement
if ! test -d "$destination"/fichiers
then
	mkdir -p "$destination"/fichiers
fi

if test $faire_archive -ne 0
then
	temporaire=~/tmp/archives
	# Archivage dans un repertoire temporaire
	if ! test -d "$temporaire"
	then
		mkdir -p "$temporaire"
	fi
	heure=`date '+%H'`
	fichier="$temporaire/$heure-asinup.tar.gz"
	dossier_actuel=`pwd`
	cd "$temporaire"
	tar cfz "$fichier" "$origine"
	cd "$dossier_actuel"
	rsync -a --partial "$temporaire" "$destination"
fi

# Synchronisation des deux répertoires
rsync -a --partial --delete "$origine" "$destination"/fichiers

#####
## FIN
###

# Limite le code de retour aux valeurs classiques d'Unix (vu dans Script Shell \
# chez O'Reilly)
test $CODEEXIT -gt 125 && CODEEXIT=125

exit $CODEEXIT
