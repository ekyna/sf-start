<?php

namespace AppBundle\DataFixtures\ORM;

use Doctrine\Common\DataFixtures\AbstractFixture as Loader;
use Doctrine\Common\DataFixtures\FixtureInterface;
use Doctrine\Common\DataFixtures\OrderedFixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;
use Ekyna\Bundle\MediaBundle\Entity\FolderRepository;
use Ekyna\Bundle\MediaBundle\Entity\MediaRepository;
use Ekyna\Bundle\MediaBundle\Model\MediaTypes;
use Faker\Factory;
use Symfony\Component\DependencyInjection\ContainerAwareInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\File\File;

/**
 * Class LoadMediaData
 * @package AppBundle\DataFixtures\ORM
 * @author Étienne Dauvergne <contact@ekyna.com>
 */
class LoadMediaData extends Loader implements FixtureInterface, OrderedFixtureInterface, ContainerAwareInterface
{
    /**
     * @var ContainerInterface
     */
    private $container;

    /**
     * @var \Faker\Generator
     */
    private $faker;

    /**
     * @var FolderRepository
     */
    private $folderRepository;

    /**
     * @var MediaRepository
     */
    private $mediaRepository;


    /**
     * {@inheritDoc}
     */
    public function setContainer(ContainerInterface $container = null)
    {
        $this->container = $container;

        $this->faker = Factory::create($this->container->getParameter('hautelook_alice.locale'));

        $this->folderRepository = $this->container->get('ekyna_media.folder.repository');
        $this->mediaRepository = $this->container->get('ekyna_media.media.repository');
    }

    /**
     * {@inheritdoc}
     */
    public function load(ObjectManager $om)
    {
        $this->loadFolders($om);

        foreach (MediaTypes::getConstants() as $const) {
            $this->loadMedias($om, $const);
        }
    }

    /**
     * Load the folders.
     *
     * @param ObjectManager $om
     */
    private function loadFolders(ObjectManager $om)
    {
        for ($f = 1; $f <= 3; $f++) {
            $folder = $this->folderRepository->createNew();
            $folder->setName(sprintf('Folder %s', $f));
            $om->persist($folder);

            $sfCount = rand(0, 2);
            for ($sf = 1; $sf <= $sfCount; $sf++) {
                $subFolder = $this->folderRepository->createNew();
                $subFolder->setName(sprintf('Folder %s.%s', $f, $sf));
                $this->folderRepository->persistAsLastChildOf($subFolder, $folder);
                $om->persist($subFolder);
            }
        }
        $om->flush();
    }

    /**
     * Load the files.
     *
     * @param ObjectManager $om
     */
    private function loadMedias(ObjectManager $om, $type)
    {
        MediaTypes::isValid($type, true);

        $dir = realpath(__DIR__.sprintf('/../../Resources/fixtures/%s/', $type));
        if (!is_dir($dir)) {
            throw new \RuntimeException(sprintf('Directory "%s" does not exists.', $dir));
        }

        $files = scandir($dir);
        foreach ($files as $file) {
            if ($file == '.' || $file == '..') {
                continue;
            }

            /** @var \Ekyna\Bundle\MediaBundle\Model\MediaInterface $media */
            $media = $this->mediaRepository->createNew();
            $media
                ->setTitle($this->faker->sentence())
                ->setDescription('<p>'.$this->faker->sentence().'</p>')
                ->setFolder($this->folderRepository->findRandomOneBy([]))
                ->setFile(new File(sprintf('%s/%s', $dir, $file)))
            ;
            $om->persist($media);
        }
        $om->flush();
    }

    /**
     * {@inheritDoc}
     */
    public function getOrder()
    {
        return -1;
    }
}
