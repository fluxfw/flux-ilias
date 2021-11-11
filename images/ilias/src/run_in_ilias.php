<?php

function run_in_ilias(callable $function) : void
{
    $init = null;
    try {
        $web_dir = filter_input(INPUT_ENV, "ILIAS_WEB_DIR");
        $common_client_id = filter_input(INPUT_ENV, "ILIAS_COMMON_CLIENT_ID");
        $root_user_login = filter_input(INPUT_ENV, "ILIAS_ROOT_USER_LOGIN");
        $root_user_password = filter_input(INPUT_ENV, "ILIAS_ROOT_USER_PASSWORD");

        chdir($web_dir);
        require_once $web_dir . "/libs/composer/vendor/autoload.php";

        $init = new ilCronStartUp($common_client_id, $root_user_login, $root_user_password);
        $init->authenticate();

        $function();
    } finally {
        if ($init !== null) {
            $init->logout();
        }
    }
}
