<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;

class AppKernel extends Kernel
{
    public function registerBundles()
    {
        $bundles = array(
            new Ekyna\Bundle\CmsBundle\EkynaCmsBundle(),
            new Ekyna\Bundle\MediaBundle\EkynaMediaBundle(),
            new Ekyna\Bundle\SettingBundle\EkynaSettingBundle(),
            new Ekyna\Bundle\TableBundle\EkynaTableBundle(),
            new Ekyna\Bundle\UserBundle\EkynaUserBundle(),
            new Ekyna\Bundle\FileManagerBundle\EkynaFileManagerBundle(),
            new Ekyna\Bundle\SitemapBundle\EkynaSitemapBundle(),
            new Ekyna\Bundle\InstallBundle\EkynaInstallBundle(),
            new Ekyna\Bundle\RequireJsBundle\EkynaRequireJsBundle(),
            new Ekyna\Bundle\FontAwesomeBundle\EkynaFontAwesomeBundle(),

            new Ekyna\Bundle\AdminBundle\EkynaAdminBundle(),
            new Ekyna\Bundle\CoreBundle\EkynaCoreBundle(),

            new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
            new Symfony\Bundle\SecurityBundle\SecurityBundle(),
            new Symfony\Bundle\TwigBundle\TwigBundle(),
            new Symfony\Bundle\MonologBundle\MonologBundle(),
            new Symfony\Bundle\SwiftmailerBundle\SwiftmailerBundle(),
            new Symfony\Bundle\AsseticBundle\AsseticBundle(),
            new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
            new Doctrine\Bundle\DoctrineCacheBundle\DoctrineCacheBundle(),
            new Doctrine\Bundle\MigrationsBundle\DoctrineMigrationsBundle(),
            new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),

            new JMS\SerializerBundle\JMSSerializerBundle(),
            new JMS\TwigJsBundle\JMSTwigJsBundle(),
            new Liip\ImagineBundle\LiipImagineBundle(),
            new Knp\Bundle\MenuBundle\KnpMenuBundle(),
            new Knp\Bundle\GaufretteBundle\KnpGaufretteBundle(),
            new FOS\UserBundle\FOSUserBundle(),
            new FOS\JsRoutingBundle\FOSJsRoutingBundle(),
            new FOS\ElasticaBundle\FOSElasticaBundle(),
            new FOS\HttpCacheBundle\FOSHttpCacheBundle(),
            new Stof\DoctrineExtensionsBundle\StofDoctrineExtensionsBundle(),
            new A2lix\TranslationFormBundle\A2lixTranslationFormBundle(),
            new Stfalcon\Bundle\TinymceBundle\StfalconTinymceBundle(),
            new WhiteOctober\PagerfantaBundle\WhiteOctoberPagerfantaBundle(),
            new Braincrafted\Bundle\BootstrapBundle\BraincraftedBootstrapBundle(),
            new Misd\PhoneNumberBundle\MisdPhoneNumberBundle(),
            new Oneup\UploaderBundle\OneupUploaderBundle(),
            new Gregwar\CaptchaBundle\GregwarCaptchaBundle(),

            new AppBundle\AppBundle(),
            new WebBundle\WebBundle(),
        );

        if (in_array($this->getEnvironment(), array('dev', 'test'))) {
            $bundles[] = new Doctrine\Bundle\FixturesBundle\DoctrineFixturesBundle();
            $bundles[] = new Hautelook\AliceBundle\HautelookAliceBundle();
            $bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
            $bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
            $bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
        }

        return $bundles;
    }

    public function registerContainerConfiguration(LoaderInterface $loader)
    {
        $loader->load(__DIR__.'/config/config_'.$this->getEnvironment().'.yml');
    }
}
