/**
 Author: Mrin
 Model : NorthWind

postgres=# \dt northwind.*
No matching relations found.
postgres=# \d+ northwind.user
Did not find any relation named "northwind.user".
postgres=# \dt northwind.*
No matching relations found.
postgres=# \dt northwind.*

**/

/*DROP TABLE IF EXISTS northwind.user;
DROP TABLE IF EXISTS northwind.customers CASCADE;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;*/

DROP SCHEMA IF EXISTS northwind CASCADE;
 
CREATE SCHEMA northwind;


/* Table: user (Application Users) */
CREATE TABLE northwind.user (
    user_id     VARCHAR(20) NOT NULL,
    password    VARCHAR(20) NOT NULL,
    first_name  VARCHAR(50) ,
    last_name   VARCHAR(50) ,
    email       VARCHAR(70) ,
    security_provider_id INT ,
    default_customer_id  INT ,
    company     VARCHAR(50) ,
    phone       VARCHAR(20) ,
    address1    VARCHAR(100),
    address2    VARCHAR(100),
    country     VARCHAR(20) ,
    postal      VARCHAR(20) ,
    role        VARCHAR(20) ,
    other_roles VARCHAR(80) ,
    is_active   BOOL  ,
    is_blocked  BOOL  ,
    secret_question     VARCHAR(100),
    secret_answer       VARCHAR(100),
    enable_beta_testing BOOL,
    enable_renewal      BOOL,
    CONSTRAINT user_id PRIMARY KEY(user_id)
);

/* Table: customers */
CREATE TABLE northwind.customers (
  id              INT NOT NULL,
  last_name       VARCHAR(50) ,
  first_name      VARCHAR(50) ,
  email           VARCHAR(50) ,
  company         VARCHAR(50) ,
  phone           VARCHAR(25) ,
  address1        VARCHAR(150),
  address2        VARCHAR(150),
  city            VARCHAR(50) ,
  state           VARCHAR(50) ,
  postal_code     VARCHAR(15) ,
  country         VARCHAR(50) ,
  PRIMARY KEY (id)
);

/* Table: employees */
CREATE TABLE northwind.employees (
  id              INT NOT NULL,
  last_name       VARCHAR(50) ,
  first_name      VARCHAR(50) ,
  email           VARCHAR(50) ,
  avatar          VARCHAR(250) ,
  job_title       VARCHAR(50) ,
  department      VARCHAR(50) ,
  manager_id      INT ,
  phone           VARCHAR(25) ,
  address1        VARCHAR(150),
  address2        VARCHAR(150),
  city            VARCHAR(50) ,
  state           VARCHAR(50) ,
  postal_code     VARCHAR(15) ,
  country         VARCHAR(50) ,
  PRIMARY KEY (id)
);

/* Table: orders */
CREATE TABLE northwind.orders (
  id              INT NOT NULL,
  employee_id     INT ,
  customer_id     INT ,
  order_date      TIMESTAMP ,
  shipped_date    TIMESTAMP ,
  ship_name       VARCHAR(50) ,
  ship_address1   VARCHAR(150) ,
  ship_address2   VARCHAR(150) ,
  ship_city       VARCHAR(50) ,
  ship_state      VARCHAR(50) ,
  ship_postal_code VARCHAR(50) ,
  ship_country    VARCHAR(50) ,
  shipping_fee    DECIMAL(19,4) NULL DEFAULT '0.0000',
  payment_type    VARCHAR(50) ,
  paid_date       TIMESTAMP ,
  order_status    VARCHAR(25),
  PRIMARY KEY (id)
);

/* Table: order_details */
CREATE TABLE northwind.order_items (
  order_id            INT NOT NULL,
  product_id          INT ,
  quantity            DECIMAL(18,4) NOT NULL DEFAULT '0.0000',
  unit_price          DECIMAL(19,4) NULL DEFAULT '0.0000',
  discount            DECIMAL(19,4) NULL DEFAULT '0.0000',
  order_item_status   VARCHAR(25),
  date_allocated      TIMESTAMP ,
  PRIMARY KEY (order_id, product_id)
);

