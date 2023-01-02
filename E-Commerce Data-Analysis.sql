 
 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- **E-COMMERCE DATA ANALYSIS** --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **   --   **  -- 
                                                           
-- The Data is of an Online retailer which has just launched its first product. 

-- For this Project, I am going to analyze and optimize marketing channels. And going to measure and test the website conversion performance,
-- /n And use data to understand the impact when the company launches a new product. I will be making an recommendations to steer the online
-- /n retailer business, and see how the business evolves based on the analyses.

 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  -- OVERVIEW OF THE E-COMMERCE DATABASE -- --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
                                                           
-- I will be working with the Six related tables, which containd E-Commerce data about:
-- *Website Activity
-- *Products
-- *Orders and Refunds, will try to understand how customers access and interact with the site, analyze landing page performance and conversion, and explore product-level sales. 

-- Following are the TABLES in the database.
-- *website_sessions
-- *website_pageviews
-- *orders
-- *order_item_refunds
-- *order_items
-- *products                                                           
 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- -- TABLES AND COLUMNS ASSOCIATED WITH IT --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
-- website_sessions             website_pageviews                    orders                          order_items                    order_item_refunds                  products
-- * website_session_id BIGINT  -- * website_pageview_id BIGINT      -- * order_id BIGINT            -- * order_item_id BIGINT      -- * order_item_refund_id BIGINT    -- * product_id INT
-- * created_at DATETIME        -- * created_at DATETIME             -- * created_at DATETIME        -- * created_at DATETIME       -- * created_at DATETIME            -- * created_at DATETIME
-- * user_id BIGINT             -- * website_session_id BIGINT       -- * website_session_id BIGINT  -- * order_id BIGINT           -- * order_item_id BIGINT           -- * product_name VARCHAR(45)
-- * is_repeat_session BINARY   -- * pageview_url VARCHAR(45)        -- * user_id BIGINT             -- * product_id INT            -- * order_id BIGINT              
-- * utm_source VARCHAR(45)                                          -- * primary_product_id INT     -- * is_primary_item BINARY    -- * refund_amount_usd DECIMAL(6,2)
-- * utm_campaign VARCHAR(45)                                        -- * items_purchased INT        -- * price_usd DECIMAL (6,2)
-- * utm_content VARCHAR(45)                                         -- * price_usd DECIMAL (6,2)    -- * cogs_usd DECIMAL (6,2)
-- * device_type VARCHAR(45)                                         -- * cogs_usd DECIMAL (6,2)    
-- * http_referer VARCHAR(45) 

-- Orders tables is where will find the purchases that customers are placing and we've order_id value associated, created_at columns means when order was occured, website_session_id is associated
-- /n with website_session table.
-- /n Within Orders we have order_items tables from this tables we get to know that which particular customers purchased multiple items. we can join order_items to product tables with the help of
-- /n product_id columns to know the name of the products. Also, we have a order_item_refunds, when customers complains and company issued a refund, so we can track those orders and also the 
-- /n unsatisfy customers. we can join order_item_refund table to the orders tables on order_id columns to know the count of the most refunded products. Then we also have a website_session table 
-- /n with the help of this table we can understand from where our traffic is coming from and which of those traffic sources are helping us generate orders. Every sessions when a customers comes in 
-- /n and visits website has an session_id associated with it. In this table, we have an utm parameter which our associated with our paid trafiic and that paid traffic is tagged with tracking parameters
-- /n that are then sorted in the database so that we can measure the traffic coming in on those paid campaigns and measure their effectiveness. 

																	 -- LET'S START -- 
                                                                        
 --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- -- TRAFFIC ANALYSIS AND OPTIMIZATION --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
 -- Traffic source analysis is about understanding where your customers are coming from and which channels are driving the higest quality traffic.  
 -- 1. We use the utm parameters stored in the database to identify paid website sessions
 -- 2. From our session data, we can link to our order data to understand how much revenue our paid campaingns are driving.
 
 
SELECT 
    ws.utm_content,
    COUNT(DISTINCT ws.website_session_id) AS session,
    COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_order_conv_rt
FROM
    website_sessions AS ws
        LEFT JOIN
    orders AS od ON ws.website_session_id = od.website_session_id
