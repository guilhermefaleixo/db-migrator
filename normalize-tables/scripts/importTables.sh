#!/bin/bash

# Set variables for source and destination MySQL servers
SOURCE_HOST="127.0.0.1"
SOURCE_USER="root"
SOURCE_PASSWORD="pass"
SOURCE_DATABASE="classicmodels"

DEST_HOST="127.0.0.1"
DEST_USER="root"
DEST_PASSWORD="pass"
DEST_DATABASE="classicmodels"

# Define an array of tables to move
TABLES=(
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

echo "Moving data for table: customers"
nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=customers,P=3310,L=/tmp \
                --dest h=$DEST_HOST,u=$DEST_USER,p=$DEST_PASSWORD,D=$DEST_DATABASE,t=customers,P=3309,L=/tmp \
                --where "1=1" --statistics --progress=10000 --limit=1000 --no-delete --no-safe-auto-increment --why-quit --bulk-insert --no-check-columns --skip-foreign-key > customers.log &&
echo "Data moved for table: customers"

echo "Moving data for table: addresses"
nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=customers,P=3310,L=/tmp \
                --dest h=$DEST_HOST,u=$DEST_USER,p=$DEST_PASSWORD,D=$DEST_DATABASE,t=addresses,P=3309,L=/tmp \
                --where "1=1" --statistics --progress=10000 --limit=1000 --no-delete --no-check-columns --no-safe-auto-increment --columns=city,state,postalcode,country,addressline1,addressline2,customernumber --why-quit  > addresses.log &&
echo "Data moved for table: addresses"
