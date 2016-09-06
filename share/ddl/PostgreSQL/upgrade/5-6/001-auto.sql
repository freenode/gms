-- Convert schema 'share/ddl/_source/deploy/5/001-auto.yml' to 'share/ddl/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
DROP TABLE channel_request_changes CASCADE;

;
DROP TABLE channel_requests CASCADE;

;
DROP TABLE cloak_change_changes CASCADE;

;
DROP TABLE cloak_changes CASCADE;

;

COMMIT;

