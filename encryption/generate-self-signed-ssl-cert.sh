#!/bin/bash
# Tim H 2011,2021
# Easy one-line way to generate a self-signed cert good for 365 days
# no passphrase protection for private key
# There is no root or intermediate CA used in this example
#
# Example usage:
#   ./generate-self-signed-ssl-cert.sh host1.example.com
#
# References:
#   http://www.akadia.com/services/ssh_test_certificate.html
#   https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl

CN="$1"                          # set this as the FQDN for the host that will serve this certificate
#CN='hostname.example.com'       # set this as the FQDN for the host that will serve this certificate

# make sure to use " not '
openssl req -x509 -nodes -newkey rsa:4096 -keyout "$CN-private_key.pem" -out "$CN-cert.crt" -days 365 -subj "/CN=$CN"

# view the certificate info, verify the CN
openssl x509 -text -noout -in "$CN-cert.crt"
