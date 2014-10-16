-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Oct 16 18:52:29 2014
-- 
;
--
-- Table: accounts.
--
CREATE TABLE "accounts" (
  "id" character varying(9) NOT NULL,
  "accountname" character varying(32),
  "dropped" integer DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: addresses.
--
CREATE TABLE "addresses" (
  "id" serial NOT NULL,
  "address_one" character varying(255) NOT NULL,
  "address_two" character varying(255),
  "city" character varying(255) NOT NULL,
  "state" character varying(255),
  "code" character varying(32),
  "country" character varying(64) NOT NULL,
  "phone" character varying(32),
  "phone2" character varying(32),
  PRIMARY KEY ("id")
);

;
--
-- Table: channel_namespace_changes.
--
CREATE TABLE "channel_namespace_changes" (
  "id" serial NOT NULL,
  "group_id" integer NOT NULL,
  "namespace_id" integer NOT NULL,
  "time" timestamp DEFAULT current_timestamp NOT NULL,
  "changed_by" text NOT NULL,
  "change_type" character varying NOT NULL,
  "status" character varying NOT NULL,
  "affected_change" integer,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "channel_namespace_changes_idx_affected_change" on "channel_namespace_changes" ("affected_change");
CREATE INDEX "channel_namespace_changes_idx_changed_by" on "channel_namespace_changes" ("changed_by");
CREATE INDEX "channel_namespace_changes_idx_group_id" on "channel_namespace_changes" ("group_id");
CREATE INDEX "channel_namespace_changes_idx_namespace_id" on "channel_namespace_changes" ("namespace_id");

;
--
-- Table: channel_namespaces.
--
CREATE TABLE "channel_namespaces" (
  "id" serial NOT NULL,
  "namespace" character varying(50) NOT NULL,
  "active_change" integer DEFAULT -1 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "channel_namespaces_unique_active_change" UNIQUE ("active_change"),
  CONSTRAINT "unique_channel_ns" UNIQUE ("namespace")
);
CREATE INDEX "channel_namespaces_idx_active_change" on "channel_namespaces" ("active_change");

;
--
-- Table: channel_request_changes.
--
CREATE TABLE "channel_request_changes" (
  "id" serial NOT NULL,
  "channel_request_id" integer NOT NULL,
  "time" timestamp DEFAULT current_timestamp NOT NULL,
  "changed_by" text NOT NULL,
  "status" character varying NOT NULL,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "channel_request_changes_idx_changed_by" on "channel_request_changes" ("changed_by");
CREATE INDEX "channel_request_changes_idx_channel_request_id" on "channel_request_changes" ("channel_request_id");

;
--
-- Table: channel_requests.
--
CREATE TABLE "channel_requests" (
  "id" serial NOT NULL,
  "request_type" character varying NOT NULL,
  "requestor" integer NOT NULL,
  "channel" character varying(50) NOT NULL,
  "target" character varying(32),
  "request_data" text,
  "active_change" integer DEFAULT -1 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_channel_request_active_change" UNIQUE ("active_change")
);
CREATE INDEX "channel_requests_idx_active_change" on "channel_requests" ("active_change");
CREATE INDEX "channel_requests_idx_requestor" on "channel_requests" ("requestor");
CREATE INDEX "channel_requests_idx_target" on "channel_requests" ("target");

;
--
-- Table: cloak_change_changes.
--
CREATE TABLE "cloak_change_changes" (
  "id" serial NOT NULL,
  "cloak_change_id" integer NOT NULL,
  "time" timestamp DEFAULT current_timestamp NOT NULL,
  "changed_by" text NOT NULL,
  "status" character varying NOT NULL,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "cloak_change_changes_idx_changed_by" on "cloak_change_changes" ("changed_by");
CREATE INDEX "cloak_change_changes_idx_cloak_change_id" on "cloak_change_changes" ("cloak_change_id");

;
--
-- Table: cloak_changes.
--
CREATE TABLE "cloak_changes" (
  "id" serial NOT NULL,
  "target" character varying(32) NOT NULL,
  "cloak" character varying(63) NOT NULL,
  "active_change" integer DEFAULT -1 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_cloak_active_change" UNIQUE ("active_change")
);
CREATE INDEX "cloak_changes_idx_active_change" on "cloak_changes" ("active_change");
CREATE INDEX "cloak_changes_idx_target" on "cloak_changes" ("target");

;
--
-- Table: cloak_namespace_changes.
--
CREATE TABLE "cloak_namespace_changes" (
  "id" serial NOT NULL,
  "group_id" integer NOT NULL,
  "namespace_id" integer NOT NULL,
  "time" timestamp DEFAULT current_timestamp NOT NULL,
  "changed_by" text NOT NULL,
  "change_type" character varying NOT NULL,
  "status" character varying NOT NULL,
  "affected_change" integer,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "cloak_namespace_changes_idx_affected_change" on "cloak_namespace_changes" ("affected_change");
CREATE INDEX "cloak_namespace_changes_idx_changed_by" on "cloak_namespace_changes" ("changed_by");
CREATE INDEX "cloak_namespace_changes_idx_group_id" on "cloak_namespace_changes" ("group_id");
CREATE INDEX "cloak_namespace_changes_idx_namespace_id" on "cloak_namespace_changes" ("namespace_id");

;
--
-- Table: cloak_namespaces.
--
CREATE TABLE "cloak_namespaces" (
  "id" serial NOT NULL,
  "namespace" character varying(63) NOT NULL,
  "active_change" integer DEFAULT -1 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "cloak_namespaces_unique_active_change" UNIQUE ("active_change"),
  CONSTRAINT "unique_cloak_ns" UNIQUE ("namespace")
);
CREATE INDEX "cloak_namespaces_idx_active_change" on "cloak_namespaces" ("active_change");

;
--
-- Table: contact_changes.
--
CREATE TABLE "contact_changes" (
  "id" serial NOT NULL,
  "contact_id" integer NOT NULL,
  "time" timestamp DEFAULT current_timestamp NOT NULL,
  "changed_by" text NOT NULL,
  "name" character varying(255) NOT NULL,
  "phone" character varying(32),
  "email" character varying(255) NOT NULL,
  "change_type" character varying NOT NULL,
  "affected_change" integer,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "contact_changes_idx_affected_change" on "contact_changes" ("affected_change");
CREATE INDEX "contact_changes_idx_changed_by" on "contact_changes" ("changed_by");
CREATE INDEX "contact_changes_idx_contact_id" on "contact_changes" ("contact_id");

;
--
-- Table: contacts.
--
CREATE TABLE "contacts" (
  "id" serial NOT NULL,
  "account_id" text NOT NULL,
  "active_change" integer DEFAULT -1 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_account" UNIQUE ("account_id"),
  CONSTRAINT "unique_contact_active_change" UNIQUE ("active_change")
);
CREATE INDEX "contacts_idx_account_id" on "contacts" ("account_id");
CREATE INDEX "contacts_idx_active_change" on "contacts" ("active_change");

;
--
-- Table: group_changes.
--
CREATE TABLE "group_changes" (
  "id" serial NOT NULL,
  "group_id" integer NOT NULL,
  "time" timestamp DEFAULT current_timestamp NOT NULL,
  "changed_by" text NOT NULL,
  "change_type" character varying NOT NULL,
  "group_type" character varying NOT NULL,
  "url" character varying(64) NOT NULL,
  "address" integer,
  "status" character varying NOT NULL,
  "affected_change" integer,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "group_changes_idx_address" on "group_changes" ("address");
CREATE INDEX "group_changes_idx_affected_change" on "group_changes" ("affected_change");
CREATE INDEX "group_changes_idx_changed_by" on "group_changes" ("changed_by");
CREATE INDEX "group_changes_idx_group_id" on "group_changes" ("group_id");

;
--
-- Table: group_contact_changes.
--
CREATE TABLE "group_contact_changes" (
  "id" serial NOT NULL,
  "group_id" integer NOT NULL,
  "contact_id" integer NOT NULL,
  "primary" boolean DEFAULT false NOT NULL,
  "status" character varying NOT NULL,
  "change_type" character varying NOT NULL,
  "changed_by" text NOT NULL,
  "affected_change" integer,
  "change_freetext" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "group_contact_changes_idx_affected_change" on "group_contact_changes" ("affected_change");
CREATE INDEX "group_contact_changes_idx_changed_by" on "group_contact_changes" ("changed_by");
CREATE INDEX "group_contact_changes_idx_group_id_contact_id" on "group_contact_changes" ("group_id", "contact_id");

;
--
-- Table: group_verifications.
--
CREATE TABLE "group_verifications" (
  "id" serial NOT NULL,
  "group_id" integer,
  "verification_type" character varying,
  "verification_data" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "group_verifications_idx_group_id" on "group_verifications" ("group_id");

;
--
-- Table: groups.
--
CREATE TABLE "groups" (
  "id" serial NOT NULL,
  "group_name" character varying(32) NOT NULL,
  "submitted" timestamp DEFAULT current_timestamp NOT NULL,
  "verify_auto" boolean NOT NULL,
  "active_change" integer DEFAULT -1 NOT NULL,
  "deleted" integer DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_active_change" UNIQUE ("active_change"),
  CONSTRAINT "unique_group_name" UNIQUE ("group_name", "deleted")
);
CREATE INDEX "groups_idx_active_change" on "groups" ("active_change");

;
--
-- Table: roles.
--
CREATE TABLE "roles" (
  "id" serial NOT NULL,
  "name" character varying(32) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "roles_name_key" UNIQUE ("name")
);

;
--
-- Table: user_roles.
--
CREATE TABLE "user_roles" (
  "account_id" text NOT NULL,
  "role_id" integer NOT NULL,
  PRIMARY KEY ("account_id", "role_id")
);
CREATE INDEX "user_roles_idx_account_id" on "user_roles" ("account_id");
CREATE INDEX "user_roles_idx_role_id" on "user_roles" ("role_id");

;
--
-- Table: group_contacts.
--
CREATE TABLE "group_contacts" (
  "group_id" integer NOT NULL,
  "contact_id" integer NOT NULL,
  "active_change" integer DEFAULT -1 NOT NULL,
  PRIMARY KEY ("group_id", "contact_id"),
  CONSTRAINT "group_contacts_unique_active_change" UNIQUE ("active_change")
);
CREATE INDEX "group_contacts_idx_active_change" on "group_contacts" ("active_change");
CREATE INDEX "group_contacts_idx_contact_id" on "group_contacts" ("contact_id");
CREATE INDEX "group_contacts_idx_group_id" on "group_contacts" ("group_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "channel_namespace_changes" ADD CONSTRAINT "channel_namespace_changes_fk_affected_change" FOREIGN KEY ("affected_change")
  REFERENCES "channel_namespace_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_namespace_changes" ADD CONSTRAINT "channel_namespace_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_namespace_changes" ADD CONSTRAINT "channel_namespace_changes_fk_group_id" FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_namespace_changes" ADD CONSTRAINT "channel_namespace_changes_fk_namespace_id" FOREIGN KEY ("namespace_id")
  REFERENCES "channel_namespaces" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_namespaces" ADD CONSTRAINT "channel_namespaces_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "channel_namespace_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_request_changes" ADD CONSTRAINT "channel_request_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_request_changes" ADD CONSTRAINT "channel_request_changes_fk_channel_request_id" FOREIGN KEY ("channel_request_id")
  REFERENCES "channel_requests" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_requests" ADD CONSTRAINT "channel_requests_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "channel_request_changes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "channel_requests" ADD CONSTRAINT "channel_requests_fk_requestor" FOREIGN KEY ("requestor")
  REFERENCES "contacts" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "channel_requests" ADD CONSTRAINT "channel_requests_fk_target" FOREIGN KEY ("target")
  REFERENCES "accounts" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "cloak_change_changes" ADD CONSTRAINT "cloak_change_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "cloak_change_changes" ADD CONSTRAINT "cloak_change_changes_fk_cloak_change_id" FOREIGN KEY ("cloak_change_id")
  REFERENCES "cloak_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "cloak_changes" ADD CONSTRAINT "cloak_changes_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "cloak_change_changes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "cloak_changes" ADD CONSTRAINT "cloak_changes_fk_target" FOREIGN KEY ("target")
  REFERENCES "accounts" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "cloak_namespace_changes" ADD CONSTRAINT "cloak_namespace_changes_fk_affected_change" FOREIGN KEY ("affected_change")
  REFERENCES "cloak_namespace_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "cloak_namespace_changes" ADD CONSTRAINT "cloak_namespace_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "cloak_namespace_changes" ADD CONSTRAINT "cloak_namespace_changes_fk_group_id" FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "cloak_namespace_changes" ADD CONSTRAINT "cloak_namespace_changes_fk_namespace_id" FOREIGN KEY ("namespace_id")
  REFERENCES "cloak_namespaces" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "cloak_namespaces" ADD CONSTRAINT "cloak_namespaces_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "cloak_namespace_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "contact_changes" ADD CONSTRAINT "contact_changes_fk_affected_change" FOREIGN KEY ("affected_change")
  REFERENCES "contact_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "contact_changes" ADD CONSTRAINT "contact_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "contact_changes" ADD CONSTRAINT "contact_changes_fk_contact_id" FOREIGN KEY ("contact_id")
  REFERENCES "contacts" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "contacts" ADD CONSTRAINT "contacts_fk_account_id" FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id") ON DELETE CASCADE ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "contacts" ADD CONSTRAINT "contacts_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "contact_changes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "group_changes" ADD CONSTRAINT "group_changes_fk_address" FOREIGN KEY ("address")
  REFERENCES "addresses" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "group_changes" ADD CONSTRAINT "group_changes_fk_affected_change" FOREIGN KEY ("affected_change")
  REFERENCES "group_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "group_changes" ADD CONSTRAINT "group_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "group_changes" ADD CONSTRAINT "group_changes_fk_group_id" FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "group_contact_changes" ADD CONSTRAINT "group_contact_changes_fk_affected_change" FOREIGN KEY ("affected_change")
  REFERENCES "group_contact_changes" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "group_contact_changes" ADD CONSTRAINT "group_contact_changes_fk_changed_by" FOREIGN KEY ("changed_by")
  REFERENCES "accounts" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "group_contact_changes" ADD CONSTRAINT "group_contact_changes_fk_group_id_contact_id" FOREIGN KEY ("group_id", "contact_id")
  REFERENCES "group_contacts" ("group_id", "contact_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "group_verifications" ADD CONSTRAINT "group_verifications_fk_group_id" FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "groups" ADD CONSTRAINT "groups_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "group_changes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_fk_account_id" FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_fk_role_id" FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "group_contacts" ADD CONSTRAINT "group_contacts_fk_active_change" FOREIGN KEY ("active_change")
  REFERENCES "group_contact_changes" ("id") DEFERRABLE;

;
ALTER TABLE "group_contacts" ADD CONSTRAINT "group_contacts_fk_contact_id" FOREIGN KEY ("contact_id")
  REFERENCES "contacts" ("id") DEFERRABLE;

;
ALTER TABLE "group_contacts" ADD CONSTRAINT "group_contacts_fk_group_id" FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
