<?php

use Symfony\Component\HttpFoundation\Request;

require __DIR__.'/../vendor/autoload.php';

$kernel = new AppKernel('prod', false);
//$kernel = new AppCache($kernel);

// When using the HttpCache, you need to call the method in your front controller instead of relying on the configuration parameter
//Request::enableHttpMethodParameterOverride();

# http://symfony.com/doc/current/deployment/proxies.html
Request::setTrustedProxies(['127.0.0.1', $_SERVER['REMOTE_ADDR']], Request::HEADER_X_FORWARDED_ALL);

$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
