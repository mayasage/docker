# Self-Signed Certificate

```shell
mkdir -p certs

openssl req \ # generate self-signed certificates for use as root CAs
	-newkey \ # generate new key...
		rsa:4096 \ # using algo
		-noenc \ # dont encrypt private key
		-sha256 \ # hash the generated key with this algo
		-keyout certs/domain.key
	-addext \ # add this extension to certificate (if -x509 is in use)
		"subjectAltName = DNS:myregistry.domain.com" \
	-x509 \ # output test certificate instead of certificate request
		-days 365 \
		-out certs/domain.crt

```
