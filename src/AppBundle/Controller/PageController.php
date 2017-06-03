<?php

namespace AppBundle\Controller;

use Braincrafted\Bundle\BootstrapBundle\Form\Type\FormActionsType;
use Ekyna\Bundle\CoreBundle\Controller\Controller;
use Symfony\Component\Form\Extension\Core\Type;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Validator\Constraints;

/**
 * Class PageController
 * @package AppBundle\Controller
 * @author  Étienne Dauvergne <contact@ekyna.com>
 */
class PageController extends Controller
{
    /**
     * Home page action.
     *
     * @return \Symfony\Component\HttpFoundation\Response
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
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function contactAction(Request $request)
    {
        $url = $this->generateUrl('app_page_contact');

        $form = $this
            ->createFormBuilder(null, [
                'action' => $url,
                'method' => 'post',
                'attr'   => [
                    'class' => 'form-horizontal',
                ],
            ])
            ->add('name', Type\TextType::class, [
                'label'       => 'web.contact.field.name',
                'constraints' => [
                    new Constraints\NotBlank(),
                ],
            ])
            ->add('email', Type\EmailType::class, [
                'label'       => 'web.contact.field.email',
                'constraints' => [
                    new Constraints\NotBlank(),
                    new Constraints\Email(),
                ],
            ])
            ->add('subject', Type\TextType::class, [
                'label'       => 'web.contact.field.subject',
                'constraints' => [
                    new Constraints\NotBlank(),
                ],
            ])
            ->add('message', Type\TextareaType::class, [
                'label'       => 'web.contact.field.message',
                'constraints' => [
                    new Constraints\NotBlank(),
                ],
            ])
            ->add('actions', FormActionsType::class, [
                'buttons' => [
                    'save' => [
                        'type'    => Type\SubmitType::class,
                        'options' => [
                            'button_class' => 'primary',
                            'label'        => 'web.contact.button',
                        ],
                    ],
                ],
            ])
            ->getForm();

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
                        'name'    => $fromName,
                        'from'    => $fromEmail,
                        'subject' => $form->get('subject')->getData(),
                        'message' => $form->get('message')->getData(),
                    ]
                ), 'text/html');

            if ($this->get('mailer')->send($message)) {
                $this->addFlash('web.contact.message.success', 'success');

                return $this->redirect($url);
            } else {
                $this->addFlash('web.contact.message.failure', 'error');
            }
        }

        $response = $this->render('WebBundle:Page:contact.html.twig', [
            'form' => $form->createView(),
        ]);

        if ('GET' !== $request->getMethod()) {
            return $response->setPrivate();
        }

        return $this->configureSharedCache($response);
    }

    /**
     * (Wide site) Search action.
     *
     * @param Request $request
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function searchAction(Request $request)
    {
        $expression = $request->request->get('expression');

        $results = $this->get('ekyna_cms.wide_search')->search($expression);

        return $this->render('WebBundle:Page:search.html.twig', array(
            'expression' => $expression,
            'results'    => $results,
        ))->setPrivate();
    }
}
