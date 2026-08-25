/* -- BUSINESS PROBLEM: How can the e-commerce company increase revenue and improve customer retention by understanding customer behavior, 
	  sales performance, product performance, order patterns, payment methods, and delivery performance? */
-- 1. How does revenue change over time, and which months generate the most revenue?
SELECT
    YEAR(o.order_purchase_timestamp) AS year,
    MONTH(o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price + oi.shipping_charges), 2) AS revenue
FROM cleaned_orders o
JOIN cleaned_orderitems oi
    ON o.order_id = oi.order_id
GROUP BY year, month
ORDER BY year, month;
    
/* RESULT -------------------------------------------------------------------------------------------------------------------------
Year Month  Revenue
2016	9	1370.83
2016	10	183487.5
2016	12	629.95
2017	1	478429
2017	2	937523.35
2017	3	1601541.04
2017	4	1421084.35
2017	5	2111148.32
2017	6	1825692.9
2017	7	2455008
2017	8	2541651.53
2017	9	2636476.92
2017	10	2779895.42
2017	11	4979654.38
2017	12	3353340.38
2018	1	4102562.62
2018	2	3966183.57
2018	3	4416404.16
2018	4	4134855.37
2018	5	4347370.17
2018	6	3499803.05
2018	7	3437735.52
2018	8	3451192.88
2018	9	302.5
------ Observation ---------------------------------------------------------------------------------------------------------------
Revenue shows a strong overall upward trend from 2016 to 2018, with significant growth throughout 2017. The highest revenue was 
recorded in November 2017 at 4.98M, likely due to seasonal shopping. Revenue remained high in 2018 but gradually declined after 
March. The unusually low revenue in September 2016 and September 2018 may indicate incomplete data for those months.
-----------------------------------------------------------------------------------------------------------------------------*/

-- 2. What is the average order value, and how does it change over time?
WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price + shipping_charges) AS order_revenue
    FROM cleaned_orderitems
    GROUP BY order_id
)

SELECT
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM order_revenue;

/* RESULT -------------------------------------------------------------------------------------------------------------------------
average_order_value
656.81
------ Observation ---------------------------------------------------------------------------------------------------------------
The average order value is 656.81, indicating that customers spend around 656.81 per order on average. This suggests a relatively 
strong customer spending level and provides a useful benchmark for tracking future changes in order value.
-----------------------------------------------------------------------------------------------------------------------------*/

-- 3. Who are the highest-value customers based on total spending?
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    ROUND(SUM(oi.price + oi.shipping_charges), 2) AS total_spending
FROM cleaned_customers c
JOIN cleaned_orders o
    ON c.customer_id = o.customer_id
JOIN cleaned_orderitems oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_city,
    c.customer_state
ORDER BY
    total_spending DESC
LIMIT 10;

