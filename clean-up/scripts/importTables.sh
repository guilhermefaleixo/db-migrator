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
    "customers"
    "employees"
    "offices"
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

echo "Moving data for table: payments"
nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=payments,P=3310,L=/tmp \
                --dest h=$DEST_HOST,u=$DEST_USER,p=$DEST_PASSWORD,D=$DEST_DATABASE,t=payments,P=3309,L=/tmp \
                --where "paymentdate > DATE_SUB(NOW(), INTERVAL 25 MONTH)" --statistics --progress=10000 --limit=1000 --no-delete --no-safe-auto-increment --why-quit --bulk-insert --skip-foreign-key > payments.log &&
echo "Data moved for table: payments"

echo "Moving data for table: orders"
nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=orders,P=3310,L=/tmp \
                --dest h=$DEST_HOST,u=$DEST_USER,p=$DEST_PASSWORD,D=$DEST_DATABASE,t=orders,P=3309,L=/tmp \
                --where "orderdate > DATE_SUB(NOW(), INTERVAL 25 MONTH)" --statistics --progress=10000 --limit=1000 --no-delete --no-safe-auto-increment --why-quit --bulk-insert --skip-foreign-key > orders.log &&
echo "Data moved for table: orders"

echo "Moving data for table: orderdetails"
nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=orderdetails,P=3310,L=/tmp \
                --dest h=$DEST_HOST,u=$DEST_USER,p=$DEST_PASSWORD,D=$DEST_DATABASE,t=orderdetails,P=3309,L=/tmp \
                --where "ordernumber in (Select ordernumber FROM orders WHERE orderdate > DATE_SUB(NOW(), INTERVAL 25 MONTH))" --statistics --progress=10000 --limit=1000 --no-delete --no-safe-auto-increment --why-quit --bulk-insert --skip-foreign-key > orderdetails.log &&
echo "Data moved for table: orderdetails"

