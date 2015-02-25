<?php

namespace AppBundle\Controller;

use Ekyna\Bundle\CoreBundle\Controller\Controller;

/**
 * Class LayoutController
 * @package AppBundle\Controller
 * @author Étienne Dauvergne <contact@ekyna.com>
 */
class LayoutController extends Controller
{
    /**
     * Renders the footer.
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function footerAction()
    {
        $response = $this->render('WebBundle:Layout:footer.html.twig');

        return $this->configureSharedCache($response);
    }
}
