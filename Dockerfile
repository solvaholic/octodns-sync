# Run octodns with your config.

FROM python:3-slim

RUN apt update && apt install -y git && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
