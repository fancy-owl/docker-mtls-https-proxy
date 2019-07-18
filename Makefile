# Makefile
#
.PHONY: default all build clean run certs docker_run docker_clean
default: all

all: run

run: docker_run

certs: server.pem client.pem

docker_run: build
	docker-compose up

build: client.pem docker_build

docker_build: server.pem
	docker-compose build

server.pem: server.key server.crt ca.crt
	@# Order matters; leaf cert -> CAs (intermediate -> root) -> key
	@cat server.crt ca.crt server.key > server.pem

client.pem: client.key client.crt ca.crt
	@# Order matters; leaf cert -> CAs (intermediate -> root) -> key
	@cat client.crt ca.crt client.key > client.pem

client.csr: client.key
	openssl req -new -key $< -out $@ \
		-subj '/C=US/ST=California/L=Inverness/O=Fancy Owl/CN=client' \

server.csr: server.key
	openssl req -new -key $< -out $@ \
		-subj '/C=US/ST=California/L=Inverness/O=Fancy Owl/CN=localhost' \

ca.crt: ca.key
	openssl req -new -x509 -days 7 \
		-subj '/C=US/ST=California/L=Inverness/O=Fancy Owl' \
		-key $< -out $@

%.crt: %.csr ca.crt ca.key
	openssl x509 -req -days 6 -in $< -CA ca.crt -CAkey ca.key -set_serial 01 -out $@

%.key:
	openssl genrsa -out $@ 4096

clean:
	docker-compose down
	docker images proxy:latest -q | xargs docker rmi
	docker images stunnel:latest -q | xargs docker rmi

distclean: clean
	rm -f *.key *.csr *.crt *.pem
	docker images alpine:3.10 -q | xargs docker rmi
