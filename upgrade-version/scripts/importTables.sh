#!/bin/bash

# Set variables for source and destination MySQL servers
SOURCE_HOST="127.0.0.1"
SOURCE_USER="root"
SOURCE_PASSWORD="nyw"
SOURCE_DATABASE="classicmodels"

DEST_HOST="127.0.0.1"
DEST_USER="root"
DEST_PASSWORD="nyw"
DEST_DATABASE="classicmodels"

# Define an array of tables to move
TABLES=(
    "customers"
    "employees"
    "offices"
    "orderdetails"
    "orders"
    "payments"
    "productlines"
    "products"
)

# Execute SQL script to create database and tables in MySQL 8.0
mysql -h $DEST_HOST -u $DEST_USER -P3309 -p$DEST_PASSWORD < createDatabase.sql &&
echo "Database created successfully"

# Loop through each table and move data using pt-archiver
for TABLE in "${TABLES[@]}"; do
    echo "Moving data for table: $TABLE"
    nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=$TABLE,P=3310,L=/tmp \
                --dest h=$DEST_HOST,u=$DEST_USER,p=$DEST_PASSWORD,D=$DEST_DATABASE,t=$TABLE,P=3309,L=/tmp \
                --where "1=1" --statistics --progress=10000 --limit=1000 --bulk-insert --no-delete --no-safe-auto-increment --why-quit --skip-foreign-key-checks > $TABLE.log &&
    echo "Data moved for table: $TABLE"
done
