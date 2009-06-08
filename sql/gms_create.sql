DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS `group`;
DROP TABLE IF EXISTS group_contact;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS user_role;

-- An account in GMS is referred to by this ID. Since
-- Atheme does not have globally unique account identifiers,
-- we use a (name, registration time) pair to uniquely identify
-- a services account.
CREATE TABLE account (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    accountname     VARCHAR(32),
    accountts       TIMESTAMP DEFAULT 0
);

CREATE TABLE contact (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    account_id      INTEGER NOT NULL,
    name            VARCHAR(255),
    address         INTEGER
);


CREATE TABLE `group` (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    groupname       VARCHAR(32) NOT NULL,
    grouptype       INTEGER NOT NULL,
    url             VARCHAR(64) NOT NULL,
    address         INTEGER,
    status          ENUM('new', 'verified', 'approved'),
    verify_url      VARCHAR(255),
    submitted       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified        TIMESTAMP DEFAULT 0,
    approved        TIMESTAMP DEFAULT 0
);

CREATE TABLE group_contact (
    group_id        INTEGER NOT NULL,
    contact_id      INTEGER NOT NULL,
    position        VARCHAR(255)
);

CREATE TABLE address (
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

CREATE TABLE role (
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(32)
);

CREATE TABLE user_role (
    account_id      INTEGER,
    role_id         INTEGER
);
