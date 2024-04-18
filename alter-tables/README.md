# MySQL Upgrade Test

This upgrade test will change tables in a new server, in case of any alter table is needed, we will use `pt-archiver` to do this without downtime.

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