WHERE
    ws.website_session_id BETWEEN 1000 AND 2000 -- arbitrary
GROUP BY 1
ORDER BY 2 DESC;
-- *Insights: Most of the orders are from g_ad_1 (Google Ad 1, utm_source)    


-- 1. Understanding from where the bulk of website session are coming from, breaking down by UTM Source, Campaign and referring domain, using data where created_at is less then '2012-04-12'
SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY 1 , 2 , 3
ORDER BY 4 DESC;
-- *Insights: gsearch nonbrand is resulting into 3612 number of sessions. which make it a most important things for us. 


 -- 2. Gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales. Calculating the conversion rates (CVR) from session to order? Limiting the data before 14th April 2012.
SELECT 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_conv_rate
FROM
    website_sessions AS ws
        LEFT JOIN
    orders AS od ON ws.website_session_id = od.website_session_id
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND ws.created_at < '2012-04-14';
 -- *Insights: When we're limiting the data to 14th April 2012 and gsearch nonbrand is able to get 112 orders over 3895 sessions and conversion rate is 2.8% and that CVR is low


 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- -- BID OPTIMIZATION -- --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  
                                                         
-- Analysing for bid optimization is about understanding the value of various segments of paid trafiic, so that we can optimize our marketing budget. 


-- 3. Based on Conversion Rate Analysis, Pulling out gesearch nonbrand trended session volume, by week, to see the changes. Limiting the data before May 10th 2012.
SELECT MIN(DATE(created_at)) AS week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
    FROM website_sessions
    WHERE created_at < '2012-05-10' 
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at);
 -- *Insights: We can see that their is an Impact on Volume of website sessions, their is a sudden downward trend of sessions in the April month.


 -- 4. Some of the times it's happens that the conversion rate would not be similar across the two campaigns and if it's true the business should not be bidding the same for the traffic. 
 -- /n So, will pulling out the conversion rates from session to order split by device type so we can more appropriately set bids at the device type level. Limiting the data before May 11th 2012.
SELECT 
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_order_conv_rate
FROM
    website_sessions AS ws
        LEFT JOIN
    orders AS od ON ws.website_session_id = od.website_session_id
WHERE
    ws.created_at < '2012-05-11'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
GROUP BY device_type;
-- *Insights: Conversion rate for the device type Desktop is 3.7% which is more than mobile which account for only 0.9% of conversion. 
-- /n And from the Desktop device type we're getting 146 orders out of 3911 sessions, whereas on mobile we're getting 24 orders out of 2492 sessions.
-- /n So, we should not be running the same bids for desktop and mobile traffic. We need to increase bids for the desktop specific traffic because it perform much better.


-- 5. After our device-level analysis of conversion rates, So I am analyzing gsearch nonbrand desktop campaigns to see wheather there was any bid changes in between.
-- /n Pulling put weekly trends for both desktop and mobile to see the impact on volume. Limiting the data before June 9th 2012.
SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS dtop_session,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mob_session
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at) , WEEK(created_at);
-- *Insights: We can clearly see that there was a suddden upward trend in the desktop session on '2012-05-20' (661), So there was a big changes made for the desktop device type.
-- /n Whereas we can see a downward weekly trend in the mobile device-type sessions, It's means that they are decreasing the bid on mobile.

 
 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- -- ANALYZING TOP WEBSITE CONTENT --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
-- Now, I will be diving deeper into the E-Commerce website to understand where customers are landing on the website and how they make their way through the conversion funnel on the path to placing an order.
-- Website content analysis is about understanding which pages are seen the most by our users, to identify where to focus on improving our business.


-- 6. Pulling out the most-viewed website-pages, ranked by session volume? Limiting the data to June 9th 2012
SELECT 
	pageview_url,
	COUNT(distinct website_pageview_id) AS sessions 
FROM 
	website_pageviews
WHERE
	created_at < '2012-06-09'
GROUP BY
	1
