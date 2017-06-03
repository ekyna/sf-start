<?php

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Debug\Debug;

if (!isset($_SERVER['PHP_DOCKER_ACCESS'])) {
    header('HTTP/1.0 403 Forbidden');
    exit('You are not allowed to access this file.');
}

/**
 * @var \Composer\Autoload\ClassLoader $loader
 */
//$loader = require __DIR__.'/../app/autoload.php'; For doctrine annotations
$loader = require __DIR__.'/../vendor/autoload.php';
Debug::enable();

$kernel = new AppKernel('test', true);
$kernel->loadClassCache();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
