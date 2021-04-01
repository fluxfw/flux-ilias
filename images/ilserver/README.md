# ILIAS ilserver image

The follow Java versions are available

- 8

The ilserver config is automatic generated based set the follow environment variables

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| ILIAS_COMMON_CLIENT_ID | Client name | default |
| ILIAS_FILESYSTEM_DATA_DIR | Path to data directory<br>This is a volume | /var/iliasdata |
| ILIAS_FILESYSTEM_INI_PHP_FILE | Path to ILIAS ini file | *%ILIAS_FILESYSTEM_DATA_DIR%*/ilias.ini.php |
| ILIAS_WEB_DIR | Path to ILIAS source code<br>This is a volume | /var/www/html |
| ILIAS_ILSERVER_INDEX_MAX_FILE_SIZE | Maximal file size (MB) | 500 |
| ILIAS_ILSERVER_INDEX_PATH | Path to index directory | *%ILIAS_FILESYSTEM_DATA_DIR%*/ilserver |
| ILIAS_ILSERVER_IP_ADDRESS | Listen IP | 0.0.0.0 |
| ILIAS_ILSERVER_LOG_DIR | Path to log directory<br>This is a volume | /var/log/ilserver |
| ILIAS_ILSERVER_LOG_FILE | Path to log file | *%ILIAS_ILSERVER_LOG_DIR%*/ilserver.log |
| ILIAS_ILSERVER_LOG_LEVEL | Log level | INFO |
| ILIAS_ILSERVER_NIC_ID | NIC registration ID | 0 |
| ILIAS_ILSERVER_NUM_THREADS | Number of threads | 1 |
| ILIAS_ILSERVER_PORT | Listen port | 11111 |
| ILIAS_ILSERVER_PROPERTIES_PATH | Path to config file | *%ILIAS_FILESYSTEM_DATA_DIR%*/ilserver.properties |
| ILIAS_ILSERVER_RAM_BUFFER_SIZE | RAM buffer size (MB) | 256 |

Minimal variables required to set are **bold**
