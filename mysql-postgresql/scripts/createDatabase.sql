-- Create the database if not exists
DO $$BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'classicmodels') THEN
CREATE DATABASE classicmodels;
END IF;
END$$;


-- Connect to the classicmodels database
\c classicmodels

-- Drop existing tables if they exist
DROP TABLE IF EXISTS orderdetails;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS offices;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS productlines;

-- Create the tables
CREATE TABLE IF NOT EXISTS productlines (
                                            productLine varchar(50) PRIMARY KEY,
                                            textDescription varchar(4000),
                                            htmlDescription text,
                                            image bytea
);

CREATE TABLE IF NOT EXISTS products (
                                        productCode varchar(15) PRIMARY KEY,
                                        productName varchar(70) NOT NULL,
                                        productLine varchar(50) NOT NULL,
                                        productScale varchar(10) NOT NULL,
                                        productVendor varchar(50) NOT NULL,
                                        productDescription text NOT NULL,
                                        quantityInStock smallint NOT NULL,
                                        buyPrice decimal(10,2) NOT NULL,
                                        MSRP decimal(10,2) NOT NULL,
                                        FOREIGN KEY (productLine) REFERENCES productlines (productLine)
);

CREATE TABLE IF NOT EXISTS offices (
                                       officeCode varchar(10) PRIMARY KEY,
                                       city varchar(50) NOT NULL,
                                       phone varchar(50) NOT NULL,
                                       addressLine1 varchar(50) NOT NULL,
                                       addressLine2 varchar(50),
                                       state varchar(50),
                                       country varchar(50) NOT NULL,
                                       postalCode varchar(15) NOT NULL,
                                       territory varchar(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS employees (
                                         employeeNumber int PRIMARY KEY,
                                         lastName varchar(50) NOT NULL,
                                         firstName varchar(50) NOT NULL,
                                         extension varchar(10) NOT NULL,
                                         email varchar(100) NOT NULL,
                                         officeCode varchar(10) NOT NULL,
                                         reportsTo int,
                                         jobTitle varchar(50) NOT NULL,
                                         FOREIGN KEY (reportsTo) REFERENCES employees (employeeNumber),
                                         FOREIGN KEY (officeCode) REFERENCES offices (officeCode)
);

CREATE TABLE IF NOT EXISTS customers (
                                         customerNumber int PRIMARY KEY,
                                         customerName varchar(50) NOT NULL,
                                         contactLastName varchar(50) NOT NULL,
                                         contactFirstName varchar(50) NOT NULL,
                                         phone varchar(50) NOT NULL,
                                         addressLine1 varchar(50) NOT NULL,
                                         addressLine2 varchar(50),
                                         city varchar(50) NOT NULL,
                                         state varchar(50),
                                         postalCode varchar(15),
                                         country varchar(50) NOT NULL,
                                         salesRepEmployeeNumber int,
                                         creditLimit decimal(10,2),
                                         FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees (employeeNumber)
);

CREATE TABLE IF NOT EXISTS payments (
                                        customerNumber int NOT NULL,
                                        checkNumber varchar(50) NOT NULL,
                                        paymentDate date NOT NULL,
                                        amount decimal(10,2) NOT NULL,
                                        PRIMARY KEY (customerNumber, checkNumber),
                                        FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)
);

CREATE TABLE IF NOT EXISTS orders (
                                      orderNumber int PRIMARY KEY,
                                      orderDate date NOT NULL,
                                      requiredDate date NOT NULL,
                                      shippedDate date,
                                      status varchar(15) NOT NULL,
                                      comments text,
                                      customerNumber int NOT NULL,
                                      FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)
);

CREATE TABLE IF NOT EXISTS orderdetails (
                                            orderNumber int NOT NULL,
                                            productCode varchar(15) NOT NULL,
                                            quantityOrdered int NOT NULL,
                                            priceEach decimal(10,2) NOT NULL,
                                            orderLineNumber smallint NOT NULL,
                                            PRIMARY KEY (orderNumber, productCode),
                                            FOREIGN KEY (orderNumber) REFERENCES orders (orderNumber),
                                            FOREIGN KEY (productCode) REFERENCES products (productCode)
);
