﻿#!/bin/bash
#instinfosquota
#
# Script d'installation d'infosquota pour Scribe 2.3 ou Scribe 2.2
#
#
#Version 2.03
#

. /usr/share/eole/FonctionsEoleNg
. /usr/bin/ParseDico

#Déclaration du proxy si besoin
if [ -f /etc/eole/version ] && [ "$proxy" == "oui" ] ; then
    #Scribe 2.2
    export https_proxy="$proxy_server:$proxy_port"
elif [ "$activer_proxy_client" == "oui" ] ; then
    #Scribe 2.3
    export https_proxy="$proxy_client_adresse:$proxy_client_port"
fi

#variable pour le nom du fichier Ã  changer en cas de changement de nom
file="infosquota2.02.tar.gz"
numfile="570"
######

######################
# Nettoyage de /tmp
######################

[ -d /tmp/infosquota ] && rm -rf /tmp/infosquota
[ -d /tmp/infosquota2 ] && rm -rf /tmp/infosquota2
[ -f /tmp/$file ] && rm -rf /tmp/$file
cd /tmp/
#clear
#################
# Téléchargement
#################
EchoGras "#################################################"
EchoGras "# Installation et mise en place d'infosquota 2  #"
EchoGras "#################################################"
echo
echo "----"
EchoGras "Téléchargement d'infosquota 2"

wget https://dev-eole.ac-dijon.fr/attachments/download/$numfile/$file --no-check-certificate
&>/dev/null

if [ ! -f $file ]
	then
		EchoRouge "Problème : $file n'a pas pu être téléchargé !"
		EchoRouge "Abandon de l'installation"
		exit 1
	else
		echo -e "["'\E[32m'"OK"'\E[0m'"] - Téléchargement réussi"
fi

###############
# Décompression
###############
echo
echo "----"
EchoGras "Décompression de $file "
tar zxf $file &>/dev/null
if [ $? -eq 0 ] ; then
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Décompression réussie"
else
	EchoRouge "Problème : le fichier infosquota2.01.tar.gz n'a pas pu être décompressé !"
	EchoRouge "Abandon de l'installation"
 	exit 1
fi

####################
# Copie des fichiers
####################
echo
echo "----"
EchoGras "Installation de infosquota2"
#cron
cp -f /tmp/infosquota2/tache_cron.d/infosquota /etc/cron.d/
if [ $? -ne 0 ] ; then
	EchoRouge "Problème de copie du cron !"
	EchoRouge "Abandon de l'installation"
 	exit 1
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Copie du cron"
fi

cp -f /tmp/infosquota2/tache_cron.weekly/findfic /etc/cron.weekly/
if [ $? -ne 0 ] ; then
	EchoRouge "Problème de copie du findfic !"
	EchoRouge "Abandon de l'installation"
 	exit 1
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Copie du findfic"
fi

#dossier /home/netlogon/infosquota
if [ -d /home/netlogon/infosquota ]; then
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Le répertoire infosquota existe"
else
	EchoGras "Création du répertoire infosquota"
	mkdir /home/netlogon/infosquota &>/dev/null
	if [ $? -ne 0 ] ; then
		EchoRouge "Problème lors de la création de /home/netlogon/infosquota"
	else
		echo -e "["'\E[32m'"OK"'\E[0m'"] - Création réussie"
	fi

fi

