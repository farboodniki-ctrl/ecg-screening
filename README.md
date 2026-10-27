# ECG Screening: PTB-XL Data Pipeline and Analysis

A data pipeline and exploratory analysis of the PTB-XL 12-lead ECG dataset. Recording metadata and diagnostic labels are loaded into PostgreSQL and analysed with SQL and Python.

> This is a learning and portfolio project. It is not a medical device and must not be used for clinical decisions.

## Status

- [x] Week 1: PostgreSQL schema, data loader and initial SQL analysis
- [ ] Week 2: Signal processing, R-peak detection and HRV features
- [ ] Week 3: Patient-grouped modelling (baseline, gradient boosting, SHAP)
- [ ] Week 4: FastAPI service, Power BI dashboard and model card

## Dataset

PTB-XL contains 21,801 clinical 12-lead ECG recordings of 10 seconds each, from 18,869 patients. It is openly available on PhysioNet (version 1.0.2). Recording dates are shifted by a random offset to protect privacy.

Diagnostic statements (SCP-ECG codes) are grouped into five superclasses: NORM, MI, STTC, CD and HYP. One recording can carry several statements, and one patient can have several recordings.

Citation:
- Wagner P. et al. (2020). PTB-XL: A Large Publicly Available ECG Dataset. Scientific Data. https://doi.org/10.1038/s41597-020-0495-6
- PhysioNet dataset: https://doi.org/10.13026/zx4k-te85

## Week 1 Results

| Metric | Value |
|---|---|
| Recordings | 21,801 |
| Patients | 18,869 |
| Patients with 1 recording | 16,756 |
| Patients with 2 or more recordings | 2,113 |
| Diagnosis rows (recording x SCP code) | 61,028 |

Recordings per superclass (a recording can belong to several):

| Superclass | Recordings |
|---|---|
| NORM | 9,517 |
| MI | 5,473 |
| STTC | 5,237 |
| CD | 4,901 |
| HYP | 2,649 |

Mean patient age per superclass: NORM 52.9 years, MI 71.4, STTC 72.4, CD 72.1, HYP 70.8. These are descriptive associations in this dataset, not causal effects.

## Project Structure

```
sql/schema.sql       tables: patients, recordings, diagnoses, scp_statements
sql/analysis.sql     five analysis queries
src/load_db.py       loads PTB-XL metadata into PostgreSQL
docker-compose.yml   PostgreSQL 16 container
```

## Reproduce

Requirements: Docker Desktop and Python 3.10 or newer.

```bash
# 1. Start PostgreSQL
docker compose up -d

# 2. Download ptbxl_database.csv and scp_statements.csv from
#    https://physionet.org/content/ptb-xl/1.0.2/
#    and place them in data/raw/ptb-xl/

# 3. Create a .env file in the project root with:
#    DATABASE_URL=postgresql+psycopg://ecg:ecg@localhost:5432/ecg

# 4. Python environment
python3 -m venv .venv
source .venv/bin/activate
pip install pandas sqlalchemy "psycopg[binary]" python-dotenv

# 5. Create schema and load data
docker compose exec -T db psql -U ecg -d ecg < sql/schema.sql
python src/load_db.py

# 6. Run the analysis queries
docker compose exec -T db psql -U ecg -d ecg < sql/analysis.sql
```

Expected: `SELECT COUNT(*) FROM recordings;` returns 21801.

## Limitations

- The dataset comes from a single source and does not represent all populations or devices.
- Recording dates span from the late 1980s to the late 1990s, so differences in equipment and practice are likely.
- Labels are ECG statements, not confirmed clinical diagnoses.
- The analysis has not been validated and has no regulatory approval.

## Data Use

The data is used under PhysioNet's open-access terms. Patient identifiers are anonymised in the source.