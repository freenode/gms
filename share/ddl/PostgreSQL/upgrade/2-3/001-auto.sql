-- Convert schema 'share/ddl/_source/deploy/2/001-auto.yml' to 'share/ddl/_source/deploy/3/001-auto.yml':;

;

BEGIN;

;
DROP TYPE IF EXISTS change_type CASCADE;
CREATE TYPE change_type AS ENUM ('create', 'request', 'approve', 'reject', 'admin', 'workflow_change');

;
DROP TYPE IF EXISTS channel_namespace_status_type CASCADE;
CREATE TYPE channel_namespace_status_type AS ENUM ('active', 'deleted', 'pending_staff');

;
DROP TYPE IF EXISTS group_type CASCADE;
CREATE TYPE group_type AS ENUM ('informal', 'corporation', 'education', 'government', 'nfp', 'internal');

;
DROP TYPE IF EXISTS group_status CASCADE;
CREATE TYPE group_status AS ENUM ('submitted', 'verified', 'active', 'deleted', 'pending_web', 'pending_staff', 'pending_auto');

;
DROP TYPE IF EXISTS channel_namespace_changes_status_type CASCADE;
CREATE TYPE channel_namespace_changes_status_type AS ENUM ('active', 'deleted', 'pending_staff');

;
DROP TYPE IF EXISTS channel_namespace_changes_change_type_type CASCADE;
CREATE TYPE channel_namespace_changes_change_type_type AS ENUM ('create', 'request', 'approve', 'reject', 'admin', 'workflow_change');

;
DROP TYPE IF EXISTS group_contact_status CASCADE;
CREATE TYPE group_contact_status AS ENUM ('invited', 'retired', 'active', 'deleted', 'pending_staff');

;
DROP TYPE IF EXISTS cloak_namespace_changes_status_type CASCADE;
CREATE TYPE cloak_namespace_changes_status_type AS ENUM ('active', 'deleted', 'pending_staff');

;
DROP TYPE IF EXISTS cloak_namespace_changes_change_type_type CASCADE;
CREATE TYPE cloak_namespace_changes_change_type_type AS ENUM ('create', 'request', 'approve', 'reject', 'admin', 'workflow_change');

;
DROP TYPE IF EXISTS cloak_change_status CASCADE;
CREATE TYPE cloak_change_status AS ENUM ('offered', 'accepted', 'approved', 'rejected', 'applied', 'error');

;
DROP TYPE IF EXISTS group_verifications_verification_type_type CASCADE;
CREATE TYPE group_verifications_verification_type_type AS ENUM ('web_url', 'web_token', 'git', 'dns', 'freetext');

;
DROP TYPE IF EXISTS request_type CASCADE;
CREATE TYPE request_type AS ENUM ('flags', 'transfer', 'drop');

;
DROP TYPE IF EXISTS channel_request_status CASCADE;
CREATE TYPE channel_request_status AS ENUM ('pending_staff', 'approved', 'rejected', 'applied', 'error');

;

ALTER TABLE contact_changes ALTER change_type TYPE change_type USING change_type::change_type;
ALTER TABLE group_changes ALTER change_type TYPE change_type USING change_type::change_type;
ALTER TABLE group_contact_changes ALTER change_type TYPE change_type USING change_type::change_type;

ALTER TABLE channel_namespaces ALTER "status" TYPE channel_namespace_status_type USING status::channel_namespace_status_type;
ALTER TABLE cloak_namespaces ALTER "status" TYPE channel_namespace_status_type USING status::channel_namespace_status_type;


ALTER TABLE groups ALTER group_type TYPE group_type USING group_type::group_type;
ALTER TABLE group_changes ALTER group_type TYPE group_type USING group_type::group_type;
ALTER TABLE groups ALTER "status" TYPE group_status USING status::group_status;
ALTER TABLE group_changes ALTER "status" TYPE group_status USING status::group_status;

ALTER TABLE channel_namespace_changes ALTER "status" TYPE channel_namespace_changes_status_type USING status::channel_namespace_changes_status_type;
ALTER TABLE channel_namespace_changes ALTER change_type TYPE channel_namespace_changes_change_type_type USING change_type::channel_namespace_changes_change_type_type;

ALTER TABLE group_contacts  ALTER "status" TYPE group_contact_status USING status::group_contact_status;
ALTER TABLE group_contact_changes ALTER "status" TYPE group_contact_status USING status::group_contact_status;

ALTER TABLE cloak_namespace_changes ALTER "status" TYPE cloak_namespace_changes_status_type USING status::cloak_namespace_changes_status_type;
ALTER TABLE cloak_namespace_changes ALTER change_type TYPE cloak_namespace_changes_change_type_type USING change_type::cloak_namespace_changes_change_type_type;


ALTER TABLE cloak_changes ALTER "status" TYPE cloak_change_status USING status::cloak_change_status;
ALTER TABLE cloak_change_changes ALTER "status" TYPE cloak_change_status USING status::cloak_change_status;

ALTER TABLE group_verifications ALTER verification_type TYPE group_verifications_verification_type_type USING verification_type::group_verifications_verification_type_type;


ALTER TABLE channel_requests ALTER request_type TYPE request_type USING request_type::request_type;

ALTER TABLE channel_requests ALTER "status" TYPE channel_request_status USING status::channel_request_status;
ALTER TABLE channel_request_changes ALTER "status" TYPE channel_request_status USING status::channel_request_status;

COMMIT;