ORDER BY
	2 DESC;
 -- *Insights: So as per the June 9th 2012, we can see that home page gets the most counts of page viewed 10403, followed by products page and the-original-mr-fuzzy page 4239 and 3037.
 
 
 -- 7. I want to see where our users are hitting the site, pulling out a list of the top entry pages? and ranking them on entry volume. Limiting the data before June 12th 2012.
 CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
    website_session_id, MIN(website_pageview_id) AS first_pv
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
    wpv.pageview_url AS landing_page,
    COUNT(DISTINCT fpv.website_session_id) AS session_hitting_page
FROM
    first_pv_per_session AS fpv
        LEFT JOIN
    website_pageviews AS wpv ON fpv.first_pv = wpv.website_session_id
GROUP BY wpv.pageview_url
ORDER BY 2 DESC;
-- *Insights: As per the June 12th 2012, Most of the users hitting home page (7744), followed by Products page (4808) and the-original-mr-fuzzy page (3455). A key takeaways is we can improve the the home page experience for our users,
-- /n also think about the other pages how we can improve those for our customers.


-- 8. Limiting the data before June 14th 2012, Performing the Bounce Rate Analysis, As we know that all of our traffic is landing on the homepage and we need to check how's that landing page is performing. Focusing on Sessions, Bounced Sessions and % of Sessions with Bounced.
CREATE TEMPORARY TABLE first_table
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_count
FROM
    website_pageviews
        INNER JOIN
    website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at < '2012-06-14'
GROUP BY 1;

CREATE TEMPORARY TABLE second_table
SELECT 
    first_table.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_table
        LEFT JOIN
    website_pageviews ON first_table.website_session_id = website_pageviews.website_session_id
        AND website_pageviews.pageview_url = '/home';

CREATE TEMPORARY TABLE third_table
SELECT 
    second_table.website_session_id,
    second_table.landing_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM
    second_table
        LEFT JOIN
    website_pageviews ON second_table.website_session_id = website_pageviews.website_session_id
GROUP BY 1 , 2
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;


SELECT 
    COUNT(DISTINCT second_table.website_session_id) AS sessions,
    COUNT(DISTINCT third_table.website_session_id) AS bounched_session,
    COUNT(DISTINCT third_table.website_session_id) / COUNT(DISTINCT second_table.website_session_id) * 100 AS bounce_rate
FROM
    second_table
        LEFT JOIN
    third_table ON second_table.website_session_id = third_table.website_session_id;
-- *Insights: As per the June 14th, On the Home page the total count of session is 11044 and out of which 6536 is of Bounced sessions, that is 59.17%.
 
 
-- 9. As I have done the Bounced Rate Analysis of the home page. Now, I am doing 50/50 test against the home page (/home) and landing page (/lander-1) for our gsearch nonbrand traffic. Pulling out the Bounced rate for these two pages and evaluate the best out. Limiting the data before July 28th 2012.
 
 -- finding the first instance of /lander-1 to set analysis timeframe.
SELECT 
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
        AND created_at IS NOT NULL;
 -- /lander-1 first_created_at is 2012-06-19 and first_pageview_id is 23504. Using this data for further analysis. 
 
 CREATE TEMPORARY TABLE first_tables
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_count
FROM
    website_sessions
        INNER JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;

CREATE TEMPORARY TABLE second_tables
SELECT 
    first_tables.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_tables
        LEFT JOIN
    website_pageviews ON first_tables.website_session_id = website_pageviews.website_session_id
        AND website_pageviews.pageview_url IN ('/home' , '/lander-1');

CREATE TEMPORARY TABLE third_tables
SELECT 
    second_tables.website_session_id,
    second_tables.landing_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM
    second_tables
        LEFT JOIN
    website_pageviews ON second_tables.website_session_id = website_pageviews.website_session_id
GROUP BY 1 , 2
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;

SELECT 
    second_tables.landing_page,
    COUNT(DISTINCT second_tables.website_session_id) AS total_sessions,
    COUNT(DISTINCT third_tables.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT third_tables.website_session_id) / COUNT(DISTINCT second_tables.website_session_id) * 100 AS Bounce_rate
FROM
    second_tables
        LEFT JOIN
    third_tables ON second_tables.website_session_id = third_tables.website_session_id
GROUP BY 1;
-- *Insights: As per the 28th July Gsearch Nonbrand, For the landing page /home and /lander-1 the count of sessions is 2260 and 2313 respectively out of which is the bounced session is 1319 and 1231 that is 58.33% and 53.23%. 
-- /n So, it dose look like there was an improvement in term of performance, we're having the fewer customer bounce on the custom lander page.


