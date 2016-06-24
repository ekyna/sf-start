<?php

namespace AppBundle\Controller;

use Ekyna\Bundle\CoreBundle\Controller\Controller;

/**
 * Class FragmentController
 * @package AppBundle\Controller
 * @author Étienne Dauvergne <contact@ekyna.com>
 */
class FragmentController extends Controller
{
    /**
     * Renders the footer fragment.
     *
     * @param string $locale
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function footerAction($locale)
    {
        $this->get('request_stack')->getCurrentRequest()->setLocale($locale);

        return $this
            ->render('WebBundle:Fragment:footer.html.twig')
            ->setSharedMaxAge(3600);
    }
}
