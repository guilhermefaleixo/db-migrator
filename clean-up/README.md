# MySQL Upgrade Test

This upgrade will show how to clean up tables of data that you no longer required. This is a good way to keep your database clean and fast.

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