-- 10. As more sessions on /lander-1 page, pulling out the paid search nonbrand traffic landing on /home and /lander-1 page trended weekly since June 1st. And also analysing the bounce rate. Limiting the data to 31st August 2012. 

-- Solution is a multi-Step query

-- STEP 1: Finding the first website_pageview_id for relevant sessions
-- STEP 2: Identifying the landing page of each sessions
-- STEP 3: Counting pageviews for each session, to identify "bounces"
-- STEP 4: Summarizing by week ( bounce rate, sessions to each lander)

CREATE TEMPORARY TABLE first_table
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_count,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;

CREATE TEMPORARY TABLE second_table
SELECT 
    first_table.website_session_id,
    first_table.min_pv_count,
    first_table.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM
    first_table
        LEFT JOIN
    website_pageviews ON first_table.website_session_id = website_pageviews.website_session_id;

SELECT 
-- YEARWEEK(session_created_at) AS year_week,
MIN(DATE(session_created_at)) AS week_start_date,
-- COUNT(DISTINCT website_session_id) AS total_sessions,
-- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0 /COUNT(DISTINCT website_session_id) AS bounced_rate,
COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM
    second_table
GROUP BY yearweek(session_created_at);
-- *Insights: Starting of the June month, we can see the bounce rate range in 58% to 61%. And then over time, as it's switched over to trffic primarily going to the Lander page, we're seeing bounce rate closer to the 50% range.
-- /n So it is a remarkable improvement from 60 % down to 50%.


-- 11. Building up the full conversion Funnels and analyzing how many customers make it to each step. Starting with the /lander-1 page all the way to our thank-you page. Using data since August 5th and Limiting data before September 5th 2012.
SELECT 
    ws.website_session_id,
    wp.pageview_url,
    ws.created_at,
    CASE
        WHEN pageview_url = '/lander-1' THEN 1
        ELSE 0
    END AS lander_page,
    CASE
        WHEN pageview_url = '/products' THEN 1
        ELSE 0
    END AS product_page,
    CASE
        WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
        ELSE 0
    END AS mr_fuzzy_page,
    CASE
        WHEN pageview_url = '/cart' THEN 1
        ELSE 0
    END AS cart_page,
    CASE
        WHEN pageview_url = '/shipping' THEN 1
        ELSE 0
    END AS shipping_page,
    CASE
        WHEN pageview_url = '/billing' THEN 1
        ELSE 0
    END AS billing_page,
    CASE
        WHEN pageview_url = '/thank-you-for-your-order' THEN 1
        ELSE 0
    END AS thanku_page
FROM
    website_sessions AS ws
        LEFT JOIN
    website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
WHERE
    wp.pageview_url IN ('/lander-1' , '/products',
        '/the-original-mr-fuzzy',
        '/cart',
        '/shipping',
        '/billing',
        '/thank-you-for-your-order')
        AND ws.created_at > '2012-08-05'
        AND ws.created_at < '2012-09-05'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
ORDER BY 1 , 3;

CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT 
    website_session_id,
    MAX(lander_page) AS lander_made_it,
    MAX(product_page) AS product_made_it,
    MAX(mr_fuzzy_page) AS mr_fuzzy_page_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thanku_page) AS thanku_made_it
