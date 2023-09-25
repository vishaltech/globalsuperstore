
view: customer_churn {
  derived_table: {
    sql: WITH customer_metrics AS (
          SELECT
              customer_id,
              customer_name,
              MAX(order_date) AS last_order_date,
              COUNT(DISTINCT order_id) AS total_orders,
              SUM(sales) AS total_sales,
              AVG(discount) AS avg_discount
          FROM
              orders
          GROUP BY
              customer_id, customer_name
      ),
      recency_score AS (
          SELECT
              customer_id,
              CASE
                  WHEN DATEDIFF(DAY, last_order_date, GETDATE()) <= 30 THEN 1
                  WHEN DATEDIFF(DAY, last_order_date, GETDATE()) <= 60 THEN 2
                  ELSE 3
              END AS recency
          FROM
              customer_metrics
      ),
      frequency_score AS (
          SELECT
              customer_id,
              CASE
                  WHEN total_orders >= 5 THEN 1
                  WHEN total_orders >= 2 THEN 2
                  ELSE 3
              END AS frequency
          FROM
              customer_metrics
      ),
      monetary_score AS (
          SELECT
              customer_id,
              CASE
                  WHEN total_sales >= 1000 THEN 1
                  WHEN total_sales >= 500 THEN 2
                  ELSE 3
              END AS monetary
          FROM
              customer_metrics
      ),
      discount_score AS (
          SELECT
              customer_id,
              CASE
                  WHEN avg_discount <= 0.1 THEN 1
                  WHEN avg_discount <= 0.2 THEN 2
                  ELSE 3
              END AS discount
          FROM
              customer_metrics
      ),
      combined_scores AS (
          SELECT
              cm.customer_id,
              cm.customer_name,
              rs.recency,
              fs.frequency,
              ms.monetary,
              ds.discount,
              (rs.recency + fs.frequency + ms.monetary + ds.discount) AS churn_risk_score
          FROM
              customer_metrics cm
          INNER JOIN recency_score rs ON cm.customer_id = rs.customer_id
          INNER JOIN frequency_score fs ON cm.customer_id = fs.customer_id
          INNER JOIN monetary_score ms ON cm.customer_id = ms.customer_id
          INNER JOIN discount_score ds ON cm.customer_id = ds.customer_id
      )
      SELECT
          customer_id,
          customer_name,
          CASE
              WHEN churn_risk_score <= 4 THEN 'Low Risk'
              WHEN churn_risk_score <= 8 THEN 'Medium Risk'
              ELSE 'High Risk'
          END AS churn_risk_level,
          ROUND((CAST(churn_risk_score AS FLOAT) / 12.0) * 100, 0) AS churn_risk_percentage
      FROM
          combined_scores
      ORDER BY
          churn_risk_score ASC ;;
  }

  measure: count {
    type: count_distinct
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

  dimension: churn_risk_level {
    type: string
    sql: ${TABLE}."CHURN_RISK_LEVEL" ;;
  }

  dimension: churn_risk_percentage {
    type: number
    sql: ${TABLE}."CHURN_RISK_PERCENTAGE" ;;
  }

  set: detail {
    fields: [
        customer_id,
  customer_name,
  churn_risk_level,
  churn_risk_percentage
    ]
  }
}
