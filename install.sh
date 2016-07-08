#!/bin/bash

echo "This will install ATHEME, IRCD-SEVEN (charybdis) AND GMS!"
echo
echo "Read now the README"

echo

curl "https://raw.githubusercontent.com/freenode/gms/master/README" | more 

echo
echo This script does all the installation described in the README in an automated way.
echo But be sure to have read the \"Before anything else\" section.
echo

read -s -p "To continue, press enter. Otherwise, press CTRL+C" 
echo

echo "Have you installed all requirements (build-essential gcc flex bison libexpat-dev libpq-dev perl)?"
read -s -p "If not, abort using CTRL+C. Otherwise, press ENTER"

wget -O- http://cpanmin.us | perl - -l ~/perl5 App::cpanminus local::lib
eval `perl -I ~/perl5/lib/perl5 -Mlocal::lib`

echo "eval \`perl -I ~/perl5/lib/perl5 -Mlocal::lib\`" >> $HOME/.bashrc

cpanm --installdeps .

read -s -p "Continue with ENTER"
echo

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

echo
echo Making and installing atheme...
echo

# Making and installing atheme

git submodule init
git submodule update
./configure --prefix=$HOME/freenode/atheme --with-perl --disable-nls
make
make install

echo
echo "Making and installing ircd (charybdis)"
echo

# Making and installing ircd (charybdis)

cd ../ircd-seven
./configure --prefix=$HOME/freenode/ircd
make
make install

cd ..

echo
echo Copying gms configurations...
echo

# Putting configuration

cd gms
cp etc/ircd.conf $HOME/freenode/ircd/etc/
cp etc/atheme.conf $HOME/freenode/atheme/etc/
cp etc/services.db $HOME/freenode/atheme/etc/

# Running the services

echo
echo Now we will start the services. After this, connect with irc to the server,
echo do /oper admin password
echo and do /msg NickServ IDENTIFY admin password
echo

$HOME/freenode/ircd/bin/ircd
$HOME/freenode/atheme/bin/atheme-services

echo
echo Now we will install gms and \"hook\" into Atheme

read -p "Continue with ENTER" -s
echo

cd atheme
mv Makefile Makefile.old
cp Makefile.gms-auto Makefile

make
make install

echo
echo That should have worked.
echo Now, restart the atheme-services using /msg OperServ RESTART
echo Note that a normal rehash will not work.
echo

read -p "Waiting for a restart... To continue, press ENTER." -s

cd ..
bin/modify_user_roles.pl admin --add=admin --add=staff  # One day in the future, there will be also a --add=accountmanager...

echo "Now go ahead and start the gms server by running script/gms_web_server.pl"

# EOF
