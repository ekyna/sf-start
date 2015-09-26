<?php

namespace AppBundle\Controller;

use Ekyna\Bundle\CoreBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Validator\Constraints;

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
     * @return \Symfony\Component\HttpFoundation\Response
     * @throws NotFoundHttpException
     */
    public function homeAction()
    {
        return $this->configureSharedCache(
            $this->render('WebBundle:Page:home.html.twig')
        );
    }

    /**
     * Default page action.
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function defaultAction()
    {
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
        $form = $this
            ->createFormBuilder()
            ->add('name', 'text', [
                'label' => 'web.contact.field.name',
                'constraints' => [
                    new Constraints\NotBlank(),
                ],
            ])
            ->add('email', 'email', [
                'label' => 'web.contact.field.email',
                'constraints' => [
                    new Constraints\NotBlank(),
                    new Constraints\Email(),
                ],
            ])
            ->add('subject', 'text', [
                'label' => 'web.contact.field.subject',
                'constraints' => [
                    new Constraints\NotBlank(),
                ],
            ])
            ->add('message', 'textarea', [
                'label' => 'web.contact.field.message',
                'constraints' => [
                    new Constraints\NotBlank(),
                ],
            ])
            ->add('actions', 'form_actions', [
                'buttons' => [
                    'save' => [
                        'type' => 'submit',
                        'options' => [
                            'button_class' => 'primary',
                            'label' => 'web.contact.button',
                        ],
                    ],
                ],
            ])
            ->getForm()
        ;

        $form->handleRequest($request);
        if ($form->isValid()) {
            $settings = $this->container->get('ekyna_setting.manager');
            $toEmails = $settings->getParameter('notification.to_emails');

            $fromName = $form->get('name')->getData();
            $fromEmail = $form->get('email')->getData();

            /** @var \Swift_Mime_Message $message */
            $message = \Swift_Message::newInstance()
                ->setSubject($form->get('subject')->getData())
                ->setFrom($fromEmail, $fromName)
                ->setTo($toEmails)
                ->setBody($this->get('twig')->render(
                    'WebBundle:Email:contact.html.twig', [
                        'name' => $fromName,
                        'from' => $fromEmail,
                        'subject' => $form->get('subject')->getData(),
                        'message' => $form->get('message')->getData(),
                    ]
                ), 'text/html')
            ;
            if ($this->get('mailer')->send($message)) {
                $this->addFlash('web.contact.message.success', 'success');
                return $this->redirect($this->generateUrl('contact'));
            } else {
                $this->addFlash('web.contact.message.failure', 'error');
            }
        }

        $response = $this->render('WebBundle:Page:contact.html.twig', [
            'form' => $form->createView()
        ]);

        return $response->setPrivate();
    }
}
