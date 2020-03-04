# Run octodns with your config.

FROM python:2-slim

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN (apt update || true) && apt install -y git
RUN pip install virtualenv && virtualenv /env
ENV VENV_NAME /env

RUN git clone --branch v0.9.9 --depth 1 https://github.com/github/octodns.git /octodns
RUN . /env/bin/activate && pip install /octodns
