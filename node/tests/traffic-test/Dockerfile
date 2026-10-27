FROM amazonlinux:2023

RUN dnf install -y httpd-tools && dnf clean all

COPY run-tests.sh ./