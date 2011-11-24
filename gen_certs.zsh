#!/usr/bin/env zsh


# Feel free to change any of these defaults
countryName="UK"
stateOrProvinceName="England"
localityName=""
organizationName="Siri Proxy"
organizationalUnitName=""
commonName="SiriProxy"
emailAddress=""

## Do not edit below here!
echo "Ok, before we get going you need to know a few things"
echo "You're about to be asked four questions, the answers are: 1234, 1234, y, y"
echo -n "Hit return to continue!"; read -e

mkdir -p demoCA/{certs,crl,newcerts,private}
touch demoCA/index.txt
echo 01 > demoCA/crtnumber

CAREQARGS="${countryName}\n${stateOrProvinceName}\n${localityName}\n${organizationName}\n${organizationalUnitName}\n${commonName}\n${emailAddress}\n\n\n"
echo -n $CAREQARGS | openssl req -new -keyout demoCA/private/cakey.pem -out demoCA/careq.pem -passin pass:1234 -passout pass:1234
openssl ca -create_serial -out demoCA/cacert.pem -days 1095 -batch -keyfile demoCA/private/cakey.pem -selfsign -extensions v3_ca -infiles demoCA/careq.pem

CRTREQARGS="${countryName}\n${stateOrProvinceName}\n${localityName}\n${organizationName}\n${organizationalUnitName}\nguzzoni.apple.com\n${emailAddress}\n\n\n"
echo $CRTREQARGS | openssl req -new -keyout newkey.pem -out newreq.pem -days 1095 -passin pass:1234 -passout pass:1234
openssl ca -policy policy_anything -out newcert.pem -infiles newreq.pem
openssl rsa -in newkey.pem -out server.passless.key -passin pass:1234

mv newcert.pem server.passless.crt
mv demoCA/cacert.pem ca.pem
rm -rf new{key,req}.pem demoCA
