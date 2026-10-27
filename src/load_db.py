import ast
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()
engine = create_engine(os.environ["DATABASE_URL"])
RAW = "data/raw/ptb-xl"

# ۱) خواندن فایل‌های خام
db = pd.read_csv(f"{RAW}/ptbxl_database.csv", index_col="ecg_id")
scp = pd.read_csv(f"{RAW}/scp_statements.csv", index_col=0)
scp.index.name = "scp_code"
db["scp_codes"] = db["scp_codes"].apply(ast.literal_eval)

# ۲) ساخت جدول‌ها
patients = db.reset_index().groupby("patient_id", as_index=False)["sex"].first()

recordings = db[[
    "patient_id", "age", "height", "weight", "recording_date",
    "device", "site", "strat_fold", "filename_lr", "filename_hr",
]].reset_index()
recordings["recording_date"] = pd.to_datetime(recordings["recording_date"])

statements = scp[[
    "description", "diagnostic", "diagnostic_class", "diagnostic_subclass",
]].reset_index()

diagnoses = pd.DataFrame(
    [(ecg_id, code, lik)
     for ecg_id, codes in db["scp_codes"].items()
     for code, lik in codes.items()],
    columns=["ecg_id", "scp_code", "likelihood"],
)

# ۳) بارگذاری به ترتیب وابستگی: اول جدول‌های مرجع
with engine.begin() as conn:
    patients.to_sql("patients", conn, if_exists="append", index=False)
    statements.to_sql("scp_statements", conn, if_exists="append", index=False)
    recordings.to_sql("recordings", conn, if_exists="append", index=False)
    diagnoses.to_sql("diagnoses", conn, if_exists="append", index=False, chunksize=5000)

print("loaded")
