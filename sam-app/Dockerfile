FROM amazonlinux:2

RUN yum install -y awscli

WORKDIR /test
COPY test.sh ./

ENTRYPOINT ["/test/test.sh"]
