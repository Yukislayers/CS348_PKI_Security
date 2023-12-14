#!/bin/bash

#first we will add an entry to /etc/hosts for iam2.kaist.ac.kr
sudo echo  "10.9.0.80	iam2.kaist.ac.kr" >> /etc/hosts

#Now we will create the certificate and the key and the key for iam2.kaist.ac.kr
#First we will issue a .csr file and a .key file
openssl req -newkey rsa:2048 -sha256 -keyout fake_20226189.key -out fake_20226189.csr -subj "/CN=iam2.kaist.ac.kr/O=kaist-sec Inc./C=US" -passout pass:dees -config openssl.cnf

#Now we will issue the crt file
openssl ca -config openssl.cnf -policy policy_anything -md sha256 -days 3650 -in fake_20226189.csr -out fake_20226189.crt -batch -cert ca.crt -keyfile ca.key -passin pass:dees

#We want to get them in the container so we will put them in volumes
sudo cp fake_20226189.crt /home/seed/Labsetup/volumes
sudo cp fake_20226189.key /home/seed/Labsetup/volumes

#Now we want to build the container and start it
docker-compose build
docker-compose up -d

#We want to add some entries to bank32_apache_ssl.conf for iam2.kaist.ac.kr
docker exec www-10.9.0.80 bash -c "echo '<VirtualHost *:443>' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '	DocumentRoot /var/www/bank32' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '	ServerName iam2.kaist.ac.kr' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '	DirectoryIndex index.html' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '	SSLEngine On' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '	SSLCertificateFile /volumes/fake_20226189.crt' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '	SSLCertificateKeyFile /volumes/fake_20226189.key' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"
docker exec www-10.9.0.80 bash -c "echo '</VirtualHost>' >> /etc/apache2/sites-available/bank32_apache_ssl.conf"

#Then we need to start the apache2 server but in the pdf file it is said that it will be launched manually
#We have to launch service apache2 start
#Then we have to enter the password dees
#And on the VM on firefox, we can browse https://iam2.kaist.ac.kr 

