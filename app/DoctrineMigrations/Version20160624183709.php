<?php

namespace Application\Migrations;

use Doctrine\DBAL\Migrations\AbstractMigration;
use Doctrine\DBAL\Schema\Schema;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
class Version20160624183709 extends AbstractMigration
{
    /**
     * @param Schema $schema
     */
    public function up(Schema $schema)
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->abortIf($this->connection->getDatabasePlatform()->getName() != 'mysql', 'Migration can only be executed safely on \'mysql\'.');

        $this->addSql('CREATE TABLE cms_tag (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(64) NOT NULL, PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_page_translation (id INT AUTO_INCREMENT NOT NULL, translatable_id INT NOT NULL, title VARCHAR(255) NOT NULL, breadcrumb VARCHAR(255) NOT NULL, html LONGTEXT DEFAULT NULL, path VARCHAR(255) DEFAULT NULL, locale VARCHAR(255) NOT NULL, INDEX IDX_33CAFA672C2AC5D3 (translatable_id), UNIQUE INDEX unique_path (path, locale), UNIQUE INDEX cms_page_translation_uniq_trans (translatable_id, locale), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_content (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(255) DEFAULT NULL, created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_page (id INT AUTO_INCREMENT NOT NULL, seo_id INT NOT NULL, content_id INT DEFAULT NULL, parent_id INT DEFAULT NULL, name VARCHAR(255) NOT NULL, route VARCHAR(64) NOT NULL, static TINYINT(1) NOT NULL, locked TINYINT(1) NOT NULL, controller VARCHAR(64) DEFAULT NULL, advanced TINYINT(1) NOT NULL, dynamic_path TINYINT(1) NOT NULL, enabled TINYINT(1) NOT NULL, lft INT NOT NULL, rgt INT NOT NULL, root INT DEFAULT NULL, lvl INT NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, UNIQUE INDEX UNIQ_D39C1B5D97E3DD86 (seo_id), UNIQUE INDEX UNIQ_D39C1B5D84A0A3ED (content_id), INDEX idx_name (name), INDEX idx_parent (parent_id), INDEX idx_route (route), UNIQUE INDEX unique_name (name, parent_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_seo (id INT AUTO_INCREMENT NOT NULL, changefreq TINYTEXT NOT NULL, priority NUMERIC(2, 1) NOT NULL, do_follow TINYINT(1) NOT NULL, do_index TINYINT(1) NOT NULL, canonical_url VARCHAR(255) DEFAULT NULL, PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_menu (id INT AUTO_INCREMENT NOT NULL, parent_id INT DEFAULT NULL, name VARCHAR(255) NOT NULL, description LONGTEXT DEFAULT NULL, route VARCHAR(255) DEFAULT NULL, parameters LONGTEXT NOT NULL COMMENT \'(DC2Type:array)\', attributes LONGTEXT NOT NULL COMMENT \'(DC2Type:array)\', locked TINYINT(1) NOT NULL, enabled TINYINT(1) NOT NULL, lft INT NOT NULL, rgt INT NOT NULL, root INT DEFAULT NULL, lvl INT NOT NULL, INDEX idx_name (name), INDEX idx_parent (parent_id), UNIQUE INDEX uniq_name (name, parent_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_menu_translation (id INT AUTO_INCREMENT NOT NULL, translatable_id INT NOT NULL, title VARCHAR(255) NOT NULL, path VARCHAR(255) DEFAULT NULL, locale VARCHAR(255) NOT NULL, INDEX IDX_4C8ABA592C2AC5D3 (translatable_id), UNIQUE INDEX cms_menu_translation_uniq_trans (translatable_id, locale), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_seo_translation (id INT AUTO_INCREMENT NOT NULL, translatable_id INT NOT NULL, title VARCHAR(255) NOT NULL, description VARCHAR(255) NOT NULL, locale VARCHAR(255) NOT NULL, INDEX IDX_D0F287EC2C2AC5D3 (translatable_id), UNIQUE INDEX cms_seo_translation_uniq_trans (translatable_id, locale), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_container (id INT AUTO_INCREMENT NOT NULL, content_id INT DEFAULT NULL, name VARCHAR(255) DEFAULT NULL, position SMALLINT NOT NULL, type VARCHAR(32) NOT NULL, data LONGTEXT NOT NULL COMMENT \'(DC2Type:object)\', created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, INDEX IDX_4C48C7684A0A3ED (content_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_block (id INT AUTO_INCREMENT NOT NULL, row_id INT DEFAULT NULL, name VARCHAR(255) DEFAULT NULL, position SMALLINT NOT NULL, size SMALLINT NOT NULL, type VARCHAR(32) NOT NULL, data LONGTEXT NOT NULL COMMENT \'(DC2Type:object)\', created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, INDEX IDX_AD680C0E83A269F2 (row_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_block_translation (id INT AUTO_INCREMENT NOT NULL, translatable_id INT NOT NULL, data LONGTEXT DEFAULT NULL COMMENT \'(DC2Type:object)\', locale VARCHAR(255) NOT NULL, INDEX IDX_DE2497772C2AC5D3 (translatable_id), UNIQUE INDEX cms_block_translation_uniq_trans (translatable_id, locale), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE cms_row (id INT AUTO_INCREMENT NOT NULL, container_id INT DEFAULT NULL, name VARCHAR(255) DEFAULT NULL, position SMALLINT NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, INDEX IDX_C5353FA0BC21F742 (container_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE media_folder (id INT AUTO_INCREMENT NOT NULL, parent_id INT DEFAULT NULL, name VARCHAR(64) NOT NULL, lft INT NOT NULL, rgt INT NOT NULL, root INT DEFAULT NULL, lvl INT NOT NULL, INDEX idx_name (name), INDEX idx_parent (parent_id), UNIQUE INDEX unique_name (name, parent_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE media_media (id INT AUTO_INCREMENT NOT NULL, folder_id INT NOT NULL, type VARCHAR(8) NOT NULL, path VARCHAR(255) NOT NULL, size INT NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, INDEX IDX_753565BD162CB942 (folder_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE media_media_translation (id INT AUTO_INCREMENT NOT NULL, translatable_id INT NOT NULL, title VARCHAR(64) DEFAULT NULL, description LONGTEXT DEFAULT NULL, locale VARCHAR(255) NOT NULL, INDEX IDX_15F85A072C2AC5D3 (translatable_id), UNIQUE INDEX media_media_translation_uniq_trans (translatable_id, locale), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE user_address (id INT AUTO_INCREMENT NOT NULL, user_id INT DEFAULT NULL, street VARCHAR(128) NOT NULL, supplement VARCHAR(128) DEFAULT NULL, postal_code VARCHAR(16) NOT NULL, city VARCHAR(64) NOT NULL, country VARCHAR(8) NOT NULL, state VARCHAR(64) DEFAULT NULL, company VARCHAR(64) DEFAULT NULL, gender VARCHAR(8) DEFAULT NULL, first_name VARCHAR(32) DEFAULT NULL, last_name VARCHAR(32) DEFAULT NULL, phone VARCHAR(35) DEFAULT NULL COMMENT \'(DC2Type:phone_number)\', mobile VARCHAR(35) DEFAULT NULL COMMENT \'(DC2Type:phone_number)\', locked TINYINT(1) NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, INDEX IDX_5543718BA76ED395 (user_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE user_user (id INT AUTO_INCREMENT NOT NULL, group_id INT NOT NULL, username VARCHAR(255) NOT NULL, username_canonical VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL, email_canonical VARCHAR(255) NOT NULL, enabled TINYINT(1) NOT NULL, salt VARCHAR(255) NOT NULL, password VARCHAR(255) NOT NULL, last_login DATETIME DEFAULT NULL, locked TINYINT(1) NOT NULL, expired TINYINT(1) NOT NULL, expires_at DATETIME DEFAULT NULL, confirmation_token VARCHAR(255) DEFAULT NULL, password_requested_at DATETIME DEFAULT NULL, roles LONGTEXT NOT NULL COMMENT \'(DC2Type:array)\', credentials_expired TINYINT(1) NOT NULL, credentials_expire_at DATETIME DEFAULT NULL, company VARCHAR(64) DEFAULT NULL, gender VARCHAR(8) NOT NULL, first_name VARCHAR(32) NOT NULL, last_name VARCHAR(32) NOT NULL, phone VARCHAR(35) DEFAULT NULL COMMENT \'(DC2Type:phone_number)\', mobile VARCHAR(35) DEFAULT NULL COMMENT \'(DC2Type:phone_number)\', created_at DATETIME NOT NULL, updated_at DATETIME DEFAULT NULL, UNIQUE INDEX UNIQ_F7129A8092FC23A8 (username_canonical), UNIQUE INDEX UNIQ_F7129A80A0D96FBF (email_canonical), INDEX IDX_F7129A80FE54D947 (group_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE user_group (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(255) NOT NULL, roles LONGTEXT NOT NULL COMMENT \'(DC2Type:array)\', as_default TINYINT(1) NOT NULL, position INT NOT NULL, UNIQUE INDEX UNIQ_8F02BF9D5E237E06 (name), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE sett_helper (id INT AUTO_INCREMENT NOT NULL, name VARCHAR(64) NOT NULL, reference VARCHAR(32) NOT NULL, content LONGTEXT NOT NULL, enabled TINYINT(1) NOT NULL, updated_at DATETIME DEFAULT NULL, PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE sett_parameter (id INT AUTO_INCREMENT NOT NULL, namespace VARCHAR(64) NOT NULL, name VARCHAR(64) NOT NULL, value LONGTEXT DEFAULT NULL COMMENT \'(DC2Type:object)\', PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE sett_redirection (id INT AUTO_INCREMENT NOT NULL, from_path VARCHAR(255) NOT NULL, to_path VARCHAR(255) NOT NULL, permanent TINYINT(1) NOT NULL, enabled TINYINT(1) NOT NULL, count INT NOT NULL, used_at DATETIME DEFAULT NULL, UNIQUE INDEX UNIQ_E50EB9FC7EC256EC (from_path), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE acl_classes (id INT UNSIGNED AUTO_INCREMENT NOT NULL, class_type VARCHAR(200) NOT NULL, UNIQUE INDEX UNIQ_69DD750638A36066 (class_type), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE acl_security_identities (id INT UNSIGNED AUTO_INCREMENT NOT NULL, identifier VARCHAR(200) NOT NULL, username TINYINT(1) NOT NULL, UNIQUE INDEX UNIQ_8835EE78772E836AF85E0677 (identifier, username), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE acl_object_identities (id INT UNSIGNED AUTO_INCREMENT NOT NULL, parent_object_identity_id INT UNSIGNED DEFAULT NULL, class_id INT UNSIGNED NOT NULL, object_identifier VARCHAR(100) NOT NULL, entries_inheriting TINYINT(1) NOT NULL, UNIQUE INDEX UNIQ_9407E5494B12AD6EA000B10 (object_identifier, class_id), INDEX IDX_9407E54977FA751A (parent_object_identity_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE acl_object_identity_ancestors (object_identity_id INT UNSIGNED NOT NULL, ancestor_id INT UNSIGNED NOT NULL, INDEX IDX_825DE2993D9AB4A6 (object_identity_id), INDEX IDX_825DE299C671CEA1 (ancestor_id), PRIMARY KEY(object_identity_id, ancestor_id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('CREATE TABLE acl_entries (id INT UNSIGNED AUTO_INCREMENT NOT NULL, class_id INT UNSIGNED NOT NULL, object_identity_id INT UNSIGNED DEFAULT NULL, security_identity_id INT UNSIGNED NOT NULL, field_name VARCHAR(50) DEFAULT NULL, ace_order SMALLINT UNSIGNED NOT NULL, mask INT NOT NULL, granting TINYINT(1) NOT NULL, granting_strategy VARCHAR(30) NOT NULL, audit_success TINYINT(1) NOT NULL, audit_failure TINYINT(1) NOT NULL, UNIQUE INDEX UNIQ_46C8B806EA000B103D9AB4A64DEF17BCE4289BF4 (class_id, object_identity_id, field_name, ace_order), INDEX IDX_46C8B806EA000B103D9AB4A6DF9183C9 (class_id, object_identity_id, security_identity_id), INDEX IDX_46C8B806EA000B10 (class_id), INDEX IDX_46C8B8063D9AB4A6 (object_identity_id), INDEX IDX_46C8B806DF9183C9 (security_identity_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB');
        $this->addSql('ALTER TABLE cms_page_translation ADD CONSTRAINT FK_33CAFA672C2AC5D3 FOREIGN KEY (translatable_id) REFERENCES cms_page (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_page ADD CONSTRAINT FK_D39C1B5D97E3DD86 FOREIGN KEY (seo_id) REFERENCES cms_seo (id) ON DELETE RESTRICT');
        $this->addSql('ALTER TABLE cms_page ADD CONSTRAINT FK_D39C1B5D84A0A3ED FOREIGN KEY (content_id) REFERENCES cms_content (id)');
        $this->addSql('ALTER TABLE cms_page ADD CONSTRAINT FK_D39C1B5D727ACA70 FOREIGN KEY (parent_id) REFERENCES cms_page (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_menu ADD CONSTRAINT FK_BA9397EE727ACA70 FOREIGN KEY (parent_id) REFERENCES cms_menu (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_menu_translation ADD CONSTRAINT FK_4C8ABA592C2AC5D3 FOREIGN KEY (translatable_id) REFERENCES cms_menu (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_seo_translation ADD CONSTRAINT FK_D0F287EC2C2AC5D3 FOREIGN KEY (translatable_id) REFERENCES cms_seo (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_container ADD CONSTRAINT FK_4C48C7684A0A3ED FOREIGN KEY (content_id) REFERENCES cms_content (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_block ADD CONSTRAINT FK_AD680C0E83A269F2 FOREIGN KEY (row_id) REFERENCES cms_row (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_block_translation ADD CONSTRAINT FK_DE2497772C2AC5D3 FOREIGN KEY (translatable_id) REFERENCES cms_block (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE cms_row ADD CONSTRAINT FK_C5353FA0BC21F742 FOREIGN KEY (container_id) REFERENCES cms_container (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE media_folder ADD CONSTRAINT FK_50DB9313727ACA70 FOREIGN KEY (parent_id) REFERENCES media_folder (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE media_media ADD CONSTRAINT FK_753565BD162CB942 FOREIGN KEY (folder_id) REFERENCES media_folder (id) ON DELETE RESTRICT');
        $this->addSql('ALTER TABLE media_media_translation ADD CONSTRAINT FK_15F85A072C2AC5D3 FOREIGN KEY (translatable_id) REFERENCES media_media (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE user_address ADD CONSTRAINT FK_5543718BA76ED395 FOREIGN KEY (user_id) REFERENCES user_user (id) ON DELETE CASCADE');
        $this->addSql('ALTER TABLE user_user ADD CONSTRAINT FK_F7129A80FE54D947 FOREIGN KEY (group_id) REFERENCES user_group (id) ON DELETE RESTRICT');
        $this->addSql('ALTER TABLE acl_object_identities ADD CONSTRAINT FK_9407E54977FA751A FOREIGN KEY (parent_object_identity_id) REFERENCES acl_object_identities (id)');
        $this->addSql('ALTER TABLE acl_object_identity_ancestors ADD CONSTRAINT FK_825DE2993D9AB4A6 FOREIGN KEY (object_identity_id) REFERENCES acl_object_identities (id) ON UPDATE CASCADE ON DELETE CASCADE');
        $this->addSql('ALTER TABLE acl_object_identity_ancestors ADD CONSTRAINT FK_825DE299C671CEA1 FOREIGN KEY (ancestor_id) REFERENCES acl_object_identities (id) ON UPDATE CASCADE ON DELETE CASCADE');
        $this->addSql('ALTER TABLE acl_entries ADD CONSTRAINT FK_46C8B806EA000B10 FOREIGN KEY (class_id) REFERENCES acl_classes (id) ON UPDATE CASCADE ON DELETE CASCADE');
        $this->addSql('ALTER TABLE acl_entries ADD CONSTRAINT FK_46C8B8063D9AB4A6 FOREIGN KEY (object_identity_id) REFERENCES acl_object_identities (id) ON UPDATE CASCADE ON DELETE CASCADE');
        $this->addSql('ALTER TABLE acl_entries ADD CONSTRAINT FK_46C8B806DF9183C9 FOREIGN KEY (security_identity_id) REFERENCES acl_security_identities (id) ON UPDATE CASCADE ON DELETE CASCADE');
    }

    /**
     * @param Schema $schema
     */
    public function down(Schema $schema)
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->abortIf($this->connection->getDatabasePlatform()->getName() != 'mysql', 'Migration can only be executed safely on \'mysql\'.');

        $this->addSql('ALTER TABLE cms_page DROP FOREIGN KEY FK_D39C1B5D84A0A3ED');
        $this->addSql('ALTER TABLE cms_container DROP FOREIGN KEY FK_4C48C7684A0A3ED');
        $this->addSql('ALTER TABLE cms_page_translation DROP FOREIGN KEY FK_33CAFA672C2AC5D3');
        $this->addSql('ALTER TABLE cms_page DROP FOREIGN KEY FK_D39C1B5D727ACA70');
        $this->addSql('ALTER TABLE cms_page DROP FOREIGN KEY FK_D39C1B5D97E3DD86');
        $this->addSql('ALTER TABLE cms_seo_translation DROP FOREIGN KEY FK_D0F287EC2C2AC5D3');
        $this->addSql('ALTER TABLE cms_menu DROP FOREIGN KEY FK_BA9397EE727ACA70');
        $this->addSql('ALTER TABLE cms_menu_translation DROP FOREIGN KEY FK_4C8ABA592C2AC5D3');
        $this->addSql('ALTER TABLE cms_row DROP FOREIGN KEY FK_C5353FA0BC21F742');
        $this->addSql('ALTER TABLE cms_block_translation DROP FOREIGN KEY FK_DE2497772C2AC5D3');
        $this->addSql('ALTER TABLE cms_block DROP FOREIGN KEY FK_AD680C0E83A269F2');
        $this->addSql('ALTER TABLE media_folder DROP FOREIGN KEY FK_50DB9313727ACA70');
        $this->addSql('ALTER TABLE media_media DROP FOREIGN KEY FK_753565BD162CB942');
        $this->addSql('ALTER TABLE media_media_translation DROP FOREIGN KEY FK_15F85A072C2AC5D3');
        $this->addSql('ALTER TABLE user_address DROP FOREIGN KEY FK_5543718BA76ED395');
        $this->addSql('ALTER TABLE user_user DROP FOREIGN KEY FK_F7129A80FE54D947');
        $this->addSql('ALTER TABLE acl_entries DROP FOREIGN KEY FK_46C8B806EA000B10');
        $this->addSql('ALTER TABLE acl_entries DROP FOREIGN KEY FK_46C8B806DF9183C9');
        $this->addSql('ALTER TABLE acl_object_identities DROP FOREIGN KEY FK_9407E54977FA751A');
        $this->addSql('ALTER TABLE acl_object_identity_ancestors DROP FOREIGN KEY FK_825DE2993D9AB4A6');
        $this->addSql('ALTER TABLE acl_object_identity_ancestors DROP FOREIGN KEY FK_825DE299C671CEA1');
        $this->addSql('ALTER TABLE acl_entries DROP FOREIGN KEY FK_46C8B8063D9AB4A6');
        $this->addSql('DROP TABLE cms_tag');
        $this->addSql('DROP TABLE cms_page_translation');
        $this->addSql('DROP TABLE cms_content');
        $this->addSql('DROP TABLE cms_page');
        $this->addSql('DROP TABLE cms_seo');
        $this->addSql('DROP TABLE cms_menu');
        $this->addSql('DROP TABLE cms_menu_translation');
        $this->addSql('DROP TABLE cms_seo_translation');
        $this->addSql('DROP TABLE cms_container');
        $this->addSql('DROP TABLE cms_block');
        $this->addSql('DROP TABLE cms_block_translation');
        $this->addSql('DROP TABLE cms_row');
        $this->addSql('DROP TABLE media_folder');
        $this->addSql('DROP TABLE media_media');
        $this->addSql('DROP TABLE media_media_translation');
        $this->addSql('DROP TABLE user_address');
        $this->addSql('DROP TABLE user_user');
        $this->addSql('DROP TABLE user_group');
        $this->addSql('DROP TABLE sett_helper');
        $this->addSql('DROP TABLE sett_parameter');
        $this->addSql('DROP TABLE sett_redirection');
        $this->addSql('DROP TABLE acl_classes');
        $this->addSql('DROP TABLE acl_security_identities');
        $this->addSql('DROP TABLE acl_object_identities');
        $this->addSql('DROP TABLE acl_object_identity_ancestors');
        $this->addSql('DROP TABLE acl_entries');
    }
}
