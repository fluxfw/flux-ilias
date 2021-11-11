#!/usr/bin/env php
<?php

function config(array $template_config, array $config, string $parent_key) : ?array
{
    foreach ($template_config as $current_key => $default_value) {
        $key = $parent_key . "_" . strtoupper($current_key);

        $value = $config[$current_key] ?? null;

        if (is_array($default_value)) {
            $config[$current_key] = config($default_value, $value ?? [], $key);
        } else {
            $env_value = filter_input(INPUT_ENV, $key);
            if ($env_value !== null) {
                if (in_array($key, [
                    "ILIAS_BACKGROUNDTASKS_MAX_NUMBER_OF_CONCURRENT_TASKS",
                    "ILIAS_CHATROOM_PORT",
                    "ILIAS_DATABASE_PORT",
                    "ILIAS_HTTP_PROXY_PORT",
                    "ILIAS_VIRUSSCANNER_ICAP_PORT",
                    "ILIAS_WEBSERVICES_RPC_SERVER_PORT"
                ])
                ) {
                    $env_value = intval($env_value);
                }

                if (in_array($key, [
                    "ILIAS_COMMON_REGISTER_NIC",
                    "ILIAS_DATABASE_CREATE_DATABASE",
                    "ILIAS_LOGGING_ENABLE",
                    "ILIAS_PRIVACYSECURITY_HTTPS_ENABLED",
                    "ILIAS_STYLE_MANAGE_SYSTEM_STYLES",
                    "ILIAS_WEBSERVICES_SOAP_USER_ADMINISTRATION"
                ])
                ) {
                    $env_value = $env_value === "true";
                }

                $config[$current_key] = $env_value;
            }
        }

        if ($config[$current_key] === null) {
            unset($config[$current_key]);
        }

        if (in_array($key, [
                "ILIAS_GLOBALCACHE_COMPONENTS",
                "ILIAS_LANGUAGE_INSTALL_LANGUAGES",
                "ILIAS_LANGUAGE_INSTALL_LOCAL_LANGUAGES"
            ])
            && is_string($config[$current_key])
            && ($key === "ILIAS_GLOBALCACHE_COMPONENTS" ? $config[$current_key] !== "all" : true)
        ) {
            $config[$current_key] = explode(" ", $config[$current_key]);
        }

        if (in_array($key, [
                "ILIAS_GLOBALCACHE_MEMCACHED_NODES"
            ])
            && is_string($config[$current_key])
        ) {
            $config[$current_key] = json_decode($config[$current_key], true) ?? [];
        }
    }

    if (empty($config)) {
        $config = null;
    }

    return $config;
}

$template_config = json_decode(file_get_contents(__DIR__ . "/../src/template_config.json"), true);

$config_file = filter_input(INPUT_ENV, "ILIAS_CONFIG_FILE");

if (file_exists($config_file)) {
    $config = json_decode(file_get_contents($config_file), true) ?? [];
} else {
    $config = [];
}

$config = config($template_config, $config, "ILIAS") ?? [];

file_put_contents($config_file, json_encode($config, JSON_UNESCAPED_SLASHES + JSON_PRETTY_PRINT));
