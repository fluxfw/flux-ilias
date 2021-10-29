ARG ILIAS_IMAGE
FROM $ILIAS_IMAGE

COPY . /FluxIliasCron

ENTRYPOINT ["/FluxIliasCron/bin/entrypoint.sh"]

ENV ILIAS_CRON_FILE /etc/periodic/ilias
ENV ILIAS_CRON_LOG_FILE $ILIAS_LOG_DIR/cron.log
ENV ILIAS_CRON_PERIOD */5 * * * *