/* RESULT -------------------------------------------------------------------------------------------------------------------------
Nz66V2TeAxAX	tijucas	SC	8147.42
bmv1Lg65SUWP	rio de janeiro	RJ	7507.68
oW2VygXvCSzO	salvador	BA	7435.24
r6BPYyzgP2BJ	curitiba	PR	7140.29
H1deBLRJV7r9	carapicuiba	SP	7051.42
ondvZDYSibyo	sao paulo	SP	6847.87
lwNS6AdlPkdm	osasco	SP	6806.3
hm4C4JCOdr7S	porto alegre	RS	6627.28
qLi1M2m38Plu	cerquilho	SP	6625.28
O7qYSrBnKKWr	sao paulo	SP	6625.28
------ Observation ---------------------------------------------------------------------------------------------------------------
The highest-value customer spent 8,147.42, while the top 10 customers spent between 6,625.28 and 8,147.42. Most of these high-value 
customers are from São Paulo and other major cities, indicating that urban customers contribute significantly to total spending.
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 4. What percentage of customers are repeat customers, and how much revenue do they generate?
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM cleaned_orders
    GROUP BY customer_id
)

SELECT
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;
/* RESULT -------------------------------------------------------------------------------------------------------------------------
repeat_customer_rate
0.00
------ Observation ---------------------------------------------------------------------------------------------------------------
The repeat customer rate is 0.00%, meaning no customers have placed more than one order in the dataset. This suggests that customer 
retention is very low, which may indicate an opportunity to improve customer loyalty and repeat purchases.
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 5. Which states and cities have the highest number of customers and revenue?
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.shipping_charges), 2) AS revenue
FROM cleaned_customers c
JOIN cleaned_orders o
    ON c.customer_id = o.customer_id
JOIN cleaned_orderitems oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

/* RESULT -------------------------------------------------------------------------------------------------------------------------
SP	37879	37879	24813291.05
RJ	11578	11578	7588920.75
MG	10334	10334	6765915.26
RS	4921	4921	3183325.17
PR	4523	4523	3102553
SC	3213	3213	2087499.95
BA	3088	3088	2013356.82
GO	1868	1868	1286384.11
ES	1798	1798	1148584
DF	1793	1793	1124891.19
PE	1493	1493	1032080.62
CE	1141	1141	781686.48
PA	817		817		566495.04
MT	848		848		548604.81
MA	623		623		415073.45
MS	637		637		402848.97
PB	497		497		331201.6
PI	423		423		259492.76
RN	381		381		252864.73
AL	342		342		208235.61
SE	305		305		199239.55
RO	241		241		177302.74
TO	247		247		170377.63
AM	140		140		95667.14
AP	68		68		43543.86
AC	75		75		37821.48
RR	43		43		26085.94
------ Observation ---------------------------------------------------------------------------------------------------------------
São Paulo (SP) has the highest number of customers and generates the most revenue, with 37,879 customers and 24.81M in revenue. 
Rio de Janeiro and Minas Gerais follow, showing that customers and revenue are highly concentrated in Brazil’s major states, 
especially in the Southeast region.
---------------------------------------------------------------------------------------------------------------------------------*/

-- 6. Which products generate the most revenue and sales volume?
SELECT
    p.product_id,
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS orders,
    SUM(oi.order_id) AS units_sold,
    ROUND(SUM(oi.price + oi.shipping_charges), 2) AS revenue
FROM cleaned_products p
JOIN cleaned_orderitems oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

/* RESULT -------------------------------------------------------------------------------------------------------------------------
9NwzO0Pm0fDM	toys	383	1031	813203.11
SLTlrWtcYt1m	toys	321	1162	580622.07
Biwi1BNtUB7l	toys	295	511	498161.69
ro08JPncYzLh	garden_tools	290	577	477766.14
ZWyg4uNWPHjJ	toys	110	249	323820.03
tPlw2QcQOvKf	garden_tools	91	136	157399.99
utVPLgd1LM3F	toys	77	111	148737
GvBzGCvvIC2D	toys	176	277	134078.87
5J7az1rwth4i	toys	110	841	122126.23
CY8OZ3lT9uqB	telephony	42	326	118762.22
------ Observation ---------------------------------------------------------------------------------------------------------------
The toys category dominates the top revenue-generating products, with several toy products appearing among the top 10. The 
highest-performing product generated 813K in revenue from 383 orders, showing strong demand and sales volume. Garden tools and 
telephony also contribute significantly, but toys are the clear leading category.
----------------------------------------------------------------------------------------------------------------------------------*/

-- 7. Which product categories generate the most revenue?
SELECT
    p.product_category_name,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price + oi.shipping_charges), 2) AS revenue
FROM cleaned_products p
JOIN cleaned_orderitems oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

