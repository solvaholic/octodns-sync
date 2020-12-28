# Run octodns-sync with your config.

FROM python:3.7-slim

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

COPY requirements.txt /requirements.txt

RUN /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
