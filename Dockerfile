# Run octodns with your config.

FROM python:3-alpine

RUN apk -U upgrade; apk add git

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
