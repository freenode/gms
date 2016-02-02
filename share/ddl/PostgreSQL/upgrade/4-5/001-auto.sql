-- Convert schema 'share/ddl/_source/deploy/4/001-auto.yml' to 'share/ddl/_source/deploy/5/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE cloak_changes ALTER COLUMN requestor SET NOT NULL;

;

COMMIT;

