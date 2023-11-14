#!/usr/bin/sh

################################  Error handling  ##############################

if [ $# -eq 0 ]; then
  echo "Pass destination directory path as argument"
  exit 1
fi

if ! ls "$1"; then
  exit 1
fi

##################################   Main  #####################################

CERT_PATH="$1"/certs
DOCKER_CERT_PATH=/etc/docker/certs.d/myregistrydomain.com:5000

mkdir -p "$CERT_PATH"

openssl req `# generate self-signed certificates for use as root CAs` \
  -newkey `# generate new key...` \
  rsa:4096 `# using algo` \
  -nodes `# dont encrypt private key, use -noenc since openssl 3.0` \
  -sha256 `# hash the generated key with this algo` \
  -keyout "$CERT_PATH"/domain.key \
  -addext `# add this extension to certificate (if -x509 is in use)` \
  "subjectAltName = DNS:myregistry.domain.com" \
  -x509 `# output test certificate instead of certificate request` \
  -days 365 \
  -out "$CERT_PATH"/domain.crt

cd "$CERT_PATH" || exit

docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)":/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 443:443 \
  registry:2

sudo mkdir -p "$DOCKER_CERT_PATH"
sudo cp "$(pwd)"/domain.crt "$DOCKER_CERT_PATH"/ca.crt

# Trust Service at the OS level if there is still error
# cp certs/domain.crt /usr/local/share/ca-certificates/myregistrydomain.com.crt
# update-ca-certificates

# Undo update-ca-certificate
# delete /usr/local/share/ca-certificates/myregistrydomain.com.crt
# run update-ca-certificates -f