/* Table: products */
CREATE TABLE northwind.products (
  id              INT NOT NULL,
  product_code    VARCHAR(25) ,
  product_name    VARCHAR(50) ,
  description     VARCHAR(250),
  standard_cost   DECIMAL(19,4) NULL DEFAULT '0.0000',
  list_price      DECIMAL(19,4) NOT NULL DEFAULT '0.0000',
  target_level    INT ,
  reorder_level   INT ,
  minimum_reorder_quantity INT ,
  quantity_per_unit VARCHAR(50) ,
  discontinued    BOOL NOT NULL DEFAULT '0',
  category        VARCHAR(50),
  PRIMARY KEY (id)
);


/* Foreign Key: orders */
ALTER TABLE northwind.orders ADD CONSTRAINT fk_orders__customers FOREIGN KEY (customer_id) REFERENCES northwind.customers(id);
ALTER TABLE northwind.orders ADD CONSTRAINT fk_orders__employees FOREIGN KEY (employee_id) REFERENCES northwind.employees(id);
/* Foreign Key:  order_items */
ALTER TABLE northwind.order_items ADD CONSTRAINT fk_order_items__orders      FOREIGN KEY (order_id) REFERENCES northwind.orders(id);
ALTER TABLE northwind.order_items ADD CONSTRAINT fk_order_items__products    FOREIGN KEY (product_id) REFERENCES northwind.products(id);

/* Views */
CREATE OR REPLACE VIEW northwind.order_info AS
select o.id as order_id
 , o.order_date
 , o.order_status
 , o.paid_date
 , o.payment_type
 , o.shipped_date
 , o.shipping_fee
 , o.ship_name
 , o.ship_address1
 , o.ship_address2
 , o.ship_city
 , o.ship_state
 , o.ship_postal_code
 , o.ship_country
 , o.customer_id
 , o.employee_id
 , concat(c.first_name, ' ', c.last_name) as customer_name
 , c.phone customer_phone
 , c.email customer_email
 , c.company as customer_company
 , concat(e.first_name, ' ', e.last_name) as employee_name
 , e.department employee_department
 , e.job_title  employee_job_title
  From   northwind.orders o
       , northwind.employees e
       , northwind.customers c
 where o.employee_id  = e.id
   and o.customer_id  = c.id;

CREATE OR REPLACE VIEW northwind.order_details AS
select oi.order_id
  , oi.product_id
  , oi.quantity
  , oi.unit_price
  , oi.discount
  , oi.date_allocated
  , oi.order_item_status
  , o.order_date
  , o.order_status
  , o.paid_date
  , o.payment_type
  , o.shipped_date
  , o.shipping_fee
  , o.ship_name
  , o.ship_address1
  , o.ship_address2
  , o.ship_city
  , o.ship_state
  , o.ship_postal_code
  , o.ship_country
  , p.product_code
  , p.product_name
  , p.category
  , p.description
  , p.list_price
  , o.customer_id
  , concat(c.first_name, ' ', c.last_name)  as customer_name
  , c.phone   as customer_phone
  , c.email   as customer_email
  , c.company as customer_company
  , o.employee_id
  , concat(e.first_name, ' ', e.last_name) as employee_name
  , e.department as employee_department
  , e.job_title  as employee_job_title
  From   northwind.orders o
       , northwind.products p
       , northwind.order_items oi
       , northwind.employees e
       , northwind.customers c
 where oi.order_id    = o.id
   and oi.product_id  = p.id
   and o.employee_id  = e.id
   and o.customer_id  = c.id;

CREATE OR REPLACE VIEW northwind.customer_orders AS
select o.order_date, o.order_status, o.paid_date, o.payment_type, o.shipping_fee, o.customer_id
       , c.first_name customer_first_name, c.last_name  customer_last_name, c.phone customer_phone, c.email customer_email, c.company
  from northwind.orders o,northwind.customers c
 where o.customer_id  = c.id;

CREATE OR REPLACE VIEW northwind.employee_orders AS
select o.order_date, o.order_status, o.paid_date, o.payment_type, o.shipping_fee, o.employee_id
       , e.first_name employee_first_name, e.last_name  employee_last_name,  e.email employee_email, e.department
  from northwind.orders o,northwind.employees e
 where o.customer_id  = e.id;
