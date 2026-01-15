/****************************************************************************************
 Script Name  : create_gold_views.sql
 Author       : Bablu
 Description  :
     This script creates GOLD layer views for analytics and reporting.
     - Builds conformed DIMENSIONS (Customers, Products)
     - Builds FACT table (Sales)
     - Applies surrogate keys for dimensional modeling
     - Filters only current (active) product records
     - Joins Silver-layer cleansed data

 Layer        : GOLD (Analytics & Reporting)
 Database     : Education
****************************************************************************************/

------------------------------------------------------------
-- GOLD.DIM_CUSTOMERS
------------------------------------------------------------
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY sci.cst_id)           AS customer_key,
    sci.cst_id                                        AS customer_id,
    sci.cst_key                                       AS customer_number,
    sci.cst_firstname                                 AS first_name,
    sci.cst_lastname                                  AS last_name,
    sel.cntry                                         AS country,
    sci.cst_material_status                           AS marital_status,
    CASE 
        WHEN sci.cst_gndr <> 'n/a' 
            THEN sci.cst_gndr
        ELSE COALESCE(sec.gen, 'n/a')
    END                                               AS gender,
    sec.bdate                                         AS birth_date,
    sci.cst_create_date                               AS create_date
FROM silver.crm_cust_info      AS sci
LEFT JOIN silver.erp_cust_az12 AS sec
    ON sec.cid = sci.cst_key
LEFT JOIN silver.erp_loc_a101  AS sel
    ON sel.cid = sci.cst_key;
GO

------------------------------------------------------------
-- GOLD.DIM_PRODUCT
------------------------------------------------------------
CREATE OR ALTER VIEW gold.dim_product AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    )                                                 AS product_key,
    pn.prd_id                                         AS product_id,
    pn.prd_key                                        AS product_number,
    pn.prd_nm                                         AS product_name,
    pn.cat_id                                         AS category_id,
    pc.cat                                            AS category,
    pc.subcat                                         AS subcategory,
    pc.maintenance                                    AS maintenance,
    pn.prd_cost                                       AS cost,
    pn.prd_line                                       AS product_line,
    pn.prd_start_dt                                  AS start_date
FROM silver.crm_prd_info        AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pc.id = pn.cat_id
-- Current (active) products only
WHERE pn.prd_end_dt IS NULL;
GO

------------------------------------------------------------
-- GOLD.FACT_SALES
------------------------------------------------------------
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    sc.sls_ord_num                                    AS order_number,
    gp.product_key,
    gc.customer_key,
    sc.sls_cust_id                                   AS customer_id,
    sc.sls_order_dt                                  AS order_date,
    sc.sls_ship_dt                                   AS ship_date,
    sc.sls_due_dt                                    AS due_date,
    sc.sls_sales                                     AS sales,
    sc.sls_quantity                                  AS quantity,
    sc.sls_price                                     AS price
FROM silver.crm_sales_details AS sc
LEFT JOIN gold.dim_product     AS gp
    ON gp.product_number = sc.sls_prd_key
LEFT JOIN gold.dim_customers   AS gc
    ON gc.customer_id = sc.sls_cust_id;
GO
