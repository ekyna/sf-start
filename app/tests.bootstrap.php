<?php

// app/tests.bootstrap.php
if (isset($_ENV['BOOTSTRAP_CLEAR_CACHE_ENV'])) {

    // Clear test image directory.
    passthru(sprintf('rm -Rf %s/../test', __DIR__));

    function runCommand($cmd, $exitOnFailure = true) {
        passthru(sprintf(
            '/usr/bin/php "%s/console" %s --env=%s --no-debug --no-interaction -q',
            __DIR__,
            $cmd,
            $_ENV['BOOTSTRAP_CLEAR_CACHE_ENV']
        ), $return);

        if (0 !== $return && $exitOnFailure) {
            echo "\n" . sprintf('Command "%s" failed.', $cmd) . "\n";
            exit();
        }
    }

    // Clear cache
    runCommand('cache:clear --no-warmup');

    // Drop/Create database
    runCommand('doctrine:database:drop --force', false);
    runCommand('doctrine:database:create');

    // Drop Schema
    //runCommand('doctrine:schema:drop --force');

    // Create Schema
    runCommand('doctrine:schema:create');

    // Bundles installation
    runCommand('ekyna:install');

    // Fake super admin
    runCommand('ekyna:admin:create-super-admin admin@example.org admin John Doe');

    // Fake user
    runCommand('ekyna:user:create user@example.org user Jane Doe');

    // Load fixtures
    runCommand('doctrine:fixtures:load --append');
}

require __DIR__.'/bootstrap.php.cache';