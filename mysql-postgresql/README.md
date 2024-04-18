# MySQL Upgrade Test

This upgrade test will move data from MySQL 5.6 to PostgreSQL.
This is a bit different as it will first create the files and then import them into PostgreSQL.

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

This script will import tables and data from MySQL 5.7 to PostgreSQL.

4. After running the script, you can check if everything was moved correctly.

## Why 