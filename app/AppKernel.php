<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;

class AppKernel extends Kernel
{
    public function registerBundles()
    {
        $bundles = [
            new Ekyna\Bundle\SocialButtonsBundle\EkynaSocialButtonsBundle(),
            new Ekyna\Bundle\GoogleBundle\EkynaGoogleBundle(),
            new Ekyna\Bundle\SitemapBundle\EkynaSitemapBundle(),

            new Ekyna\Bundle\CmsBundle\EkynaCmsBundle(),
            new Ekyna\Bundle\MediaBundle\EkynaMediaBundle(),
            new Ekyna\Bundle\AdminBundle\EkynaAdminBundle(),

            new Ekyna\Bundle\UserBundle\EkynaUserBundle(),
            new Ekyna\Bundle\ResourceBundle\EkynaResourceBundle(),
            new Ekyna\Bundle\SettingBundle\EkynaSettingBundle(),
            new Ekyna\Bundle\InstallBundle\EkynaInstallBundle(),
            new Ekyna\Bundle\TableBundle\EkynaTableBundle(),
            new Ekyna\Bundle\CoreBundle\EkynaCoreBundle(),
            new Ekyna\Bundle\RequireJsBundle\EkynaRequireJsBundle(),

            new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
            new Doctrine\Bundle\DoctrineCacheBundle\DoctrineCacheBundle(),
            new Doctrine\Bundle\MigrationsBundle\DoctrineMigrationsBundle(),
            new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
            new Symfony\Bundle\SecurityBundle\SecurityBundle(),
            new Symfony\Bundle\TwigBundle\TwigBundle(),
            new Symfony\Bundle\MonologBundle\MonologBundle(),
            new Symfony\Bundle\SwiftmailerBundle\SwiftmailerBundle(),
            //new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),

            new Snc\RedisBundle\SncRedisBundle(),
            new JMS\I18nRoutingBundle\JMSI18nRoutingBundle(),
            new Liip\ImagineBundle\LiipImagineBundle(),
            new Knp\Bundle\MenuBundle\KnpMenuBundle(),
            //new Knp\Bundle\SnappyBundle\KnpSnappyBundle(),
            new FOS\UserBundle\FOSUserBundle(),
            new FOS\JsRoutingBundle\FOSJsRoutingBundle(),
            new FOS\ElasticaBundle\FOSElasticaBundle(),
            new FOS\HttpCacheBundle\FOSHttpCacheBundle(),
            new Stof\DoctrineExtensionsBundle\StofDoctrineExtensionsBundle(),
            new A2lix\AutoFormBundle\A2lixAutoFormBundle(),
            new A2lix\TranslationFormBundle\A2lixTranslationFormBundle(),
            new WhiteOctober\PagerfantaBundle\WhiteOctoberPagerfantaBundle(),
            new Braincrafted\Bundle\BootstrapBundle\BraincraftedBootstrapBundle(),
            new Craue\FormFlowBundle\CraueFormFlowBundle(),
            new Oneup\FlysystemBundle\OneupFlysystemBundle(),
            new Oneup\UploaderBundle\OneupUploaderBundle(),
            new Gregwar\CaptchaBundle\GregwarCaptchaBundle(),
            new Ivory\GoogleMapBundle\IvoryGoogleMapBundle(),
            new Misd\PhoneNumberBundle\MisdPhoneNumberBundle(),

            new AppBundle\AppBundle(),
            new WebBundle\WebBundle(),
        ];

        if (in_array($this->getEnvironment(), ['dev', 'test'])) {
            $bundles[] = new Doctrine\Bundle\FixturesBundle\DoctrineFixturesBundle();
            $bundles[] = new Hautelook\AliceBundle\HautelookAliceBundle();
            $bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
            $bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
            $bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
        }

        return $bundles;
    }

    public function getRootDir()
    {
        return __DIR__;
    }

    public function getCacheDir()
    {
        return dirname(__DIR__) . '/var/cache/' . $this->getEnvironment();
    }

    public function getLogDir()
    {
        return dirname(__DIR__) . '/var/logs';
    }

    public function getDataDir()
    {
        if (in_array($this->getEnvironment(), ['prod', 'dev'])) {
            return dirname(__DIR__) . '/var/data';
        }

        return dirname(__DIR__) . '/var/data/__' . $this->getEnvironment();
    }

    public function registerContainerConfiguration(LoaderInterface $loader)
    {
        $loader->load($this->getRootDir() . '/config/config_' . $this->getEnvironment() . '.yml');
    }

    protected function getKernelParameters()
    {
        $parameters = parent::getKernelParameters();

        $parameters['kernel.data_dir'] = $this->getDataDir();

        return $parameters;
    }
}
