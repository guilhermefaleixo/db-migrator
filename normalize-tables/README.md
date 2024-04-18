# MySQL Upgrade Test

This will normalize tables, let's say in this example that now we want to normalize the table `customer` and `address` that are in the same table, so we want to move all the address data from `customer` to a new table address.
We can do this using `pt-archiver` and `pt-archiver` will help us to move the data from one table to another without downtime.

## Setup

1. Run the following command to create the Docker containers:

    ```bash
    docker-compose up -d
    ```

This command will create the Docker images required for the test.

2. Navigate to the `scripts` directory.

3. Run the following script to import tables:

    ```bash
    ./importTables.sh
    ```

This script will import tables and data from MySQL 5.7 to MySQL 8.0.

4. After running the script, you can check if everything was moved correctly.

## Why 