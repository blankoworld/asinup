#!/bin/bash -
#
# cron_asinup.sh
#
# Outil qui va lancer un ensemble de sauvegardes à l'aide du script asinup.sh sur une liste de dossiers donnés dans un fichier

#####
## VARIABLES
###

$USER='olivier'
script="/home/$USER/bin/asinup.sh"
liste="/home/$USER/bin/fic_cron_asinup.liste"

ARCHIVE=0

#####
## TESTS
###

# Vérification fichier asinup.sh présent
if ! [[ -x "$script" ]]
then
  echo "Script $script non trouvé ou non exécutable."
  exit 1
else
  echo "Script trouvé et exécutable."
fi

if ! [[ -r "$liste" ]]
then
  echo "Liste $liste non trouvée ou non lisible."
  exit 1
else
  echo "Liste $liste trouvée et lisible."
fi

if test $# -gt 0 && [[ $1 == "-a" ]]
then
  ARCHIVE=1
fi

#####
## DEBUT
###

# Lecture du fichier comportant les dossiers à sauver (adresses absolues)
#cat $1/${PIC_IDX} | while read ligne ; do

cat $liste | while read ligne ; do
  origine=`echo $ligne |cut -d ":" -f 1`
  destination=`echo $ligne |cut -d ":" -f 2`
  if test $ARCHIVE -ne 0
  then
    commande="$script -a $origine $destination"
  else
    commande="$script $origine $destination"
  fi
  #echo -e "Origine: $origine\n\tDestination: $destination"
  echo "COMMANDE : $commande ..."
  ($commande)
  echo -e "\tTerminée avec succès"
done

