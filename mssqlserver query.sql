select * from [dbo].[customers]
select * from [dbo].[employees]
select * from [dbo].[offices]
select * from [dbo].[orders]
select * from[dbo].[payments]
select * from[dbo].[productlines]
select * from[dbo].[products]
select * from[dbo].[warehouses]
select * from [dbo].[orderdetails]

use mintclassics


-----finding total number of customers------
select count(customerNumber) as customer_count from customers

-----------------------------------------country wise  customer  count data-------------------
select distinct(country) as uniquecountry,count(customerNumber)as cust_count from customers
group by country
order by cust_count desc
--------------------
--*** orders--- each year wise order count by extracting year from date 
select datepart(year,orderDate)as year_count,count(*) as total_count from orders
group by datepart(year,orderDate)
-------------------month wise order----------------
select datepart(MONTH,orderdate)as month_num,count(*) as total_count from orders
group by datepart(MONTH,orderdate)
order by total_count desc

----------------------------------------
-----****customer wise orde count****order table------
select count(orderNumber) total_Ordercount,customerNumber from orders
group by customerNumber
-------------------------
select  b.customerNumber,b.country, a.total_order
from customers b 
join
(select customerNumber ,count(ordernumber)as total_order from orders
group by customerNumber ) a
on a.customerNumber=b.customerNumber
--where a.total_order>=5
order by a.total_order desc

--------------------------------------------------
-----------------shipping status count*****----

select count(status) total_count,status,customerNumber from orders
group by customerNumber,status
order by total_count desc

select  count(status) status_count ,status from orders
group by status
-------------------------country wise shipping count and ware house count---------------
select a.country,count(b.orderNumber)as tottal_order,d.warehouseCode,count(b.status) as status_count,b.status
from customers as a
join orders as b
on a.customerNumber=b.customerNumber
join orderdetails as c
on c.orderNumber=b.orderNumber
join 
products as d
on d.productCode=c.productCode
group by a.country,d.warehouseCode,b.status
order by tottal_order desc ,a.country
-------------------------------------warehouse wise sales-----------------------
select sum(quantityInStock*buyPrice)as total_sales,warehouseCode from products
group by warehouseCode
order by total_sales desc
--------------------------------total sales of each products-----------
select sum(quantityInStock*buyPrice)as total_sales,warehouseCode,productline from products
group by warehouseCode,productline
order by total_sales desc
select * from products
-----------------------------
----------------Find top payament customers with country wise by joining the payment and customers table-------
select a.CustomerNumber,a.country,sum(b.amount) as  total_pamentsum
from customers as a
full join payments as b on a.customerNumber =b.customerNumber
group by a.CustomerNumber,a.country 
order by total_pamentsum desc

---product count of each warehouseCode
select count(productName) as product_count,warehouseCode from products
group by warehouseCode

select distinct productName,warehouseCode from products
-------------------------------------------------
------------------------------------------------finding total products count under each product line and  warehouse,sum of price -------------
select a.productLine,count(b.productName) as totl_productcount,sum(b.buyPrice) as price,
b.warehouseCode,c.warehouseName
from productlines as a
full join products as b
on a.productline=b.productLine 
full join warehouses as c
on c.warehouseCode=b.warehouseCode
group by a.productLine,b.warehouseCode,c.warehouseName
order by totl_productcount desc,b.warehouseCode desc
select a.productCode,count(c.productCode) as total_orders,a.productName,b.warehouseCode,b.warehouseName
from products as a
full join warehouses as b on a.warehouseCode=b.warehouseCode
full join orderdetails as c on c.productCode=a.productCode
group by a.productCode,b.warehouseCode,b.warehouseName,a.productName
----------------------------------------------------
-----------------------------finding products that not ordered---------
SELECT
    productCode,
    productName,
    warehouseCode,
	productName,
	warehouseCode
FROM
    products
WHERE
    productCode NOT IN (
        SELECT productCode
        FROM orderdetails
    );
-----------profit of each products---------
select a.productName,a.MSRP,a.buyPrice,a.warehouseCode,a.productLine,a.productVendor,b.priceEach,(((b.priceEach-a.buyPrice)/a.buyPrice)) as profit from products as a
full join orderdetails as b on a.productCode=b.productCode
order by profit  desc
-------------------------------------------selecting customer details who payed much---
select a.customerName,a.customerNumber,
a.country,b.max_payment
from customers a

join
(
select customerNumber,max(amount) as max_payment
from payments 
group by customerNumber
) b on a.customerNumber=b.customerNumber
order by max_payment desc

-------------------------------------------quantity ----------------
select sum(quantityInStock) as total_stockquantity,count(productName) total_prodcut,warehouseCode from products
group by warehouseCode
order by total_stockquantity desc
----------------------------------
select sum(b.quantityOrdered) as total_orderquantity,a.warehouseCode,count(a.productName) as total_product
from products as a
join orderdetails b
on a.productCode = b.productCode
group by a.warehouseCode
order by total_orderquantity desc
--select * from products
--select * from orderdetails

---------------most shipped product----
-----------which warehouse having higher order-----------
----------------------------
select * from products

select distinct(productLine) as product,warehouseCode from products
-------------------------------------------------------------
---------------------------2 nd question-----------------------------
select distinct(productLine) as product_name,sum(quantityInStock) as quantity,sum(quantityInStock*buyPrice)as total_sales,warehouseCode from products
group by productLine, warehouseCode
order by total_sales desc

--------------finding quantity in stock and how many product sold---------------
select * from [dbo].[orderdetails]
select * from products
select a. warehousecode,a.productName,a.productLine,sum(a.quantityInStock) as quantityinstock,sum(b.quantityOrdered) as totalorder
from products a
full join orderdetails as b
on a.productCode=b.productCode
group by a. warehousecode,a.productName,a.productLine
order by quantityinstock desc

select distinct(a.productLine),a.warehousecode,
sum(a.quantityInStock) as quantityinstock,
sum(b.quantityOrdered) as totalorder
from products a
left join orderdetails as b
on a.productCode=b.productCode
group by a.productName,a.warehousecode,a.productLine
order by quantityinstock desc
---------------------finding correlation between quantity of stock and order of product
SELECT 
    a.productLine,
    a.warehousecode,
    SUM(a.quantityInStock) AS quantityinstock,
    SUM(b.quantityOrdered) AS totalorder
FROM 
    (SELECT productLine,productCode, warehousecode, SUM(quantityInStock) AS quantityInStock
     FROM products
     GROUP BY productLine, warehousecode,productCode) a
LEFT JOIN 
    (SELECT productCode, SUM(quantityOrdered) AS quantityOrdered
     FROM orderdetails
     GROUP BY productCode) b
ON 
    a.productCode=b.productCode
GROUP BY 
    a.productLine, a.warehousecode
ORDER BY 
    quantityinstock DESC;


