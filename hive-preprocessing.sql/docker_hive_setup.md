# Apache Hive via Docker – Setup Notes

This project used Apache Hive inside a Docker container to perform initial data cleaning before analysis.

## Tools
- Docker
- Hive

## Steps I Followed
1. Pulled Docker image: `docker pull bde2020/hive`
2. Started Hive container with Docker Compose
3. Ambari Hive View 2.0
4. Created external table from raw CSV
5. Cleaned and transformed data using Hive SQL
6. Exported cleaned table as CSV into local machine
7. Uploaded CSV into Google Colab for further analysis

➡️ See `hive_script.sql` for the actual Hive queries used.
