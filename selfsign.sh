#! /bin/bash
#
# @(!--#) @(#) selfsign.sh, version 003, 24-may-2025
#
# create a self signed certificate for the host using EasyRSA
#

set -u

EASYRSA_TAR=EasyRSA-3.2.2.tgz

########################################################################

turn2spaces() {
  spaces=`echo "$1" | sed 's/./ /g'`

  echo "$spaces"
}

########################################################################

#
# Main
#

PATH=/bin:/usr/bin
export PATH

progname=`basename $0`

username=`id | cut -d'(' -f2 | cut -d')' -f1`

if [ "$username" = "root" ]
then
  echo "$progname: do NOT run this script as root user!!!" 1>&2
  exit 2
fi

if [ "`which expect`" = "" ]
then
  echo "$progname: it does not appear that the expect command/package is present on this system" 1>&2
  echo "`turn2spaces $progname`  try installing with \"sudo apt install expect\" or similar" 1>&2
  exit 2
fi

HOSTNAME=`hostname`

REQUEST_NAME=`echo $HOSTNAME | cut -d. -f1`

CERTAUTHDIR=easy-rsa-ca

CLIENTDIR=easy-rsa-client

echo "East RSA tar gzipped filename ........: $EASYRSA_TAR"
echo "Hostname .............................: $HOSTNAME"
echo "Request name .........................: $REQUEST_NAME"
echo "Certificate Authority subdirectory ...: $CERTAUTHDIR"
echo "Client sundirectory ..................: $CLIENTDIR"

if [ ! -r $EASYRSA_TAR ]
then
  echo "$progname: the EasyRSA tar file \"$EASYRSA_TAR\" does not exist or is not readable" 1>&2
  exit
fi

for d in $CERTAUTHDIR $CLIENTDIR
do
  tar xzf $EASYRSA_TAR
  rm -rf $d
  mv EasyRSA-3.2.2 $d
  (
    cd $d
    ./easyrsa init-pki
  )
done

echo $HOSTNAME

(
  cd $CERTAUTHDIR
  ../build-ca.exp $HOSTNAME
)

(
  cd $CLIENTDIR
  ../gen-req.exp $HOSTNAME $REQUEST_NAME
  cp pki/reqs/$REQUEST_NAME.req /tmp/$REQUEST_NAME.req
)

(
  cd $CERTAUTHDIR
  ./easyrsa import-req /tmp/$REQUEST_NAME.req $REQUEST_NAME
  ../sign-req.exp $REQUEST_NAME
)

cp -p $CERTAUTHDIR/pki/ca.crt                       00_ca.crt
cp -p $CERTAUTHDIR/pki/issued/$REQUEST_NAME.crt     00_$REQUEST_NAME.crt
cp -p $CLIENTDIR/pki/private/$REQUEST_NAME.key      00_$REQUEST_NAME.key

chmod u=rw,go-rwx 00_*

for d in $CERTAUTHDIR $CLIENTDIR
do
  rm -rf $d
done

echo "**********************************************************************************************"
echo "****"
ls -l 00_* | sed 's/^/****    /g'
echo "****"
echo "**********************************************************************************************"

exit 0

# end of file: selfsign.sh