/* RESULT -------------------------------------------------------------------------------------------------------------------------
product_category_name  units_sold  revenue
toys	67012	25965415.31
furniture_decor	1760	832070.19
garden_tools	807	780355.12
bed_bath_table	2146	699715.68
health_beauty	2351	697498.49
watches_gifts	1196	636302.58
sports_leisure	1837	626172.99
telephony	912	530039.29
computers_accessories	1715	504251.35
housewares	1340	474102.13
auto	829	269536.28
cool_stuff	718	212691.02
baby	621	209814.71
perfumery	671	189685.61
office_furniture	533	183845.81
stationery	462	176632.54
fashion_bags_accessories	408	163479.42
pet_shop	394	129944.56
electronics	547	119362.85
Unknown	308	99834.24
construction_tools_construction	192	76566.76
luggage_accessories	178	73287.63
musical_instruments	150	58124.19
home_appliances	215	56709.66
consoles_games	156	46793.71
small_appliances	117	37068.18
home_construction	131	34676.99
food_drink	65	30909.64
books_general_interest	82	30604.93
costruction_tools_garden	82	27795.72
audio	107	26815.86
construction_tools_lights	51	25870.34
air_conditioning	77	25835.1
agro_industry_and_commerce	67	25160.57
fashion_shoes	61	25015.79
market_place	84	23147.17
furniture_living_room	82	22612.82
tablets_printing_image	64	22368.68
home_appliances_2	72	18919.26
books_technical	80	18321.56
home_confort	40	16880.3
fixed_telephony	47	16237.78
signaling_and_security	48	14812.76
food	59	14181.47
drinks	50	14126.12
kitchen_dining_laundry_garden_furniture	52	13344.16
computers	53	11978.73
costruction_tools_tools	32	10774.37
industry_commerce_and_business	48	9498.68
fashion_underwear_beach	16	7945.66
christmas_supplies	27	6770.43
fashion_male_clothing	21	6173.82
construction_tools_safety	24	5991.24
furniture_bedroom	16	5546.23
la_cuisine	4	5354.04
art	13	4426.6
dvds_blu_ray	10	2810.75
arts_and_craftmanship	4	2428.39
books_imported	12	2290.77
party_supplies	7	1628.82
music	7	1399.79
small_appliances_home_oven_and_coffee	9	1319.69
cine_photo	5	1056.53
home_comfort_2	1	743.96
fashion_childrens_clothes	2	720.2
fashion_sport	3	618.51
flowers	6	459.14
fashio_female_clothing	2	156.95
diapers_and_hygiene	1	126.46
furniture_mattress_and_upholstery	1	93.98
security_and_services	1	52.21
------ Observation ---------------------------------------------------------------------------------------------------------------
The toys category is the clear revenue leader, generating 25.97M from 67,012 units sold, far exceeding all other categories. 
Furniture décor and garden tools follow but contribute significantly less, showing that toys are the main driver of category-level 
revenue.
----------------------------------------------------------------------------------------------------------------------------------*/

-- 8. Which customers place the most orders?
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count
FROM cleaned_customers c
JOIN cleaned_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_city, c.customer_state
ORDER BY order_count DESC
LIMIT 10;
/* RESULT -------------------------------------------------------------------------------------------------------------------------
yZxp4LnOBCE6	sao paulo	            SP	1
YZxSl4nUGdoQ	araxa	                MG	1
yZYBouywXx0U	sao joao da boa vista	SP	1
YZYF1ncUI2vH	osasco	                SP	1
YzYfjzvsOYRa	janauba	                MG	1
YzyGtTKuzvpL	parauapebas	            PA	1
yzyjAbeIHLkQ	colombo	                PR	1
YZYovK2pRAKh	sao luis	            MA	1
YzYZ0oDRR3z9	duque de caxias	        RJ	1
yZZI4kZbsO4I	jundiai	                SP	1
------ Observation ---------------------------------------------------------------------------------------------------------------
The results show that the highest-order customers placed only one order each, indicating that customers generally do not make repeat 
purchases. This supports the earlier finding of a 0% repeat customer rate and highlights a potential customer retention issue.
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 9. How well does the company meet its estimated delivery dates?
SELECT
    COUNT(*) AS delivered_orders,
    SUM(
        CASE
            WHEN order_delivered_timestamp <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,
    ROUND(
        SUM(
            CASE
                WHEN order_delivered_timestamp <= order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_rate
FROM cleaned_orders
WHERE order_delivered_timestamp IS NOT NULL;
/* RESULT -------------------------------------------------------------------------------------------------------------------------
delivered_orders   on_time_orders   on_time_delivery_rate
89316	              82578	              92.46
------ Observation ---------------------------------------------------------------------------------------------------------------
The company has a strong 92.46% on-time delivery rate, with 82,578 out of 89,316 delivered orders arriving by the estimated date. 
This indicates that the company generally meets customer delivery expectations, although there is still room to improve the 
remaining 7.54% of late deliveries.
----------------------------------------------------------------------------------------------------------------------------------*/

