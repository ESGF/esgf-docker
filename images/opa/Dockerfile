Analyzing openpolicyagent/opa:latest
Docker Version: 19.03.13+azure
GraphDriver: overlay2
Environment Variables
|PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
|SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

Image user
|Image is running as User: 0

Potential secrets:
Dockerfile:
bazel build ...
bazel build ...
ARG USER=0
MAINTAINER Torin Sandall <torinsandall@gmail.com>
USER 0
ARG BIN_DIR=.
COPY file:b612d99e332a1635f64b79505e369ddddb098047706a76b0c4c189454b202270 in /opa
	opa

COPY file:7b8ab9dc85e4fbf7178cc1ff090a4edaccdefc7d632593eb78fd2e0c2643cfdb in /usr/lib/opa/libwasmer.so
	usr/
	usr/lib/
	usr/lib/opa/
	usr/lib/opa/libwasmer.so

ENTRYPOINT ["/opa"]
CMD ["run"]

