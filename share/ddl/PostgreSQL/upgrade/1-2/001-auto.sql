-- Convert schema 'share/ddl/_source/deploy/1/001-auto.yml' to 'share/ddl/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE channel_namespaces ADD COLUMN status character varying NOT NULL;

;
ALTER TABLE channel_namespaces ADD COLUMN group_id integer NOT NULL;

;
CREATE INDEX channel_namespaces_idx_group_id on channel_namespaces (group_id);

;
ALTER TABLE channel_namespaces ADD CONSTRAINT channel_namespaces_fk_group_id FOREIGN KEY (group_id)
  REFERENCES groups (id) ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE channel_requests ADD COLUMN namespace_id integer NOT NULL;

;
ALTER TABLE channel_requests ADD COLUMN status character varying NOT NULL;

;
CREATE INDEX channel_requests_idx_namespace_id on channel_requests (namespace_id);

;
ALTER TABLE channel_requests ADD CONSTRAINT channel_requests_fk_namespace_id FOREIGN KEY (namespace_id)
  REFERENCES channel_namespaces (id) ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE cloak_changes ADD COLUMN namespace_id integer NOT NULL;

;
ALTER TABLE cloak_changes ADD COLUMN status character varying NOT NULL;

;
CREATE INDEX cloak_changes_idx_namespace_id on cloak_changes (namespace_id);

;
ALTER TABLE cloak_changes ADD CONSTRAINT cloak_changes_fk_namespace_id FOREIGN KEY (namespace_id)
  REFERENCES cloak_namespaces (id) ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE cloak_namespaces ADD COLUMN status character varying NOT NULL;

;
ALTER TABLE cloak_namespaces ADD COLUMN group_id integer NOT NULL;

;
CREATE INDEX cloak_namespaces_idx_group_id on cloak_namespaces (group_id);

;
ALTER TABLE cloak_namespaces ADD CONSTRAINT cloak_namespaces_fk_group_id FOREIGN KEY (group_id)
  REFERENCES groups (id) ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE contacts ADD COLUMN name character varying(255) NOT NULL;

;
ALTER TABLE contacts ADD COLUMN phone character varying(32);

;
ALTER TABLE contacts ADD COLUMN email character varying(255) NOT NULL;

;
ALTER TABLE group_contacts DROP CONSTRAINT group_contacts_fk_active_change;

;
ALTER TABLE group_contacts DROP CONSTRAINT group_contacts_fk_contact_id;

;
ALTER TABLE group_contacts ADD COLUMN primary boolean DEFAULT false NOT NULL;

;
ALTER TABLE group_contacts ADD COLUMN status character varying NOT NULL;

;
ALTER TABLE group_contacts ADD CONSTRAINT group_contacts_fk_active_change FOREIGN KEY (active_change)
  REFERENCES group_contact_changes (id) ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE group_contacts ADD CONSTRAINT group_contacts_fk_contact_id FOREIGN KEY (contact_id)
  REFERENCES contacts (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE groups ADD COLUMN group_type character varying NOT NULL;

;
ALTER TABLE groups ADD COLUMN url character varying(64);

;
ALTER TABLE groups ADD COLUMN address integer;

;
ALTER TABLE groups ADD COLUMN status character varying NOT NULL;

;
CREATE INDEX groups_idx_address on groups (address);

;
ALTER TABLE groups ADD CONSTRAINT groups_fk_address FOREIGN KEY (address)
  REFERENCES addresses (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;

COMMIT;

