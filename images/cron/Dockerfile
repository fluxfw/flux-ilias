ARG ILIAS_IMAGE
FROM $ILIAS_IMAGE

COPY . /FluxIliasCron

ENTRYPOINT ["/FluxIliasCron/bin/entrypoint.sh"]

ENV ILIAS_CRON_FILE /etc/periodic/ilias
ENV ILIAS_CRON_PERIOD */5 * * * *
