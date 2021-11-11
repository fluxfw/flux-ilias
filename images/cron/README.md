# ILIAS cron image

The follow environment variables are available

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_CRON_FILE | Path to crontab file | /etc/periodic/ilias |
| ILIAS_CRON_PERIOD | Period the cron job is run<br>Default value means every 5th minute | */5 * * * * |

Minimal variables required to set are **bold**
