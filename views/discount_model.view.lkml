
view: discount_model {
  derived_table: {
    sql: WITH customer_base AS (
        SELECT
            customer_id,
            customer_name,
            region,
            SUM(sales) AS total_sales,
            COUNT(DISTINCT order_id) AS order_count,
            AVG(profit / sales) AS avg_profit_margin,
            AVG(DATEDIFF('day', order_date, ship_date)) AS avg_days_between_orders,
            AVG(shipping_cost) AS avg_shipping_cost
        FROM orders
        GROUP BY customer_id, customer_name, region
      ),
      avg_cdsqi AS (
        SELECT AVG((total_sales * order_count * avg_profit_margin) / NULLIF(avg_days_between_orders * (1 + avg_shipping_cost), 0)) AS avg_cdsqi
        FROM customer_base
      ),
      frequent_order_day AS (
        SELECT
            region,
            EXTRACT(DAYOFWEEK FROM order_date) AS order_day,
            COUNT(*) AS day_count,
            SUM(sales) AS total_sales,
            AVG(profit / sales) AS avg_profit_margin
        FROM orders
        GROUP BY region, order_day
      ),
      best_day_score AS (
        SELECT
            region,
            order_day,
            RANK() OVER (PARTITION BY region ORDER BY day_count DESC) AS rank_by_order_count,
            RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rank_by_total_sales,
            RANK() OVER (PARTITION BY region ORDER BY avg_profit_margin ASC) AS rank_by_profit_margin,
            (RANK() OVER (PARTITION BY region ORDER BY day_count DESC) +
             RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) +
             RANK() OVER (PARTITION BY region ORDER BY avg_profit_margin ASC)) AS composite_score
        FROM frequent_order_day
      ),
      best_day_for_discount AS (
        SELECT DISTINCT
            region,
            FIRST_VALUE(order_day) OVER (PARTITION BY region ORDER BY composite_score ASC) AS best_discount_day
        FROM best_day_score
      ),
      day_name_mapping AS (
        SELECT
          1 AS day_number, 'Sunday' AS day_name UNION ALL
          SELECT 2, 'Monday' UNION ALL
          SELECT 3, 'Tuesday' UNION ALL
          SELECT 4, 'Wednesday' UNION ALL
          SELECT 5, 'Thursday' UNION ALL
          SELECT 6, 'Friday' UNION ALL
          SELECT 7, 'Saturday'
      ),
      discount_candidates AS (
        SELECT DISTINCT
            cb.customer_id,
            cb.customer_name,
            cb.region,
            (cb.total_sales * cb.order_count * cb.avg_profit_margin) / NULLIF(cb.avg_days_between_orders * (1 + cb.avg_shipping_cost), 0) AS cdsqi,
            RANK() OVER (PARTITION BY cb.region ORDER BY cdsqi DESC) AS cdsqi_rank
        FROM customer_base cb, avg_cdsqi ac
        WHERE cdsqi IS NOT NULL AND cdsqi < ac.avg_cdsqi
      ),
      shipping_issues AS (
        SELECT
            customer_id,
            MAX(order_id) AS recent_order_issue,
            COUNT(order_id) AS issue_count
        FROM orders
        WHERE DATEDIFF('day', order_date, ship_date) > (SELECT AVG(DATEDIFF('day', order_date, ship_date)) FROM orders)
        GROUP BY customer_id
      )
      SELECT
          dc.customer_id,
          dc.customer_name,
          dc.region,
          dc.cdsqi AS discount_candidate_cdsqi,
          dc.cdsqi_rank,
          dn.day_name AS best_day_for_discount,
          CASE
              WHEN si.customer_id IS NOT NULL THEN si.customer_id
              ELSE 'N/A'
          END AS shipping_issue_customer,
          si.recent_order_issue,
          si.issue_count
      FROM discount_candidates dc
      JOIN best_day_for_discount bdd ON dc.region = bdd.region
      JOIN day_name_mapping dn ON bdd.best_discount_day = dn.day_number
      LEFT JOIN shipping_issues si ON dc.customer_id = si.customer_id
      ORDER BY dc.region, dc.cdsqi_rank ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: discount_candidate_cdsqi {
    type: number
    sql: ${TABLE}."DISCOUNT_CANDIDATE_CDSQI" ;;
  }

  dimension: cdsqi_rank {
    type: number
    sql: ${TABLE}."CDSQI_RANK" ;;
  }

  dimension: best_day_for_discount {
    type: string
    sql: ${TABLE}."BEST_DAY_FOR_DISCOUNT" ;;
  }

  dimension: shipping_issue_customer {
    type: string
    sql: ${TABLE}."SHIPPING_ISSUE_CUSTOMER" ;;
  }

  dimension: recent_order_issue {
    type: string
    sql: ${TABLE}."RECENT_ORDER_ISSUE" ;;
  }
  measure: cdsqi_measure {
    type: number
    sql: ${cdsqi_rank} ;;
  }

  dimension: issue_count {
    type: number
    sql: ${TABLE}."ISSUE_COUNT" ;;
  }

  set: detail {
    fields: [
        customer_id,
  customer_name,
  region,
  discount_candidate_cdsqi,
  cdsqi_rank,
  best_day_for_discount,
  shipping_issue_customer,
  recent_order_issue,
  issue_count
    ]
  }
}
