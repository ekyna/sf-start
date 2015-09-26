<?php

namespace AppBundle\Tests\Controller;

use Ekyna\Bundle\CoreBundle\Tests\WebTestCase;

/**
 * Class PageControllerTest
 * @package AppBundle\Tests\Controller
 * @author Étienne Dauvergne <contact@ekyna.com>
 */
class PageControllerTest extends WebTestCase
{
    /**
     * Tests the home page.
     */
    public function testIndexAction()
    {
        $this->client->request('GET', $this->generatePath('home'));
        $this->assertEquals(200,
            $this->client->getResponse()->getStatusCode(),
            'Failed to reach "home" page.'
        );
    }

    /**
     * Tests the default pages.
     */
    public function testDefaultAction()
    {
        $routes = ['example'];

        foreach ($routes as $route) {
            $this->client->request('GET', $this->generatePath($route));
            $this->assertEquals(200,
                $this->client->getResponse()->getStatusCode(),
                'Failed to reach "' . $route . '" page.'
            );
        }
    }

    /**
     * Tests the contact page.
     */
    public function testContactAction()
    {
        $crawler = $this->client->request('GET', $this->generatePath('contact'));
        $this->assertEquals(200,
            $this->client->getResponse()->getStatusCode(),
            'Failed to reach "contact" page.'
        );

        $form = $crawler->selectButton('submit')->form();
        $form['form[email]'] = 'contact@example.org';
        $form['form[subject]'] = 'Testing the contact form';
        $form['form[message]'] = "I love spéçiàl chars\nand line breaks.";

        $this->client->submit($form);
        $this->assertTrue(
            $this->client->getResponse()->isRedirection(),
            'Contact form submission failed.'
        );
    }
}
