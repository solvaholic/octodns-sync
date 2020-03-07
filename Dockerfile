# Run octodns with your config.

FROM python:3-slim

RUN (apt update || true) && apt install -y git
RUN pip install virtualenv && virtualenv /env
ENV VENV_NAME /env

RUN git clone --branch v0.9.9 --depth 1 https://github.com/github/octodns.git /octodns
RUN . /env/bin/activate && pip install /octodns

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
