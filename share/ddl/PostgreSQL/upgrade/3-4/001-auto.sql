-- Convert schema 'share/ddl/_source/deploy/3/001-auto.yml' to 'share/ddl/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE cloak_changes ADD COLUMN requestor character varying(32);

CREATE INDEX cloak_changes_idx_requestor on cloak_changes (requestor);

ALTER TABLE cloak_changes ADD CONSTRAINT cloak_changes_fk_requestor FOREIGN KEY (requestor)
  REFERENCES accounts (id) ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

UPDATE cloak_changes SET requestor = changed_by FROM cloak_change_changes WHERE
  cloak_change_id = cloak_changes.id AND cloak_change_changes.status = 'offered';

ALTER TABLE cloak_changes ALTER COLUMN requestor SET NOT NULL;

COMMIT;
