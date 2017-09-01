#!/bin/bash
#
# Client script for Short-Lived Credential Service interface based on openssl and
# curl
#
# @author P J Kershaw 25/05/2010
#
# @copyright: (C) 2010 STFC
#
# @license: BSD - See top-level LICENCE file for licence details
#
# $Id$
cmdname=$(basename $0)
cmdline_opt=`getopt hU:l:So:c:C:k:n $*`

usage="Usage: $cmdname [-U Online CA Service URI][-l username] ...\n
\n
   Options\n
       -h\t\t\tDisplays usage\n
       -U <uri>\t\tShort-Lived Credential Service URI\n
       -l <username>\t\tUsername for the delegated credential (defaults to \$LOGNAME)\n
       -S\t\t\tpass password from stdin rather prompt from tty\n
       -n\t\t\tsend null password (for advanced use with SSL client authentication)\n
       -o <file path>\t\tOutput location of end entity certificate (default to stdout)\n
       -c <directory path>\tDirectory containing the trusted CA (Certificate Authority) certificates.  These are used to\n
       \t\t\tverify the identity of the Online CA Web Service.  Defaults to\n 
       \t\t\t${HOME}/.globus/certificates or\n
       \t\t\t/etc/grid-security/certificates if running as root.\n
       -C <file path>\t\tPath to file containing client certificate or client certificate and private key.  These are\n
       \t\t\tused to enable optional SSL authentication with peer.\n
       -k <file path>\t\tPath to client private key to use for SSL authentication with peer.  This is optional.\n
"

if [ $? != 0 ] ; then
    echo -e $usage >&2 ;
    exit 1 ;
fi

set -- $cmdline_opt

# Initialise SSL client cert and key options
clientcert_opt=
clientkey_opt=

while true ; do
    case "$1" in
        -h) echo -e $usage ; exit 0 ;;
        -U) uri=$2 ; shift 2 ;;
        -l) username=$2 ; shift 2 ;;
        -S) stdin_pass=True ; shift 1 ;;
        -n) null_password=True ; shift 1 ;;
        -o) outfilepath=$2 ; shift 2 ;;
        -c) cadir=$2 ; shift 2 ;;
        -C) clientcert_opt="--cert $2" ; shift 2 ;;
        -k) clientkey_opt="--key $2" ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Error parsing command line" ; exit 1 ;;
    esac
done

if [ -z $uri ]; then
    echo -e Give the URI for the Short-Lived Credential Service get certificate request;
    echo -e $usage >&2 ;
    exit 1;
fi

# Default to LOGNAME if not set on command line
if [ -z $username ]; then
    username=${LOGNAME}
fi

# Set password
if [ $stdin_pass ] && [ $null_password ]; then
    echo "Cannot set both -S and -n options" >&2;
    echo -e $usage >&2;
    exit 1;
    
elif [ $stdin_pass ]; then
    read password;
    
elif [ $null_password ]; then
    password="";
else
    stty -echo
    read -p "Enter pass phrase: " password; echo
    stty echo
fi

# Set-up trust root
if [ -z $cadir ]; then
  if [ ${X509_CERT_DIR} ]; then
      cadir=${X509_CERT_DIR}
  elif [ "$username" = "root" ]; then
      cadir=/etc/grid-security/certificates
  else
      cadir=${HOME}/.globus/certificates
  fi
fi

# Set output file path
if [ -z $outfilepath ]; then
    if [ ${X509_USER_PROXY} ]; then
        outfilepath=${X509_USER_PROXY}
    else
        # Default to stdout
        outfilepath=/dev/stdout
    fi
fi
    
# Make a temporary file location for the certificate request
certreqfilepath="/tmp/$UID-$RANDOM.csr"

# Generate key pair and request.  The key file is written to the 'key' var
key=$(openssl req -new -newkey rsa:2048 -nodes -keyout /dev/stdout -subj /CN=dummy -out $certreqfilepath 2> /dev/null)

# Post request to Short-Lived Credential Service passing username/password for HTTP Basic
# auth based authentication.  
# 
# Nb. Earlier versions of curl don't support --data-urlencode so use this 
# workaround instead...

# Alterations to change Base 64 encoding to URL safe Base 64
encoded_certreq=$(cat $certreqfilepath|sed s/+/%2B/g)

response=$(curl $uri --insecure --tlsv1 -u $username:$password --data "certificate_request=$encoded_certreq" --capath $cadir -w " %{http_code}" -s -S $clientcert_opt $clientkey_opt)

responsemsg=$(echo "$response"|sed '$s/ *\([^ ]* *\)$//')
responsecode=$(echo $response|awk '{print $NF}')
if [ "$responsecode" != "200" ]; then
    echo "Online CA server returned error code $responsecode:" >&2
    echo "$responsemsg" >&2
    exit 1
fi

# Simple sanity check on response
if [[ $responsemsg != -----BEGIN\ CERTIFICATE-----* ]]; then
    echo "Expecting certificate in response; got:"
    echo "$responsemsg" >&2
    exit 1
fi

# Output certificate
echo "$responsemsg" > $outfilepath

# Add key 
echo "$key" >> $outfilepath
