create database esca;
use esca;

describe cleaned_orders;

-- creating and loading data from csv file through import wizard
SELECT count(*) 
FROM cleaned_orders;
ALTER TABLE cleaned_orders RENAME TO orders;

SELECT count(*) 
FROM cleaned_customers;

CREATE TABLE cleaned_orderitems (
    order_id VARCHAR(40),
    product_id VARCHAR(40),
    seller_id VARCHAR(40),
    price FLOAT,
    shipping_charges FLOAT
);
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SHOW VARIABLES;
SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\cleaned_orderitems.csv'
INTO TABLE cleaned_orderitems
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE cleaned_ (
    order_id VARCHAR(40),
    product_id VARCHAR(40),
    seller_id VARCHAR(40),
    price FLOAT,
    shipping_charges FLOAT
);
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SHOW VARIABLES;
SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\cleaned_orderitems.csv'
INTO TABLE cleaned_orderitems
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE cleaned_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value FLOAT
);
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SHOW VARIABLES;
SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\cleaned_payments.csv'
INTO TABLE cleaned_orderitems
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT count(*) 
FROM cleaned_products;
