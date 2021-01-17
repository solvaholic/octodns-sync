# Run octodns-sync with your config.

FROM python:3.7-slim
ARG image_version

LABEL name="solvaholic/octodns-sync" \
      version="${image_version}" \
      maintainer="solvaholic on GitHub"

ENV APP_UID 1501
ENV APP_GID 1501

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

COPY requirements.txt /requirements.txt
RUN chmod 644 /requirements.txt
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN groupadd -g ${APP_GID} octodns \
    && useradd -g octodns -u ${APP_UID} -M octodns
RUN /entrypoint.sh

# USER octodns
ENTRYPOINT ["/entrypoint.sh"]
