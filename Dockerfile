# Run octodns-sync with your config.

FROM python:3.7-slim

RUN apt-get update && \
    apt-get install --no-install-recommends -y git=1:2.20.1-2+deb10u3 && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
