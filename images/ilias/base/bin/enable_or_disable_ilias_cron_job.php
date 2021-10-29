#!/usr/bin/env php
<?php

require_once __DIR__ . "/../src/run_in_ilias.php";

run_in_ilias(function () : void {
    global $argv;

    $cron_job_id = $argv[1];
    $value = $argv[2];

    $cron_job = ilCronManager::getJobInstanceById($cron_job_id);

    if ($value) {
        ilCronManager::activateJob($cron_job);
    } else {
        ilCronManager::deactivateJob($cron_job);
    }
});