FROM
    (SELECT 
        ws.website_session_id,
            wp.pageview_url,
            ws.created_at,
            CASE
                WHEN pageview_url = '/lander-1' THEN 1
                ELSE 0
            END AS lander_page,
            CASE
                WHEN pageview_url = '/products' THEN 1
                ELSE 0
            END AS product_page,
            CASE
                WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
                ELSE 0
            END AS mr_fuzzy_page,
            CASE
                WHEN pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN pageview_url = '/billing' THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thanku_page
    FROM
        website_sessions AS ws
    LEFT JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
    WHERE
        wp.pageview_url IN ('/lander-1' , '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
            AND ws.created_at > '2012-08-05'
            AND ws.created_at < '2012-09-05'
            AND ws.utm_source = 'gsearch'
            AND ws.utm_campaign = 'nonbrand'
    ORDER BY 1 , 3) AS pageview
GROUP BY 1;

-- Final Output-1
SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    -- COUNT(DISTINCT CASE
            -- WHEN lander_made_it = 1 THEN website_session_id
            -- ELSE NULL
        -- END) AS to_lander,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_product,
    COUNT(DISTINCT CASE
            WHEN mr_fuzzy_page_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_shipping,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_billing,
    COUNT(DISTINCT CASE
            WHEN thanku_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_thanku
FROM
    session_level_made_it_flags;
    
-- Final output-2
SELECT 
    -- COUNT(DISTINCT website_session_id) AS sessions,

    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS lander_click_rate,
    COUNT(DISTINCT CASE
            WHEN mr_fuzzy_page_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) * 100 AS product_click_rt,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN mr_fuzzy_page_made_it = 1 THEN website_session_id
            ELSE NULL
        END) * 100 AS Mrfuzzy_click_rate,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) * 100 AS cart_click_rate,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) * 100 AS shipping_click_rate,
    COUNT(DISTINCT CASE
            WHEN thanku_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) * 100 AS billing_click_rate
FROM
    session_level_made_it_flags;
-- *Insights: Basically what we're getting now is in the aggregate, how many of these total sessions made it to each of the product, and then we convert those into rates.
-- /n we are counting the sessions that made it to product and then we're dividing those by the total sessions to get the click rate. It will help us how many people are clicking through at each step.
-- /n So we see lander click rate is 47% product page is 74% and etc 


-- 12. Comparing the /billing-2 page with the original /billing page to see the difference. And analysing the % of sessions on those pages end up placing an order. Limiting the data before November 10th 2012.

-- Finding the first time /billing-2 was seen
SELECT 
	MIN(website_pageviews.website_pageview_id) AS first_pv_id
    FROM website_pageviews
    WHERE pageview_url = '/billing-2';
-- Therefore, the first website_pageview_id for the /billing-2 page is 53550.

SELECT 
    wp.website_session_id,
    wp.pageview_url AS billing_pageviews_seen,
    od.order_id
FROM
    website_pageviews AS wp
        LEFT JOIN
    orders AS od ON wp.website_session_id = od.website_session_id
WHERE
    wp.pageview_url IN ('/billing-2' , '/billing')
        AND wp.website_pageview_id >= 53550
        AND wp.created_at < '2012-11-10';

SELECT 
    billing_pageviews_seen,
    COUNT(DISTINCT website_session_id) AS Sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id)* 100 AS billing_to_order_rate
FROM
    (SELECT 
        wp.website_session_id,
            wp.pageview_url AS billing_pageviews_seen,
            od.order_id
    FROM
        website_pageviews AS wp
    LEFT JOIN orders AS od ON wp.website_session_id = od.website_session_id
    WHERE
        wp.pageview_url IN ('/billing-2' , '/billing')
            AND wp.website_pageview_id >= 53550
            AND wp.created_at < '2012-11-10') AS billing_session_w_orders
GROUP BY 1;
-- *Insights: billing and billing-2 pages have almost the same number of sessions 657 and 654. But it looks like /billing-2 has a lot more orders 410 and the conversion rate to order is substantially higher 62%.
-- /n orders we have from the billing page is 300 and conversion rate is just 45% which is lower than the billing-2 page. Looks like the new version of the billing page is doing a much better job in converting customers.


 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- -- Analysing for Channel Portfolio Management --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
                       -- Trying to dive deeper into our channel mix and explore paid traffic and free traffic and looking mobile V/S desktop performacne -- 

-- 13. Analysing the second paid search channel 'bsearch'. And pulling out weekly trended session volume and comparing to gsearch nonbrand. Limiting the data before November 29th 2012.
SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS gsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) AS bsearch_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-08-22' AND '2012-11-29'
        AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);
-- *Insights: It's look like Gsearch is about three times as bigger as Bsearch and that seems to be pretty consistent across each of these weeks. But we can see the sudden increase in the Bsearch sessions on '2012-11-18' and the following week.


-- 14. Pulling out the percentage of traffic coming on mobile via bsearch nonbrand campaign and comparing the same with the gsearch campaign. Aggregating the data since the August 22nd and limiting the data before November 30th 2012.
SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) * 100 AS pct_mobile
FROM
    website_sessions
