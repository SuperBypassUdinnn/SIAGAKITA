-- ============================================================
-- SiagaKita — Database Schema Migration
-- Version: 001_init_schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- MASTER TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS m_ranks (
    id        SERIAL PRIMARY KEY,
    rank_name VARCHAR(100) NOT NULL,
    min_exp   INT          NOT NULL DEFAULT 0,
    icon_url  VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS m_badges (
    id          SERIAL PRIMARY KEY,
    badge_name  VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url    VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS agencies (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name          VARCHAR(255) NOT NULL,
    type          VARCHAR(100),
    city_code     VARCHAR(20),
    hotline_number VARCHAR(20)
);

-- ============================================================
-- USERS
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name            VARCHAR(255) NOT NULL,
    nik                  VARCHAR(16)  UNIQUE,
    date_of_birth        DATE,
    phone_number         VARCHAR(20),
    email                VARCHAR(255) NOT NULL UNIQUE,
    password_hash        VARCHAR(255) NOT NULL,
    role                 VARCHAR(50)  NOT NULL DEFAULT 'masyarakat',
    is_verified_volunteer BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at           TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_email      ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role       ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);

-- ============================================================
-- USER MEDICAL PROFILES
-- ============================================================

CREATE TABLE IF NOT EXISTS user_medical_profiles (
    user_id            UUID        PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    blood_type         VARCHAR(5),
    allergies          TEXT,
    medical_conditions TEXT,
    height_cm          INT,
    weight_kg          INT,
    alamat             TEXT,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- EMERGENCY CONTACTS
-- ============================================================

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_name  VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20)  NOT NULL,
    relation      VARCHAR(100),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_emergency_contacts_user_id ON emergency_contacts(user_id);

-- ============================================================
-- VOLUNTEER REPUTATION
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_reputation (
    user_id       UUID        PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    exp_points    INT         NOT NULL DEFAULT 0,
    rank_id       INT         REFERENCES m_ranks(id),
    total_rescues INT         NOT NULL DEFAULT 0,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- AGENCY PERSONNELS
-- ============================================================

CREATE TABLE IF NOT EXISTS agency_personnels (
    user_id       UUID        PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    agency_id     UUID        NOT NULL REFERENCES agencies(id),
    badge_number  VARCHAR(50)
);

-- ============================================================
-- VOLUNTEER CERTIFICATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_certifications (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    certificate_type VARCHAR(100) NOT NULL,
    document_url     VARCHAR(255),
    status           VARCHAR(50)  NOT NULL DEFAULT 'pending',
    verified_by      UUID        REFERENCES users(id),
    expires_at       TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- VOLUNTEER BADGES
-- ============================================================

CREATE TABLE IF NOT EXISTS volunteer_badges_acquired (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id   INT         NOT NULL REFERENCES m_badges(id),
    earned_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INCIDENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS incidents (
    id             BIGSERIAL    PRIMARY KEY,
    reporter_id    UUID         NOT NULL REFERENCES users(id),
    incident_type  VARCHAR(100),
    latitude       DOUBLE PRECISION NOT NULL,
    longitude      DOUBLE PRECISION NOT NULL,
    status         VARCHAR(50)  NOT NULL DEFAULT 'grace_period',
    address_detail TEXT,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    resolved_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_incidents_reporter_id ON incidents(reporter_id);
CREATE INDEX IF NOT EXISTS idx_incidents_status      ON incidents(status);

-- ============================================================
-- INCIDENT RESPONSES
-- ============================================================

CREATE TABLE IF NOT EXISTS incident_responses (
    id           BIGSERIAL    PRIMARY KEY,
    incident_id  BIGINT       NOT NULL REFERENCES incidents(id),
    responder_id UUID         NOT NULL REFERENCES users(id),
    status       VARCHAR(50)  NOT NULL DEFAULT 'en_route',
    accepted_at  TIMESTAMPTZ,
    arrived_at   TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_incident_responses_incident_id  ON incident_responses(incident_id);
CREATE INDEX IF NOT EXISTS idx_incident_responses_responder_id ON incident_responses(responder_id);

-- ============================================================
-- SEED: Master Ranks
-- ============================================================

INSERT INTO m_ranks (rank_name, min_exp, icon_url) VALUES
    ('Relawan Baru',   0,    NULL),
    ('Relawan Muda',   200,  NULL),
    ('Relawan Madya',  500,  NULL),
    ('Relawan Senior', 1000, NULL),
    ('Relawan Ahli',   2000, NULL)
ON CONFLICT DO NOTHING;
