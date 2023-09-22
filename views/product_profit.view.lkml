
view: product_profit {
  derived_table: {
    sql: WITH ProductProfitability AS (
          SELECT
              product_id,
              product_name,
              sub_category,
              category,
              SUM(shipping_cost) AS total_shipping_cost,
              SUM(discount) AS total_discount,
              SUM(profit) AS total_profit,
              COUNT(DISTINCT customer_id) AS customer_count
          FROM orders
          GROUP BY product_id, product_name, sub_category, category
      ),

      NormalizedProfitability AS (
          SELECT
              product_id,
              product_name,
              sub_category,
              category,
              total_shipping_cost,
              total_discount,
              total_profit,
              customer_count,
              (total_profit - total_discount - total_shipping_cost) AS normalized_profit
          FROM ProductProfitability
      )

      SELECT
          product_id,
          product_name,
          sub_category,
          category,
          total_shipping_cost,
          total_discount,
          customer_count,
          (normalized_profit - MIN(normalized_profit) OVER ()) /
          (MAX(normalized_profit) OVER () - MIN(normalized_profit) OVER ()) * 10 AS scaled_profitability
      FROM NormalizedProfitability ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}."PRODUCT_NAME" ;;
  }

  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: total_shipping_cost {
    type: number
    sql: ${TABLE}."TOTAL_SHIPPING_COST" ;;
  }

  dimension: total_discount {
    type: number
    sql: ${TABLE}."TOTAL_DISCOUNT" ;;
  }

  dimension: customer_count {
    type: number
    sql: ${TABLE}."CUSTOMER_COUNT" ;;
  }

  dimension: scaled_profitability {
    type: number
    sql: ${TABLE}."SCALED_PROFITABILITY" ;;
  }
  measure: scaled_profitablity_measure {
    label: "Product Profit"
    type: sum
    sql: ${scaled_profitability} ;;
  }

  set: detail {
    fields: [
        product_id,
  product_name,
  sub_category,
  category,
  total_shipping_cost,
  total_discount,
  customer_count,
  scaled_profitability
    ]
  }
}
