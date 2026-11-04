FROM amazonlinux:2023@sha256:c04a1012acc483977f61f7f91c28624a39a621e56a59781319a75dec528be9b6

RUN dnf install -y httpd-tools && dnf clean all

COPY run-tests.sh ./