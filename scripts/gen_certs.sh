#!/usr/bin/env bash

commonName=$2

if [ "${commonName}" == "" ]
then
  commonName="SiriProxyCA"
fi

# Feel free to change any of these defaults
countryName="US"
stateOrProvinceName="Missouri"
localityName=""
organizationName="Siri Proxy"
organizationalUnitName=""
emailAddress=""

#You probably don't need to modify these unless you know what you're doing.
SIRI_PROXY_ROOT=$1
SIRI_PROXY_SETTINGS=~/.siriproxy
LOG_FILE=$SIRI_PROXY_SETTINGS/cert.log
TMP_DIR=/tmp
TMP_CA_DIR=/tmp/siriCA #THIS ($dir) ALSO MUST BE MODIFIED IN openssl.cnf IF YOU CHANGE IT!

## Do not edit below here!

echo "" > $LOG_FILE

echo "Creating CA directory"
mkdir -p $TMP_CA_DIR/{certs,crl,newcerts,private}
touch $TMP_CA_DIR/index.txt
echo 01 > $TMP_CA_DIR/crtnumber

echo "Generating '${commonName}' CA request"
echo "${countryName}" > $TMP_DIR/ca.args
echo "${stateOrProvinceName}" >> $TMP_DIR/ca.args
echo "${localityName}" >> $TMP_DIR/ca.args
echo "${organizationName}" >> $TMP_DIR/ca.args
echo "${organizationalUnitName}" >> $TMP_DIR/ca.args
echo "${commonName}" >> $TMP_DIR/ca.args
echo "${emailAddress}" >> $TMP_DIR/ca.args
echo "" >> $TMP_DIR/ca.args
echo "" >> $TMP_DIR/ca.args

cat $TMP_DIR/ca.args | openssl req -new -config $SIRI_PROXY_ROOT/scripts/openssl.cnf -keyout $TMP_CA_DIR/private/cakey.pem -out $TMP_CA_DIR/careq.pem -passin pass:1234 -passout pass:1234 >> $LOG_FILE 2>> $LOG_FILE

echo "Self-signing '${commonName}' CA"
openssl ca -create_serial -passin pass:1234 -config $SIRI_PROXY_ROOT/scripts/openssl.cnf -out $TMP_CA_DIR/cacert.pem -outdir $TMP_CA_DIR/newcerts -days 1095 -batch -keyfile $TMP_CA_DIR/private/cakey.pem -selfsign -extensions v3_ca -infiles $TMP_CA_DIR/careq.pem >> $LOG_FILE 2>> $LOG_FILE

echo "Generating guzzoni.apple.com certificate request"
echo "Generating '${commonName}' CA request"
echo "${countryName}" > $TMP_DIR/ca.args
echo "${stateOrProvinceName}" >> $TMP_DIR/ca.args
echo "${localityName}" >> $TMP_DIR/ca.args
echo "${organizationName}" >> $TMP_DIR/ca.args
echo "${organizationalUnitName}" >> $TMP_DIR/ca.args
echo "guzzoni.apple.com" >> $TMP_DIR/ca.args
echo "${emailAddress}" >> $TMP_DIR/ca.args
echo "" >> $TMP_DIR/ca.args
echo "" >> $TMP_DIR/ca.args
cat $TMP_DIR/ca.args | openssl req -new -keyout $TMP_DIR/newkey.pem -config $SIRI_PROXY_ROOT/scripts/openssl.cnf -out $TMP_DIR/newreq.pem -days 1095 -passin pass:1234 -passout pass:1234 >> $LOG_FILE 2>> $LOG_FILE

echo "Generating guzzoni.apple.com certificate"
yes | openssl ca -policy policy_anything -out $TMP_DIR/newcert.pem -config $SIRI_PROXY_ROOT/scripts/openssl.cnf -passin pass:1234 -keyfile $TMP_CA_DIR/private/cakey.pem -cert $TMP_CA_DIR/cacert.pem -infiles $TMP_DIR/newreq.pem >> $LOG_FILE 2>> $LOG_FILE

echo "Removing passphrase from guzzoni.apple.com key"
yes | openssl rsa -in $TMP_DIR/newkey.pem -out $SIRI_PROXY_SETTINGS/server.passless.key -passin pass:1234 >> $LOG_FILE 2>> $LOG_FILE

echo "Cleaning up..."
mv $TMP_DIR/newcert.pem $SIRI_PROXY_SETTINGS/server.passless.crt
mv $TMP_CA_DIR/cacert.pem $SIRI_PROXY_SETTINGS/ca.pem
rm -rf $TMP_DIR/new{key,req}.pem $TMP_CA_DIR $TMP_DIR/ca.args

echo "Done! (For details on any errors, check '${LOG_FILE}')"
echo "-------------------------------------------------------------"
echo ""
echo "Please install ${SIRI_PROXY_SETTINGS}/ca.pem onto your phone!"
echo "(Note: You can do this by emailing the file to yourself)"
echo ""
echo "-------------------------------------------------------------"