DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS group_contacts CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS channel_namespaces CASCADE;
DROP TABLE IF EXISTS cloak_namespaces CASCADE;

DROP TYPE IF EXISTS group_status;
CREATE TYPE group_status AS ENUM ('auto_pending', 'auto_verified', 'manual_pending', 'approved');

CREATE TABLE accounts (
    id              SERIAL PRIMARY KEY,
    accountname     VARCHAR(32)
);

CREATE TABLE addresses (
    id              SERIAL PRIMARY KEY,
    address_one     VARCHAR(255) NOT NULL,
    address_two     VARCHAR(255),
    city            VARCHAR(255) NOT NULL,
    state           VARCHAR(255),
    code            VARCHAR(32),
    country         VARCHAR(64) NOT NULL,
    phone           VARCHAR(32),
    phone2          VARCHAR(32)
);

CREATE TABLE contacts (
    id              SERIAL PRIMARY KEY,
    account_id      INTEGER NOT NULL REFERENCES accounts(id),
    name            VARCHAR(255),
    address_id      INTEGER REFERENCES addresses(id)
);

CREATE TABLE groups (
    id              SERIAL PRIMARY KEY,
    groupname       VARCHAR(32) NOT NULL,
    grouptype       INTEGER NOT NULL,
    url             VARCHAR(64) NOT NULL,
    address         INTEGER DEFAULT NULL,
    status          group_status,
    verify_url      VARCHAR(255),
    verify_token    VARCHAR(16),
    submitted       INTEGER NOT NULL,
    verified        INTEGER DEFAULT 0,
    approved        INTEGER DEFAULT 0
);

CREATE TABLE channel_namespaces (
    group_id        INTEGER NOT NULL REFERENCES groups(id),
    namespace       VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE cloak_namespaces (
    group_id        INTEGER NOT NULL REFERENCES groups(id),
    namespace       VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE group_contacts (
    group_id        INTEGER NOT NULL REFERENCES groups(id),
    contact_id      INTEGER NOT NULL REFERENCES accounts(id),
    position        VARCHAR(255),
    PRIMARY KEY (group_id, contact_id)
);

CREATE TABLE roles (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE user_roles (
    account_id      INTEGER REFERENCES accounts(id),
    role_id         INTEGER REFERENCES roles(id),
    PRIMARY KEY (account_id, role_id)
);

