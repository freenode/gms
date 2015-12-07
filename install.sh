#!/bin/bash

echo "This will install ATHEME, IRCD-SEVEN (charybdis) AND GMS!"

read -s -p "To continue, press enter. Otherwise, press CTRL+C" 

echo Downloading and installing requirements...

# Installing requirements
sudo apt-get update
sudo apt-get install build-essential gcc flex bison
sudo apt-get install perl=5.18.2-2ubuntu1

echo If there was an error that perl was not found, install perl5 version 5.18.2 yourself from apt.

read -s -p "If not, do that now. Otherwise continue with ENTER"

ln -l /usr/lib/libperl.so.5.18.2 /usr/lib/libperl.so.5
ln -l /usr/lib/libperl.so.5.18.2 /usr/lib/libperl.so

# Download all
cd $HOME
mkdir freenode
cd freenode
mkdir src
mkdir atheme
mkdir ircd
cd src
git clone https://github.com/atheme/atheme.git
git clone https://github.com/atheme/charybdis.git ircd-seven
git clone https://github.com/freenode/gms.git
cd atheme

echo Making and installing atheme...

# Making and installing atheme

git submodule init
git submodule update
./configure --prefix=$HOME/freenode/atheme --with-perl --disable-nls
make
make install

echo Making and installing ircd (charybdis)

# Making and installing ircd (charybdis)

cd ../ircd-seven
./configure --prefix=$HOME/freenode/ircd
make
make install

cd ..

echo Copying gms configurations...

# Putting configuration

cd gms
cp etc/ircd.conf $HOME/freenode/ircd/etc/
cp etc/atheme.conf $HOME/freenode/atheme/etc/
cp etc/services.db $HOME/freenode/atheme/etc/

# Running the services

echo Now we will start the services. After this, connect with irc to the server,
echo do /oper admin password
echo and do /msg NickServ IDENTIFY admin password

$HOME/freenode/ircd/bin/ircd
$HOME/freenode/atheme/bin/atheme-services

echo Now we will install gms and \"hook\" into Atheme

read -p "Continue with ENTER" -s

cd atheme
mv Makefile Makefile.old
cp Makefile.gms-auto Makefile

make
make install

echo That should have worked.
echo Now, restart the atheme-services using /msg OperServ RESTART
echo Note that a normal rehash will not work.

read -p "Waiting for a restart... To continue, press ENTER." -s

$username = "admin"  # Set by default of ircd.conf and services.db....

cd ..
bin/modify_user_roles.pl $username --add=admin --add=staff  # One day in the future, there will be also a --add=accountmanager...

echo "Now go ahead and start the gms server by running script/gms_web_server.pl"

# EOF
