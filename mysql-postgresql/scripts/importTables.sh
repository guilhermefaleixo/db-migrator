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
    "orderdetails"
    "orders"
    "payments"
    "productlines"
    "products"
)

# Loop through each table and move data using pt-archiver to a file
for TABLE in "${TABLES[@]}"; do
    echo "Moving data for table: $TABLE"
    nohup pt-archiver --source h=$SOURCE_HOST,u=$SOURCE_USER,p=$SOURCE_PASSWORD,D=$SOURCE_DATABASE,t=$TABLE,P=3310,L=/tmp \
                --file '%D.%t.tsv' \
                --where "1=1" --statistics --header --progress=10000 --limit=1000 --no-delete --no-safe-auto-increment --why-quit --skip-foreign-key-checks > $TABLE.log &&
    echo "Data moved for table: $TABLE"
done

# Execute SQL script to create database and tables in PostgreSQL
psql -h $DEST_HOST -U $DEST_USER -d $DEST_DATABASE  -p 3309 -f createDatabase.sql &&
echo "Database created successfully"


# Get all the TSV files in the current directory
files=$(find . -maxdepth 1 -type f -name "*.tsv")

# Iterate through each TSV file
for file in $files; do
    echo "Processing file: $file"
    # Remove '\N' with 'NULL', carriage return characters with a space, and '\r\n' with a space
    sed -i '' -e 's/\\N/NULL/g' -e 's/\r/ /g' -e 's/\r\n/ /g' "$file"
    # Concatenate lines ending with backslash
    sed -i '' -e :a -e '/\\$/N; s/\\\n//; ta' "$file"
    # Escape double quotes
    sed -i '' 's/"/""/g' "$file"
    echo "Done processing file: $file"
done


# Define the order of files
ordered_files=(
    "classicmodels.productlines.tsv"
    "classicmodels.products.tsv"
    "classicmodels.offices.tsv"
    "classicmodels.employees.tsv"
    "classicmodels.customers.tsv"
    "classicmodels.payments.tsv"
    "classicmodels.orders.tsv"
    "classicmodels.orderdetails.tsv"
)

# Loop through files in the specified order
for file in "${ordered_files[@]}"; do
    # Check if file exists
    if [ -f "$file" ]; then
        # Extract table name from file name
        table_name=$(echo "$file" | cut -d '.' -f2)
        echo "Importing data from $file to $table_name"
        # Import data into PostgreSQL table
        psql -h $DEST_HOST -U $DEST_USER -d $DEST_DATABASE -p 3309 -c "COPY $table_name FROM '/tmp/scripts/$file' NULL 'NULL' DELIMITER E'\t' CSV HEADER;"
        # Check if import was successful
        if [ $? -eq 0 ]; then
            echo "Data imported from $file to $table_name"
        else
            echo "Error importing data from $file to $table_name"
        fi
    else
        echo "File $file not found."
    fi
done

