#!/bin/bash
#title        : manarang.sh  
#description  : Script Seperti Vagrant Provision Untuk Digunakan Pada Linux XAMPP
#author       : Syaifur Rijal Syamsul, SST
#date         : 29 Mei 2020
#revisiondate : 9 Juni 2020
#version      : 0.4
#usage        : bash manarang.sh
#notes        : Install yq package
#bash_version : 4.1.5(1)-release
#=================================================================================

export HOSTS=$HOME/Public/Manarang/hosts
export FYAML=$HOME/Public/Manarang/manarang.yaml

export LAMPP=/opt/lampp
export HTTPD=$LAMPP/etc/httpd.conf
export VHOST=$LAMPP/etc/extra/httpd-vhosts.conf

export MYSQLPATH=/opt/lampp/bin
export PGSQLPATH=/opt/lampp/postgresql

# menjalankan lampp server
echo '--- Jalankan Linux XAMPP SERVER'
sudo $LAMPP/lampp start && bash $PGSQLPATH/postgresql.sh start

echo -ne "\n"

echo '--- Memulai Provision Linux XAMPP'

# Menghapus seluruh isi file
echo '--- Reset File hosts'
sed -i '/# Daftar Website Sesuai Konfigurasi/!d' $HOSTS

# Mengembalikan file httpd.conf seperti semula
echo '--- Reset File httpd.conf'
sudo sed -i '1, /# Mulai Aliases/!d' $HTTPD

# Mengembalikan file httpd-vhosts.conf seperti semula
echo '--- Reset File httpd-vhosts.conf'
sudo sed -i '1, /# Mulai Vhosts/!d' $VHOST

echo -ne "\n"

# Menulis seluruh domain ke file hosts
echo '--- Menulis Ulang Seluruh Domain'
for n in $(yq r $FYAML sites[*].map)
do
    echo -ne "\n"
    
    echo "$(yq r $FYAML ip) $n.test" >> $HOSTS
    
    echo -ne "--- $n.test : #####                     (33%)\r"
    sleep 1
    echo -ne "--- $n.test : #############             (66%)\r"
    sleep 1
    echo -ne "--- $n.test : #######################   (100%)\r"
done

echo -ne "\n\n"

# Menulis ulang seluruh aliases
echo '--- Menulis Ulang Seluruh Aliases'
IALIAS=0
for n in $(yq r $FYAML sites[*].to)
do
    echo -ne "\n" | sudo tee -a $HTTPD
    
    echo "# $(yq r $FYAML sites[${IALIAS}].map).test" | sudo tee -a $HTTPD > /dev/null
    echo "Alias /$(yq r $FYAML sites[${IALIAS}].map) \"$n\"" | sudo tee -a $HTTPD > /dev/null
    echo "<Directory \"$n\">" | sudo tee -a $HTTPD > /dev/null
    echo -e "\tAllowOverride All" | sudo tee -a $HTTPD > /dev/null
    echo -e "\tOrder allow,deny" | sudo tee -a $HTTPD > /dev/null
    echo -e "\tAllow from all" | sudo tee -a $HTTPD > /dev/null
    echo "</Directory>" | sudo tee -a $HTTPD > /dev/null
    
    echo -ne "--- $(yq r $FYAML sites[${IALIAS}].map).test : #####                     (33%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML sites[${IALIAS}].map).test : #############             (66%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML sites[${IALIAS}].map).test : #######################   (100%)\r"
    
    let IALIAS=${IALIAS}+1
done

echo -ne "\n\n"

# Menulis ulang seluruh virtualhost
echo '--- Menulis Ulang Seluruh Virtualhost'
IVHOST=0
for n in $(yq r $FYAML sites[*].to)
do
    echo -ne "\n" | sudo tee -a $VHOST
    
    echo "# $(yq r $FYAML sites[${IVHOST}].map).test" | sudo tee -a $VHOST > /dev/null
    echo "<VirtualHost *:80>" | sudo tee -a $VHOST > /dev/null
    echo -e "\tServerAdmin webmaster@$(yq r $FYAML sites[${IVHOST}].map).test" | sudo tee -a $VHOST > /dev/null
    echo -e "\tDocumentRoot \"$n" | sudo tee -a $VHOST > /dev/null
    echo -e "\tServerName $(yq r $FYAML sites[${IVHOST}].map).test" | sudo tee -a $VHOST > /dev/null
    echo -e "\tServerAlias www.$(yq r $FYAML sites[${IVHOST}].map).test" | sudo tee -a $VHOST > /dev/null
    echo -e "\tErrorLog \"logs/$(yq r $FYAML sites[${IVHOST}].map).dev-error_log\"" | sudo tee -a $VHOST > /dev/null
    echo -e "\tCustomLog \"logs/$(yq r $FYAML sites[${IVHOST}].map).dev-error_log\" common" | sudo tee -a $VHOST > /dev/null
    echo "</VirtualHost>" | sudo tee -a $VHOST > /dev/null
    
    echo -ne "--- $(yq r $FYAML sites[${IVHOST}].map).test : #####                     (33%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML sites[${IVHOST}].map).test : #############             (66%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML sites[${IVHOST}].map).test : #######################   (100%)\r"
    
    let IVHOST=${IVHOST}+1
done

echo -ne "\n\n"

# Memasang database
echo '--- Memasang Database MySQL'
IMYSQL=0
for n in $(yq r $FYAML mysqldb[*])
do
    echo -ne "\n"

    if ! $MYSQLPATH/mysql -u root -e "use $n" > /dev/null; then
        $MYSQLPATH/mysql -u root -e "create database $n character set utf8mb4 collate utf8mb4_unicode_ci";
    fi
    
    echo -ne "--- $(yq r $FYAML mysqldb[${IMYSQL}]) : #####                     (33%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML mysqldb[${IMYSQL}]) : #############             (66%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML mysqldb[${IMYSQL}]) : #######################   (100%)\r"
    
    let IMYSQL=${IMYSQL}+1
done

echo -ne "\n\n"

echo '--- Memasang Database PostgreSQL'
IPOSTGRESQL=0
for n in $(yq r $FYAML postgresqldb[*])
do
    echo -ne "\n"
    
    if ! $PGSQLPATH/bin/psql -U postgres -lqt | cut -d \| -f 1 | grep -qw $n > /dev/null; then
        $PGSQLPATH/bin/createdb -U postgres -h localhost -p 5432 $n
    fi
    
    echo -ne "--- $(yq r $FYAML postgresqldb[${IPOSTGRESQL}]) : #####                     (33%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML postgresqldb[${IPOSTGRESQL}]) : #############             (66%)\r"
    sleep 1
    echo -ne "--- $(yq r $FYAML postgresqldb[${IPOSTGRESQL}]) : #######################   (100%)\r"
    
    let IPOSTGRESQL=${IPOSTGRESQL}+1
done

echo -ne "\n\n"

# Restart ulang lampp server
echo '--- Restart Linux XAMPP SERVER'
sudo $LAMPP/lampp restart && bash $PGSQLPATH/postgresql.sh restart

echo -ne "\n"

# Restart ulang DNS Masquarade
echo '--- Restart Service dnsmasq'
sudo systemctl restart dnsmasq

echo -ne "\n"

# Done
echo '--- Tahapan Provision Selesai, Happy Coding'
