# Run octodns with your config.

FROM python:3-slim

RUN (apt update || true) && apt install -y git
RUN pip3 install virtualenv && virtualenv /env
ENV VENV_NAME /env

RUN git clone --branch v0.9.9 --depth 1 https://github.com/github/octodns.git /octodns
RUN . /env/bin/activate && pip3 install /octodns

COPY entrypoint.sh /entrypoint.sh
COPY octodns-action.sh /octodns-action.sh
RUN chmod 755 /entrypoint.sh /octodns-action.sh

ENTRYPOINT ["/entrypoint.sh"]
