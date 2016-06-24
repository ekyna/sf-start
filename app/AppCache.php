<?php

require_once __DIR__.'/AppKernel.php';

use Symfony\Bundle\FrameworkBundle\HttpCache\HttpCache;
class AppCache extends HttpCache {}

/*use FOS\HttpCacheBundle\SymfonyCache\EventDispatchingHttpCache;
class AppCache extends EventDispatchingHttpCache {}*/
