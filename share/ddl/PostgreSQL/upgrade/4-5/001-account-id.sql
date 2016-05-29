--- Thanks Obama

CREATE SEQUENCE accounts_id_seq;

ALTER TABLE accounts ADD COLUMN uuid text;

UPDATE accounts SET uuid = id;

ALTER TABLE accounts
  ALTER COLUMN uuid SET NOT NULL,
  ADD UNIQUE (uuid);

ALTER TABLE contacts DROP CONSTRAINT contacts_fk_account_id;

ALTER TABLE contacts ADD FOREIGN KEY
  (account_id) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE user_roles DROP CONSTRAINT user_roles_fk_account_id;

ALTER TABLE user_roles ADD FOREIGN KEY
  (account_id) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE channel_namespace_changes DROP CONSTRAINT channel_namespace_changes_fk_changed_by;

ALTER TABLE channel_namespace_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE channel_request_changes DROP CONSTRAINT channel_request_changes_fk_changed_by;

ALTER TABLE channel_request_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE channel_requests DROP CONSTRAINT channel_requests_fk_target;

ALTER TABLE channel_requests ADD FOREIGN KEY
  (target) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE cloak_change_changes DROP CONSTRAINT cloak_change_changes_fk_changed_by;

ALTER TABLE cloak_change_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;


ALTER TABLE cloak_changes DROP CONSTRAINT cloak_changes_fk_target;

ALTER TABLE cloak_changes ADD FOREIGN KEY
  (target) REFERENCES accounts(id) ON UPDATE CASCADE;


ALTER TABLE cloak_changes DROP CONSTRAINT cloak_changes_fk_requestor;

ALTER TABLE cloak_changes ADD FOREIGN KEY
  (requestor) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE cloak_namespace_changes DROP CONSTRAINT cloak_namespace_changes_fk_changed_by;

ALTER TABLE cloak_namespace_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE contact_changes DROP CONSTRAINT contact_changes_fk_changed_by;

ALTER TABLE contact_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;


ALTER TABLE group_changes DROP CONSTRAINT group_changes_fk_changed_by;

ALTER TABLE group_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;

ALTER TABLE group_contact_changes DROP CONSTRAINT group_contact_changes_fk_changed_by;

ALTER TABLE group_contact_changes ADD FOREIGN KEY
  (changed_by) REFERENCES accounts(id) ON UPDATE CASCADE;



UPDATE accounts SET id = nextval('accounts_id_seq')::text;


ALTER TABLE contacts DROP CONSTRAINT contacts_account_id_fkey;

ALTER TABLE user_roles DROP CONSTRAINT user_roles_account_id_fkey;

ALTER TABLE channel_namespace_changes DROP CONSTRAINT channel_namespace_changes_changed_by_fkey;

ALTER TABLE channel_request_changes DROP CONSTRAINT channel_request_changes_changed_by_fkey;

ALTER TABLE channel_requests DROP CONSTRAINT channel_requests_target_fkey;

ALTER TABLE cloak_change_changes DROP CONSTRAINT cloak_change_changes_changed_by_fkey;

ALTER TABLE cloak_changes DROP CONSTRAINT cloak_changes_target_fkey;

ALTER TABLE cloak_changes DROP CONSTRAINT cloak_changes_requestor_fkey;

ALTER TABLE cloak_namespace_changes DROP CONSTRAINT cloak_namespace_changes_changed_by_fkey;

ALTER TABLE contact_changes DROP CONSTRAINT contact_changes_changed_by_fkey;

ALTER TABLE group_changes DROP CONSTRAINT group_changes_changed_by_fkey;

ALTER TABLE group_contact_changes DROP CONSTRAINT group_contact_changes_changed_by_fkey;


ALTER TABLE accounts
  ALTER COLUMN id TYPE int USING id::int,
  ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq');

ALTER TABLE contacts
  ALTER COLUMN account_id TYPE int USING account_id::int,
  ADD FOREIGN KEY (account_id) REFERENCES accounts (id);

ALTER TABLE user_roles
  ALTER COLUMN account_id TYPE int USING account_id::int,
  ADD FOREIGN KEY (account_id) REFERENCES accounts (id);

ALTER TABLE channel_namespace_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);

ALTER TABLE channel_request_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);

ALTER TABLE channel_requests
  ALTER COLUMN target TYPE int USING target::int,
  ADD FOREIGN KEY (target) REFERENCES accounts (id);

ALTER TABLE cloak_change_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);

ALTER TABLE cloak_changes
  ALTER COLUMN target TYPE int USING target::int,
  ADD FOREIGN KEY (target) REFERENCES accounts (id);

ALTER TABLE cloak_changes
  ALTER COLUMN requestor TYPE int USING requestor::int,
  ADD FOREIGN KEY (requestor) REFERENCES accounts (id);

ALTER TABLE cloak_namespace_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);

ALTER TABLE contact_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);

ALTER TABLE group_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);

ALTER TABLE group_contact_changes
  ALTER COLUMN changed_by TYPE int USING changed_by::int,
  ADD FOREIGN KEY (changed_by) REFERENCES accounts (id);
