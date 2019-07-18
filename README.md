# docker-mtls-https-proxy

Demonstration of a forwarding https proxy setup where the proxy server requires
a client TLS certificate to be presented as authentication to be allowed to
connect and have outbound traffic be carried.

## Requires:

- GNUMake
- curl
- docker with ocker-compose
- access to the webber'nets

## Usage

### Create the Certificate Authority, Server, Client Certs, and docker images

`$ make build`

### Start the service(s)

`$ make run`

### Run the simulation (in a separate window)

Uses the proxy to HTTP GET http(s)://ipv4.icanhazip.com

Expected output:

```
$ ./test.sh
******

This should fail; no client cert spec'd
curl: (35) error:1401E410:SSL routines:CONNECT_CR_FINISHED:sslv3 alert handshake failure

******

This should fail; no client private key spec'd
curl: (58) unable to set private key file: 'client.crt' type PEM

******

This should pass; client cert and key in separate files
199.208.64.3

******

This should pass; combined client cert and key
199.208.64.3

******

$
```

## Note

If docker isn't your thing, it should be easy enough to adapt/run on a
conventional Linux host