#outils
cp -Rf /tmp/infosquota2/infosquota/* /home/netlogon/infosquota/
if [ $? -ne 0 ] ; then
	EchoRouge "Problème de copie de l'application !"
	EchoRouge "Abandon de l'installation"
 	exit 1
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Copie de l'application dans /home/netlogon/infosquota/"
fi

#web
if [ -d /var/www/html/outils ]; then
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Le répertoire outils existe"
else
	EchoGras "Création du répertoire outils"
	mkdir /var/www/html/outils &>/dev/null
	if [ $? -ne 0 ] ; then
		EchoRouge "Problème lors de la création de /var/www/html/outils"
	else
		echo -e "["'\E[32m'"OK"'\E[0m'"] - Création réussie"
	fi
fi

cp -Rf /tmp/infosquota2/outils/* /var/www/html/outils/
if [ $? -ne 0 ] ; then
	EchoRouge "Problème de copie de l'application web !"
	EchoRouge "Abandon de l'installation"
 	exit 1
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Copie de l'application dans /var/www/html/outils/"
fi

cp -f /tmp/infosquota2/sites-enabled/* /etc/apache2/sites-enabled/
if [ $? -ne 0 ] ; then
	EchoRouge "Problème de copie de la config d'outils !\n"
	EchoRouge "Abandon de l'installation"
 	exit 1
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - mise en place de la config d'outils pour Apache2"
fi

###################
# Remise des droits
###################
echo
echo "----"
EchoGras "Mise en place des droits"
chmod +x /etc/cron.weekly/findfic
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors de l'application des droits sur /etc/cron.weekly/findfic"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - mise en place des droits sur /etc/cron.weekly/findfic"
fi
chown -R root:www-data /var/www/html/outils/
chmod -R 755 /var/www/html/outils/
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors de l'application des droits sur /var/www/html/outils/"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - mise en place des droits sur /var/www/html/outils/"
fi
chmod -R 2750 /var/www/html/outils/quotas/log
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors de l'application des droits sur /var/www/html/outils/quotas/log"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - mise en place des droits sur /var/www/html/outils/quotas/log"
fi
chown -R root:www-data /var/www/html/outils/quotas/log
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors du changement de propriétaire de /var/www/html/outils/quotas/log"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - changement de propriétaire de /var/www/html/outils/quotas/log"
fi

#####################
# Redémarrage de cron
#####################
echo
echo "----"
EchoGras "Redémarrage des services modifiés"
service cron restart
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors du redémarrage du cron"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Redémarrage du cron"
fi


#####################
# Redémarrage de Apache2
#####################
service apache2 restart
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors du redémarrage de Apache2"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Redémarrage de Apache2"
fi

###################
# Nettoyage de /tmp
###################
echo
echo "----"
EchoGras "Suppression du répertoire temporaire"
rm -rf /tmp/infosquota2
if [ $? -ne 0 ] ; then
	EchoRouge "Problème lors de la suppression du répertoire temporaire"
else
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Suppression du répertoire temporaire"
fi

echo
############################
# Edition du domainusers.txt
############################
echo
echo "----"
EchoGras "Mise en place de la commande infosquota dans DomainUsers.txt"
grep infosquota.exe /home/netlogon/scripts/groups/DomainUsers.txt > /dev/null
if [ $? = 0 ]
then
	echo "Le fichier /home/netlogon/scripts/groups/DomainUsers.txt contient déjà la commande pour infosquota"
else
	echo cmd,\\\\$adresse_ip_eth0\\netlogon\\infosquota\\infosquota.exe >> /home/netlogon/scripts/groups/DomainUsers.txt
	if [ $? -ne 0 ] ; then
		echo
		EchoRouge "Problème lors de la mise en place de la commande dans DomainUsers.txt"
	else
		echo	
		echo -e "["'\E[32m'"OK"'\E[0m'"] - Mise en place de la commande dans DomainUsers.txt"
	fi
fi

############################
# Préparation des fichiers (premiere execution)
############################
echo
echo "----"
EchoGras "Première exécusion de infosquota2"
echo
EchoOrange "Lancement de la recherche, "
EchoOrange "veuillez patienter quelques minutes."
EchoOrange "Merci ..."

/etc/cron.weekly/findfic

if [ $? -ne 0 ] ; then
	echo
	EchoRouge "Problème lors de l'exécusion de /etc/cron.weekly/findfic"
else
	echo	
	echo -e "["'\E[32m'"OK"'\E[0m'"] - Exécusion de /etc/cron.weekly/findfic"
fi
echo
EchoVert "La recherche est terminée !"
echo
echo "Vous pouvez consulter le résultat "
echo "en vous loggant avec le compte 'admin' du scribe"
echo "Ã  l'adresse suivante :"
echo
EchoBleu "http://$adresse_ip_eth0/outils/quotas"
echo
echo "----"
echo
exit 0

