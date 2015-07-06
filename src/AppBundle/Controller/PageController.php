<?php

namespace AppBundle\Controller;

use Ekyna\Bundle\CoreBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Class PageController
 * @package AppBundle\Controller
 * @author Étienne Dauvergne <contact@ekyna.com>
 */
class PageController extends Controller
{
    /**
     * Home page action.
     *
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     * @throws NotFoundHttpException
     */
    public function homeAction(Request $request)
    {
        if (null === $page = $this->getDoctrine()->getRepository('EkynaCmsBundle:Page')->findOneByRequest($request)) {
            throw new NotFoundHttpException('Page not found');
        }

        return $this->configureSharedCache(
            $this->render('WebBundle:Page:home.html.twig')
        );
    }

    /**
     * Default page action.
     *
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function defaultAction(Request $request)
    {
        if (null === $page = $this->getDoctrine()->getRepository('EkynaCmsBundle:Page')->findOneByRequest($request)) {
            throw new NotFoundHttpException('Page not found');
        }

        return $this->configureSharedCache(
            $this->render('WebBundle:Page:default.html.twig')
        );
    }

    /**
     * Contact page action.
     *
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function contactAction(Request $request)
    {
        if (null === $page = $this->getDoctrine()->getRepository('EkynaCmsBundle:Page')->findOneByRequest($request)) {
            throw new NotFoundHttpException('Page not found');
        }

        $form =
            $this->createFormBuilder(null, array(
                '_footer' => array(
                    'offset' => 4,
                    'buttons' => array(
                        'submit' => array(
                            'label' => 'ekyna_core.button.send'
                        )
                    )
                )
            ))
                ->add('email', 'email', array(
                    'label' => 'Votre adresse email',
                ))
                ->add('subject', 'text', array(
                    'label' => 'Sujet de votre demande',
                ))
                ->add('message', 'textarea', array(
                    'label' => 'Votre message'
                ))
                ->getForm()
        ;

        $form->handleRequest($request);
        if ($form->isValid()) {
            $settings = $this->container->get('ekyna_setting.manager');
            $fromEmail = $settings->getParameter('notification.from_email');
            $fromName = $settings->getParameter('notification.from_name');
            $toEmails = $settings->getParameter('notification.to_emails');

            $message = \Swift_Message::newInstance()
                ->setSubject($form->get('subject')->getData())
                ->setFrom($fromEmail, $fromName)
                ->setTo($toEmails)
                ->setBody($this->get('twig')->render(
                    'WebBundle:Email:contact.html.twig', array(
                        'from' => $form->get('email')->getData(),
                        'subject' => $form->get('subject')->getData(),
                        'message' => $form->get('message')->getData(),
                    )
                ), 'text/html')
            ;
            if ($this->get('mailer')->send($message)) {
                $this->addFlash(
                    'Votre message a bien été envoyé. Nous vous répondrons dans les plus brefs délais.',
                    'success'
                );
                return $this->redirect($this->generateUrl('contact'));
            } else {
                $this->addFlash(
                    'Une error s\'est produite lors de l\'envoi de votre message. Veuillez réessayer utlérieurement.',
                    'error'
                );
            }
        }

        $response = $this->render('WebBundle:Page:contact.html.twig', array(
            'form' => $form->createView()
        ));

        return $response->setPrivate();
    }
}
