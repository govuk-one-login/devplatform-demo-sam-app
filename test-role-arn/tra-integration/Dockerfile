FROM debian:stable-slim
RUN apt-get update && apt-get install -y python3 python3-pip awscli
RUN pip install poetry
WORKDIR /tests/
COPY pyproject.toml poetry.lock ./
RUN poetry install
COPY ./features ./features
COPY ./behave.ini ./
COPY ./run-tests.sh /
ENTRYPOINT ["/run-tests.sh"]
