# ILIAS cron image

This image is based on [ILIAS php-fpm image](../ilias) but will run the cron service

A second variant exits based on [ILIAS development php-fpm image](../ilias-dev)

The follow PHP versions are available

- 7.2
- 7.3
- 7.4
- 8.0 (For development purposes only, ILIAS doesn't support yet)

The cron config is automatic generated based set the follow environment variables

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_CRON_FILE | Path to crontab file | /etc/periodic/ilias |
| ILIAS_CRON_LOG_FILE | Path to log file<br>Means only stoutput and sterror | *%ILIAS_LOG_DIR%*/cron.log |
| ILIAS_CRON_PERIOD | Period the cron job is run<br>Default value means every 5th minute | */5 * * * * |

Minimal variables required to set are **bold**

In order to make work you need also set `ILIAS_CRON_USER_PASSWORD` (More infos at the [ILIAS php-fpm image](../ilias))