WHERE
    created_at > '2012-08-22'
        AND created_at < '2012-11-30'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;
 -- *Insights: we can see that the gseatch is about 24.5% of mobile. Whereas bsearch is only about 8% of mobile. These two campaigns are quite different from a device standpoint.


-- 15. Pulling out the weekly session volume for gsearch and bsearch nonbrand, broken down by device and including a comparison metric to show bsearch as a percent of gsearch for each device. Limiting the data before December 22nd 2012. 
SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS g_dtop_session,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_dtop_session,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_pct_of_g_dtop,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS g_mob_session,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_mob_session,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_pct_of_g_mob
FROM
    website_sessions
WHERE
    created_at > '2012-11-04'
        AND created_at < '2012-12-22'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at) , WEEK(created_at);
-- *Insights: we can see the trended results and we can see there's been an impact on 2nd December where I feel they are bidding down bsearch. 
-- /n Before the bid down, we were seeing relatively stable numbers of bsearch being about 40% of the gsearch volumne on desktop. 
-- /n Intrestingly, the week of the bid down, we do see bsearch falling more than gsearch and now it's down to 23%. So it dose look like that bid changes impacted volume here.


-- 16. Pulling organic search, direct type in, and paid brand search sessions by month, and showing those sessions as a percentage of paid search nonbrand. Limiting the data before December 23rd 2012. 
SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN channel_group ='paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group ='paid_brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group ='paid_brand' THEN website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN channel_group ='paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nobrand,
    COUNT(DISTINCT CASE WHEN channel_group ='direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
     COUNT(DISTINCT CASE WHEN channel_group ='direct_type_in' THEN website_session_id ELSE NULL END) / 
     COUNT(DISTINCT CASE WHEN channel_group ='paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
     COUNT(DISTINCT CASE WHEN channel_group ='organic_search' THEN website_session_id ELSE NULL END) AS organic,
     COUNT(DISTINCT CASE WHEN channel_group ='organic_search' THEN website_session_id ELSE NULL END)/
     COUNT(DISTINCT CASE WHEN channel_group ='paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM (
SELECT 
    website_session_id,
    created_at,
    CASE WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com')THEN 'organic_search' 
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        END AS channel_group
	FROM website_sessions
WHERE
    created_at < '2012-12-23'
) AS sessions_w_channel_group
GROUP BY YEAR(created_at) , MONTH(created_at);
-- *Insights: What's intresting here over time, if we look at the organic in April 2012, organic is about 2% of non brand and then it builds over time and in December it almost seven and a half percent of the non brand traffic.
-- /n it's look like the organic search is picking up and it seems to be growing faster than non brand traffic, which is a good thing because we're not paying for the organic search. Same story with the direct as a percent of non brand. 
-- /n Brand as percent of non brand is also a similar story, it's not quite as high but it's on a similar trend. 


 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- -- Product Analysis --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
-- Now, we're looking into the product level sales and conversion rate trends and do some analysis on product refund rates t keep an eye on quality.
-- /n Analysing Product sales helps us understand how each product contributes to our business and how product launches impact the overall portfolio. 

-- 17. Pulling monthly trends to date for number of sales, total revenue, and total margin generated for the business. Limiting the data before January 4th 2013.alter
SELECT 
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
    orders
WHERE
    created_at < '2013-01-04'
GROUP BY 1 , 2;
-- *Insights: We can see that the number of sales going up from 60 all the way upto 618 in November of 2012. Similar trend in increasing revenue and increasing total margin.


-- 18. Comparing the Product from the time period since April 1st 2012 to April 5th 2013. Breaking down monthly order volume, overall conversion rates, revenue per session and a breakdown of sales by product.
SELECT 
    YEAR(ws.created_at) AS YR,
    MONTH(ws.created_at) AS MO,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    SUM(od.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE
            WHEN od.primary_product_id = 1 THEN od.order_id
            ELSE NULL
        END) AS product_one_orders,
    COUNT(DISTINCT CASE
            WHEN od.primary_product_id = 2 THEN od.order_id
            ELSE NULL
        END) AS product_two_orders
FROM
    website_sessions AS ws
        LEFT JOIN
    orders AS od ON ws.website_session_id = od.website_session_id
WHERE
    ws.created_at > '2012-04-01'
        AND ws.created_at < '2013-04-01'
GROUP BY 1 , 2
ORDER BY 1 , 2;
-- *Insights: We can see that the product two have no orders unti Janurary 2013. But on February 2013, Product two gets a lot of sales and then kind of reduced in March 2013. 
-- /n Revenue per sessions seems a pretty strong and conversion rates similary have improved in general.


-- 19. Now, we have a new product, I'm thinking about our user path and conversion funnel. Looking at the sessions which hit the /product page and see where they went next. 
-- /n pulling out clickthrough rate from /products since the new product launch on 6th Janurary 2013. Comparing to the 3 month leading up to launch as a baseline. Limiting the data before April 6th 2013.
-- STEP 1: Finding the relevant /product pageview with website_session_id
-- STEP 2: Finding the next pageview id that occurs AFTER the product pageview
-- STEP 3: Finding the pageview_url associated with any applicable next pageview_id
-- STEP 4: Summarize the data and analyze the pre vs post periods.

CREATE TEMPORARY TABLE first_table
SELECT 
    website_session_id,
    website_pageview_id,
    created_at,
    CASE
        WHEN created_at < '2013-01-06' THEN 'A.Pre_product'
        WHEN created_at >= '2013-01-06' THEN 'B.Post_product'
        ELSE 'uh.Oh..Check logic'
    END AS time_period
FROM
    website_pageviews
WHERE
    created_at > '2012-10-06'
        AND created_at < '2013-04-06'
        AND pageview_url = '/products';

-- finding the next pageview id that occurs AFTER the product pageviews.
CREATE TEMPORARY TABLE second_table
SELECT 
    ft.time_period,
    ft.website_session_id,
    MIN(wp.website_pageview_id) AS min_next_paveview_id
FROM
    first_table AS ft
        LEFT JOIN
    website_pageviews AS wp ON wp.website_session_id = ft.website_session_id
        AND wp.website_pageview_id > ft.website_pageview_id
GROUP BY 1 , 2;

-- Find the pageview url associated with any applicable next pageview id
CREATE TEMPORARY TABLE third_table
SELECT 
    sd.time_period,
    sd.website_session_id,
    wp.pageview_url AS next_pageview_url
FROM
    second_table AS sd
        LEFT JOIN
    website_pageviews AS wp ON wp.website_pageview_id = sd.min_next_paveview_id;

SELECT 
    time_period,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url IS NOT NULL THEN website_session_id
            ELSE NULL
        END) AS w_next_page,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url IS NOT NULL THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_w_next_page,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) AS to_fuzzy,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_to_fuzzy,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) AS to_bear,
    COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS pct_to_bear
