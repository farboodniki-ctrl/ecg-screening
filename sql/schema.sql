DROP TABLE IF EXISTS diagnoses, recordings, patients, scp_statements CASCADE;

CREATE TABLE patients (
    patient_id INTEGER PRIMARY KEY,
    sex        SMALLINT              -- طبق PTB-XL: 0 = مرد، 1 = زن
);

CREATE TABLE scp_statements (
    scp_code            TEXT PRIMARY KEY,
    description         TEXT,
    diagnostic          SMALLINT,
    diagnostic_class    TEXT,        -- NORM, MI, STTC, CD, HYP
    diagnostic_subclass TEXT
);

CREATE TABLE recordings (
    ecg_id         INTEGER PRIMARY KEY,
    patient_id     INTEGER NOT NULL REFERENCES patients(patient_id),
    age            REAL,
    height         REAL,
    weight         REAL,
    recording_date TIMESTAMP,
    device         TEXT,
    site           INTEGER,
    strat_fold     SMALLINT,
    filename_lr    TEXT,
    filename_hr    TEXT
);

CREATE TABLE diagnoses (
    ecg_id     INTEGER REFERENCES recordings(ecg_id),
    scp_code   TEXT REFERENCES scp_statements(scp_code),
    likelihood REAL,
    PRIMARY KEY (ecg_id, scp_code)
);