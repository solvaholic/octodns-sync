# Run octodns with your config.

FROM python:3-alpine

RUN apk -U upgrade; apk add git

COPY entrypoint.sh /entrypoint.sh
COPY octodns-action.sh /octodns-action.sh
RUN chmod 755 /entrypoint.sh /octodns-action.sh

ENTRYPOINT ["/octodns-action.sh"]