FROM
    third_table
GROUP BY 1;
-- *Insights: Now we have a two time periods. Percent of sessions with the next page which looks like previously we were at 72 percent Now we're at 76.5%. 72% of customer clicking for MrFuzzy page and 62% were clicking after post product launch.
-- /n Looks like the percent of /product pageviews that clicked to Mr Fuzzy has gone down since the launch of the lovebear, but the overall clickthrough rate has gone up, so it seems to be generating additional product interest overall. 


-- 19. Analysing the conversion funnel from each product page to conversion. Comparison between the two conversion funnels, for all website traffic. Limiting the data before April 10th 2014. 
CREATE TEMPORARY TABLE session_seeing_product_pages
SELECT 
    website_session_id,
    website_pageview_id,
    pageview_url AS product_page_seen
FROM
    website_pageviews
WHERE
    created_at < '2013-04-10'
        AND created_at > '2013-01-06'
        AND pageview_url IN ('/the-original-mr-fuzzy' , '/the-forever-love-bear')
GROUP BY 1;
 
SELECT DISTINCT
    wp.pageview_url
FROM
    session_seeing_product_pages AS ss
        LEFT JOIN
    website_pageviews AS wp ON ss.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > ss.website_pageview_id;

SELECT 
    ss.website_session_id,
    ss.product_page_seen,
    CASE
        WHEN wp.pageview_url = '/cart' THEN 1
        ELSE 0
    END AS cart_page,
    CASE
        WHEN wp.pageview_url = '/shipping' THEN 1
        ELSE 0
    END AS shipping_page,
    CASE
        WHEN wp.pageview_url = '/billing-2' THEN 1
        ELSE 0
    END AS billing_page,
    CASE
        WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1
        ELSE 0
    END AS thanku_page
