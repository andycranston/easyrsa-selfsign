# easyrsa-selfsign - create a selfsigned TLS certicate using EasyRSA version 3.2.2

## Pre-requisite - expect

The `expect` command/package must be installed. If using a package manager then something like
one of the following:

+ sudo apt install expect
+ sudo dnf install expect

If compiling `expect` (and the dependency `tcl`) from source make sure the expect
command is in a directory in the PATH (e.g. `/usr/local/bin/expect`).

## Pre-reqsuite - bc

The `bc` command ("an arbitrary precision calculator language") should be available:

Run:

```
which bc
```

If the output from this command is NOT:

```
/usr/bin/bc
```

then install the `bc` package. One of:

+ sudo apt install bc
+ sudo dnf install bc

or whatever package manager you are using.

## Pre-requsite - hostname is a fully qualified domain name

The hostname of the system must be a fully qualified domain name such as:

```
darkstar.example.com
```

## Quick start

After cloning the `easyrsa-selfsign` repo download the file:

```
EasyRSA-3.2.2.tgz
```

from this git repo:

```
https://github.com/OpenVPN/easy-rsa/releases/tag/v3.2.2
```

and put it in the same directory.

Then run:

```
./selfsign.sh
```

The output will be quite long but the last few lines should be similar to:

```
Write out database with 1 new entries
Database updated

WARNING
=======
INCOMPLETE Inline file created:
* /home/localadm/selfsign/easy-rsa-ca/pki/inline/ldapper.inline


Notice
------
Certificate created at:
* /home/localadm/selfsign/easy-rsa-ca/pki/issued/ldapper.crt

**********************************************************************************************
****
****    -rw-------. 1 localadm localadm 1233 May 25 11:21 00_ca.crt
****    -rw-------. 1 localadm localadm 4552 May 25 11:21 00_ldapper.crt
****    -rw-------. 1 localadm localadm 1704 May 25 11:21 00_ldapper.key
****
**********************************************************************************************
```

The warning "INCOMPLETE Inline file created" can be safely ignored.

The three files:

```
00_ca.crt
00_ldapper.crt
00_ldapper.key
```

have been created. Descriptions are:

+ `00_ca.crt` is the certificate for the Certificate Authority which signed the certificate file
+ `00_ldapper.crt` is the certificate file which has been signed
+ `00_ldapper.key` is the key for the 00_ldapper.crt certificate file

Note that the `00_ldapper.key` file does NOT have a password so it must be protected
from prying eyes/programs. A file mode of "-rw-------" is a good start but take care when 
copying/moving the file to a different location either on the same system or a remote system.

These three files can now be used for an application requiring a certificate and you are happy that
a self-signed cerificate is suitable. For example I have a test OpenLDAP server (version 2.5.19)
and I have a directory `/usr/local-local/openldap/ldapcerts`
which contains the three files:

```
00_ca.crt
00_ldapper.crt
00_ldapper.key
```

In the `slapd.conf` file I added the following three lines:

```
TLSCACertificateFile /usr/local-local/openldap/ldapcerts/00_ca.crt
TLSCertificateFile /usr/local-local/openldap/ldapcerts/00_ldapper.crt
TLSCertificateKeyFile /usr/local-local/openldap/ldapcerts/00_ldapper.key
```

Secure LDAP over port 636 with TLS is now possible.

## Full output of a selfsign.sh run

Here is the full output of a run of the `selfsign.sh` script on a host called `ldapper.matrix.lab`:

