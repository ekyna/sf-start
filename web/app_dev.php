<?php

use Symfony\Component\Debug\Debug;
use Symfony\Component\HttpFoundation\Request;

if (!isset($_SERVER['PHP_DOCKER_ACCESS'])) {
    header('HTTP/1.0 403 Forbidden');
    exit('You are not allowed to access this file.');
}

/**
 * @var Composer\Autoload\ClassLoader $loader
 */
require __DIR__.'/../vendor/autoload.php';
Debug::enable();

# http://symfony.com/doc/current/deployment/proxies.html
Request::setTrustedProxies(['127.0.0.1', $_SERVER['REMOTE_ADDR']], Request::HEADER_X_FORWARDED_ALL);

$kernel = new AppKernel('dev', true);
$kernel->loadClassCache();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
