# Run octodns with your config.

FROM python:3-slim

RUN (apt update || true) && apt install -y git

COPY entrypoint.sh /entrypoint.sh
COPY octodns-action.sh /octodns-action.sh
RUN chmod 755 /entrypoint.sh /octodns-action.sh

ENTRYPOINT ["/octodns-action.sh"]
