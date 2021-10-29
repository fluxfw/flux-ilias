#!/usr/bin/env php
<?php

require_once __DIR__ . "/../src/run_in_ilias.php";

run_in_ilias(function () : void {
    global $argv, $DIC;

    $user_login = $argv[1];
    $user_password = $argv[2];

    if (!ilObjUser::_loginExists($user_login)) {
        $user = new ilObjUser();

        $user->setLogin($user_login);
        $user->setFirstname($user_login);
        $user->setLastname($user_login);
        $user->setTitle($user->getFullname());

        $user->setPasswd($user_password);
        $user->setLastPasswordChangeToNow();
        $user->setPasswordPolicyResetStatus(false);
        $user->setIsSelfRegistered(true);

        $user->setActive(true);
        $user->setTimeLimitUnlimited(true);

        $user->create();
        $user->saveAsNew();

        $DIC->rbac()->admin()->assignUser(SYSTEM_ROLE_ID, $user->getId());
    } else {
        $user = new ilObjUser(ilObjUser::_lookupId($user_login));

        $user->setPasswd($user_password);
        $user->setPasswordPolicyResetStatus(false);
        $user->setIsSelfRegistered(true);

        $user->update();
    }
});
