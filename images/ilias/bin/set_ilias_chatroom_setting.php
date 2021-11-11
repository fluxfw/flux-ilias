#!/usr/bin/env php
<?php

require_once __DIR__ . "/../src/run_in_ilias.php";

run_in_ilias(function () : void {
    global $argv;

    $key = $argv[1];
    $value = $argv[2];

    if (in_array($key, ["ilias_proxy", "client_proxy"])) {
        $value = intval($value);
    }

    $chatroom_admin = new ilChatroomAdmin(current(ilObject::_getObjectsByType("chta"))["obj_id"]);
    $settings = $chatroom_admin->loadGeneralSettings();
    $settings[$key] = $value;
    $chatroom_admin->saveGeneralSettings((object) $settings);

    (new ilChatroomConfigFileHandler())->createServerConfigFile($settings);
});