FROM
    session_seeing_product_pages AS ss
        LEFT JOIN
    website_pageviews AS wp ON ss.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > ss.website_pageview_id;

CREATE TEMPORARY TABLE xyzzzz
SELECT 
    website_session_id,
    CASE WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'MRfuzzy'
	 WHEN product_page_seen = '/the-forever-love-bear' THEN 'LOVEbear'
     ELSE 'uh oh... check logic'
     END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thanku_page) AS thanku_made_it
FROM
    (SELECT 
        ss.website_session_id,
            ss.product_page_seen,
            CASE
                WHEN wp.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN wp.pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN wp.pageview_url = '/billing-2' THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thanku_page
    FROM
        session_seeing_product_pages AS ss
    LEFT JOIN website_pageviews AS wp ON ss.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > ss.website_pageview_id) AS page_view
GROUP BY 1,
     CASE WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'Mrfuzzy'
	 WHEN product_page_seen = '/the-forever-love-bear' THEN 'LOVEbear'
     ELSE 'uh oh... check logic'
     END;
-- -- Final output 1
SELECT 
    product_seen,
    COUNT(DISTINCT website_session_id) AS session,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_shipping,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_billing,
    COUNT(DISTINCT CASE
            WHEN thanku_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_thanku
FROM
    xyzzzz
GROUP BY 1;
-- Final output 2
SELECT 
   product_seen,
    COUNT(DISTINCT website_session_id) AS session,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS cart_click_rt,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS shipping_click_rt,
    COUNT(DISTINCT CASE
            WHEN thanku_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS billing_click_rt
FROM
    xyzzzz
GROUP BY 1;
-- *Insights: The products page click through rate does look fairly different. 43% of people seeing Mr. Fuzzy Click through to the cart and 55% almost click through from lovebear to the cart.
-- /n we had found that adding a second product increased overall CTR from the /product page, and this analysis shows that the Love Bear has a better click rate to the /cart page and comparable rates throughout the rest of the funnel.


-- 20. Pulling monthly product refund rates by products. Limiting the data before October 15th 2014.
SELECT 
    YEAR(od.created_at) AS yr,
    MONTH(od.created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 1 THEN od.order_item_id
            ELSE NULL
        END) AS p1_orders,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 1 THEN rd.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN od.product_id = 1 THEN od.order_id
            ELSE NULL
        END) AS p1_refund_rate,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 2 THEN od.order_item_id
            ELSE NULL
        END) AS p2_orders,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 2 THEN rd.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN od.product_id = 2 THEN od.order_id
            ELSE NULL
        END) AS p2_refund_rate,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 3 THEN od.order_item_id
            ELSE NULL
        END) AS p3_orders,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 3 THEN rd.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN od.product_id = 3 THEN od.order_id
            ELSE NULL
        END) AS p3_refund_rate,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 4 THEN od.order_item_id
            ELSE NULL
        END) AS p4_orders,
    COUNT(DISTINCT CASE
            WHEN od.product_id = 4 THEN rd.order_item_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN od.product_id = 4 THEN od.order_id
            ELSE NULL
        END) AS p4_refund_rate
FROM
    order_items AS od
        LEFT JOIN
    order_item_refunds AS rd ON od.order_id = rd.order_id
WHERE
    od.created_at < '2014-10-15'
GROUP BY 1 , 2;
 -- *Insights: For 2014 August and september we can see the higest jump in refund for the product 1 that is 13%-14%. it seems we have a major problem with repect to product 1.
 -- /n Look like the refund rates for Product 1 did go down after the initial improvement in september 2013, but refund rates were terrible in August and September (13%-14%)


 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
 --   **  --  --   **  -- 	 --   **  -- 	 --   **  -- 	 --   **  --  --   **  --  THANK YOU  --  **  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 
 --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  --  --   **  -- 



















