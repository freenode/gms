DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS group_contacts;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS channel_namespaces;
DROP TABLE IF EXISTS cloak_namespaces;

-- An account in GMS is referred to by this ID. Since
-- Atheme does not have globally unique account identifiers,
-- we use a (name, registration time) pair to uniquely identify
-- a services account.
CREATE TABLE accounts (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    accountname     VARCHAR(32)
);

CREATE TABLE contacts (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    account_id      INTEGER NOT NULL,
    name            VARCHAR(255),
    address_id      INTEGER
);

CREATE TABLE groups (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    groupname       VARCHAR(32) NOT NULL,
    grouptype       INTEGER NOT NULL,
    url             VARCHAR(64) NOT NULL,
    address         INTEGER,
    status          ENUM('auto_pending', 'auto_verified', 'manual_pending', 'approved'),
    verify_url      VARCHAR(255),
    verify_token    VARCHAR(16),
    submitted       INTEGER NOT NULL,
    verified        INTEGER DEFAULT 0,
    approved        INTEGER DEFAULT 0
);

CREATE TABLE channel_namespaces (
    group_id        INTEGER NOT NULL,
    namespace       VARCHAR(32)
);

CREATE TABLE cloak_namespaces (
    group_id        INTEGER NOT NULL,
    namespace       VARCHAR(32)
);

CREATE TABLE group_contacts (
    group_id        INTEGER NOT NULL,
    contact_id      INTEGER NOT NULL,
    position        VARCHAR(255),
    PRIMARY KEY (group_id, contact_id)
);

CREATE TABLE addresses (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    address_one     VARCHAR(255) NOT NULL,
    address_two     VARCHAR(255),
    city            VARCHAR(255) NOT NULL,
    state           VARCHAR(255),
    code            VARCHAR(32),
    country         VARCHAR(64) NOT NULL,
    phone           VARCHAR(32),
    phone2          VARCHAR(32)
);

CREATE TABLE roles (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(32)
);

CREATE TABLE user_roles (
    account_id      INTEGER,
    role_id         INTEGER
);
