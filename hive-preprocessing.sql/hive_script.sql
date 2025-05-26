-- CREATE EXTERNAL TABLE
CREATE EXTERNAL TABLE IF NOT EXISTS drug_overdose_mortality (
    INDICATOR STRING,
    PANEL STRING,
    PANEL_NUM INT,
    UNIT STRING,
    UNIT_NUM INT,
    STUB_NAME STRING,
    STUB_NAME_NUM INT,
    STUB_LABEL STRING,
    YEAR INT,
    YEAR_NUM INT,
    AGE STRING,          
    AGE_NUM DOUBLE,
    ESTIMATE STRING,
    FLAG STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar"     = "\""
)
STORED AS TEXTFILE
LOCATION '/user/maria_dev/afiqah/'
TBLPROPERTIES ("skip.header.line.count"="1");

-- CLEAN AND CREATE FINAL TABLE
DROP TABLE IF EXISTS dod_final;

CREATE TABLE dod_final AS
SELECT 
  panel,
  unit_num,
  stub_label,
  year,
  age,

  -- Cleaned estimate column
  CASE
    WHEN TRIM(estimate) IN ('', 'NA', '..') THEN NULL
    ELSE CAST(estimate AS DOUBLE)
  END AS estimate,

  -- Gender extraction
  CASE
    WHEN LOWER(stub_label) LIKE 'male%' THEN 'Male'
    WHEN LOWER(stub_label) LIKE 'female%' THEN 'Female'
    WHEN LOWER(stub_label) LIKE '%all persons%' THEN 'All'
    ELSE 'Unknown'
  END AS gender,

  -- Cause of death
  CASE
    WHEN LOWER(panel) LIKE '%heroin%' THEN 'Heroin'
    WHEN LOWER(panel) LIKE '%methadone%' THEN 'Methadone'
    WHEN LOWER(panel) LIKE '%synthetic opioids%' THEN 'Synthetic Opioid'
    WHEN LOWER(panel) LIKE '%natural and semisynthetic%' THEN 'Semisynthetic Opioid'
    WHEN LOWER(panel) LIKE '%opioid%' THEN 'Opioid'
    WHEN LOWER(panel) LIKE '%all drug overdose%' THEN 'All'
    ELSE 'Other'
  END AS cause_of_death,

  -- Age code extraction
  CASE
    WHEN age IS NOT NULL THEN
      CASE
        WHEN age = 'Under 15 years' THEN 1
        WHEN age = '15-24 years' THEN 2
        WHEN age = '25-34 years' THEN 3
        WHEN age = '35-44 years' THEN 4
        WHEN age = '45-54 years' THEN 5
        WHEN age = '55-64 years' THEN 6
        WHEN age = '65-74 years' THEN 7
        WHEN age = '75-84 years' THEN 8
        WHEN age = '85 years and over' THEN 9
        WHEN age = 'All ages' THEN 0
        ELSE NULL
      END
    ELSE
      CASE
        WHEN LOWER(stub_label) LIKE '%under 15%' THEN 1
        WHEN LOWER(stub_label) LIKE '%15-24%' THEN 2
        WHEN LOWER(stub_label) LIKE '%25-34%' THEN 3
        WHEN LOWER(stub_label) LIKE '%35-44%' THEN 4
        WHEN LOWER(stub_label) LIKE '%45-54%' THEN 5
        WHEN LOWER(stub_label) LIKE '%55-64%' THEN 6
        WHEN LOWER(stub_label) LIKE '%65-74%' THEN 7
        WHEN LOWER(stub_label) LIKE '%75-84%' THEN 8
        WHEN LOWER(stub_label) LIKE '%85 years and over%' THEN 9
        WHEN LOWER(stub_label) LIKE '%all ages%' THEN 0
        ELSE NULL
      END
  END AS age_code

FROM drug_overdose_mortality;