```
East RSA tar gzipped filename ........: EasyRSA-3.2.2.tgz
Hostname .............................: ldapper.matrix.lab
Request name .........................: ldapper
Certificate Authority subdirectory ...: easy-rsa-ca
Client sundirectory ..................: easy-rsa-client

Notice
------
'init-pki' complete; you may now create a CA or requests.

Your newly created PKI dir is:
* /home/localadm/selfsign/easy-rsa-ca/pki

Using Easy-RSA configuration:
* undefined

Notice
------
'init-pki' complete; you may now create a CA or requests.

Your newly created PKI dir is:
* /home/localadm/selfsign/easy-rsa-client/pki

Using Easy-RSA configuration:
* undefined
ldapper.matrix.lab
Common Name (CN) ....: ldapper.matrix.lab
spawn ./easyrsa build-ca

Enter New CA Key Passphrase: Passw0rd!


Confirm New CA Key Passphrase: Passw0rd!

.......+....+.....+...+....+...........+....+......+...+++++++++++++++++++++++++++++++++++++++*..............+......+...+.+++++++++++++++++++++++++++++++++++++++*...+................+...+..+.+...+.....+....+..+...+.+......+...........+.......+.....+.......+........+.............+..+..........+...........+......+.............+..+.+............+..+...+.+......+......+..+.+....................+.+.....+....+..+....+...........+...+.+...........+..........+...+..+.......+..+....+..+...............+.......+..+........................++++++
....+...+........+.........+.............+++++++++++++++++++++++++++++++++++++++*.+..+...................+..+....+.....+.+.....+.......+..+.+.................+.+..+.........+....+..+............+...............+......+......+.+...+......+...+..+.+.....+...+....+......+..+...+.........+.+..+++++++++++++++++++++++++++++++++++++++*......+...................+.....+....+...+.....+...+...............+....+...+..+.+..+.......+.....+.......+......+..+...+...+.+.....+...+................+......+..............+.+.........+..+.......+........+............+.+..+....+...+...+.....+.............+.....+.......+...+...........+...+..........+..+.+..............++++++
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:ldapper.matrix.lab

Notice
------
CA creation complete. Your new CA certificate is at:
* /home/localadm/selfsign/easy-rsa-ca/pki/ca.crt

Create an OpenVPN TLS-AUTH|TLS-CRYPT-V1 key now: See 'help gen-tls'

Build-ca completed successfully.

Common Name (CN) ....: ldapper.matrix.lab
Request Name ........: ldapper
spawn ./easyrsa --nopass gen-req ldapper
..+.+.....+++++++++++++++++++++++++++++++++++++++*......+++++++++++++++++++++++++++++++++++++++*.....+.....+......+.+......+...+.....+.+.....+......+..................+.+.....+.+...+.....+......+.+..+..........+...........+.+......+..+............+...+......+......+....+..+....+..............+.+...+..+......+...+....+........+....+.........+..+....+...........+...+......+.+..............+...+.+.........+..+.+.............................+....+.........+..................+.....+....+...+...+.........+..............+.+.....+.............+...+.....+.........+...+..........+..+..........+...+...+..+.+..+...+.........+.......+.........+.....+....+..................+................................+.+.....+..........+......+......+...+..............+.+..+.........+.........+.++++++
............+..+.+..+.......+......+............+++++++++++++++++++++++++++++++++++++++*..+..+.+..............+.............+...+..............+.......+......+++++++++++++++++++++++++++++++++++++++*...+..+............+.+...+...............+..+....+.....+....+.........+........+.............+.....+.++++++
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [ldapper]:ldapper.matrix.lab

Notice
------
Private-Key and Public-Certificate-Request files created.
Your files are:
* req: /home/localadm/selfsign/easy-rsa-client/pki/reqs/ldapper.req
* key: /home/localadm/selfsign/easy-rsa-client/pki/private/ldapper.key


Notice
------
Request successfully imported with short-name: ldapper
This request is now ready to be signed.

Request Name (CN) ...: ldapper
spawn ./easyrsa sign-req client ldapper
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.
You are about to sign the following certificate:

  Requested CN:     'ldapper.matrix.lab'
  Requested type:   'client'
  Valid for:        '825' days


subject=
    commonName                = ldapper.matrix.lab

Type the word 'yes' to continue, or any other input to abort.
  Confirm requested details: yes

Using configuration from /home/localadm/selfsign/easy-rsa-ca/pki/4b354a44/temp.1.1
Enter pass phrase for /home/localadm/selfsign/easy-rsa-ca/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'ldapper.matrix.lab'
Certificate is to be certified until Aug 28 10:30:45 2027 GMT (825 days)

Write out database with 1 new entries
Database updated

WARNING
=======
INCOMPLETE Inline file created:
* /home/localadm/selfsign/easy-rsa-ca/pki/inline/ldapper.inline


Notice
------
Certificate created at:
* /home/localadm/selfsign/easy-rsa-ca/pki/issued/ldapper.crt

**********************************************************************************************
****
****    -rw-------. 1 localadm localadm 1233 May 25 11:30 00_ca.crt
****    -rw-------. 1 localadm localadm 4552 May 25 11:30 00_ldapper.crt
****    -rw-------. 1 localadm localadm 1704 May 25 11:30 00_ldapper.key
****
**********************************************************************************************
```

---------------
End of Document
