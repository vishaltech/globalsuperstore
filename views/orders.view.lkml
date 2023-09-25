view: orders {

  dimension: order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  measure: order_count {
    label: "Order Count"
    type: count_distinct
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: order_date {
    type: time
    sql: ${TABLE}."ORDER_DATE" ;;
  }

  dimension_group: ship_date {
    type: time
    sql: ${TABLE}."SHIP_DATE" ;;
  }

  dimension: ship_mode {
    type: string
    sql: ${TABLE}."SHIP_MODE" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  measure: customer_count {
    label: "Customer Count"
    type: count_distinct
    sql: ${customer_id} ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: segment {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    map_layer_name: "us_states"
    sql: ${TABLE}."STATE" ;;
  }

  dimension: country {
    type: string
    map_layer_name: "countries"
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: postal_code {
    type: number
    sql: ${TABLE}."POSTAL_CODE" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}."PRODUCT_NAME" ;;
  }

  dimension: sales {
    type: number
    sql: ${TABLE}."SALES" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: discount {
    type: number
    sql: ${TABLE}."DISCOUNT" ;;
  }

  dimension: profit {
    type: number
    sql: ${TABLE}."PROFIT" ;;
  }

  dimension: shipping_cost {
    type: number
    sql: ${TABLE}."SHIPPING_COST" ;;
  }

  dimension: order_priority {
    type: string
    sql: ${TABLE}."ORDER_PRIORITY" ;;
  }

  measure: total_profit {
    label: "Total Profit"
    type: sum
    sql: ${TABLE}.profit ;;
    value_format: "0"
    value_format_name: usd_0
  }

  measure: total_sales {
    label: "Total Sales"
    type: sum
    sql: ${TABLE}.sales ;;
  }

  measure: avg_discount {
    label: "Average Discount"
    type: average
    sql: ${TABLE}.discount ;;
  }

  measure: avg_quantity {
    label: "Average Quantity"
    type: average
    sql: ${TABLE}.quantity ;;
  }

  measure: total_shipping_cost {
    label: "Total Shipping Cost"
    type: sum
    sql: ${TABLE}.shipping_cost ;;
  }
  measure: avg_shipping_time {
    label: "Average Shipping Time"
    type: average
    sql: DATEDIFF('DAY', CAST(${TABLE}.ORDER_DATE AS TIMESTAMP), CAST(${TABLE}.SHIP_DATE AS TIMESTAMP)) ;;
    value_format: "0.0"  # This will display the value as a decimal with one digit after the decimal point
  }

  measure: order_priority_weight {
    label: "Order Priority Weight"
    type: average
    sql: CASE
           WHEN ${TABLE}.order_priority = 'High' THEN 3
           WHEN ${TABLE}.order_priority = 'Medium' THEN 2
           WHEN ${TABLE}.order_priority = 'Low' THEN 1
           ELSE 0
         END ;;
  }
  measure: profit_efficiency_score_scaled {
    label: "Profit Efficiency Score"
    type: number
    sql: 100 * (
                (${total_profit} / ${total_sales}) *
                (1 - (${avg_discount} / ${avg_quantity})) *
                (1 + (${total_sales} / ${total_shipping_cost})) *
                (${order_priority_weight} / ${avg_shipping_time})
              ) ;;
  }
  measure: avg_sales_per_customer {
    type: average
    sql: ${TABLE}.sales ;;
    value_format_name: usd_0
  }

  measure: avg_discount_per_customer {
    type: average
    sql: ${TABLE}.discount ;;
  }

  measure: avg_profit_per_customer {
    type: average
    sql: ${TABLE}.profit ;;
  }

  measure: avg_shipping_cost_per_customer {
    type: average
    sql: ${TABLE}.shipping_cost ;;
  }

  measure: avg_quantity_per_customer {
    type: average
    sql: ${TABLE}.quantity ;;
  }

  measure: avg_order_priority_per_customer {
    type: average
    sql: CASE
           WHEN ${TABLE}.order_priority = 'High' THEN 3
           WHEN ${TABLE}.order_priority = 'Medium' THEN 2
           WHEN ${TABLE}.order_priority = 'Low' THEN 1
           ELSE 0
         END ;;
  }
    measure: avg_sales {
      type: number
      sql: AVG(orders.sales) ;;
      hidden: yes
    }

    measure: avg_discountt {
      type: number
      sql: AVG(orders.discount) ;;
      hidden: yes
    }

    measure: avg_profit {
      type: number
      sql: AVG(orders.profit) ;;
      hidden: yes
    }

    measure: avg_shipping_cost {
      type: number
      sql: AVG(orders.shipping_cost) ;;
      hidden: yes
    }

    measure: avg_quantityy {
      type: number
      sql: AVG(orders.quantity) ;;
      hidden: yes
    }

    measure: avg_order_priority {
      type: number
      sql: AVG(CASE
          WHEN orders.order_priority = 'High' THEN 3
          WHEN orders.order_priority = 'Medium' THEN 2
          WHEN orders.order_priority = 'Low' THEN 1
          ELSE 0
        END) ;;
      hidden: yes
    }
  measure: customer_value_index {
    type: number
    sql: CASE
          WHEN AVG(orders.sales) <= 0 THEN 0
          WHEN AVG(orders.discount) <= 0 OR AVG(orders.shipping_cost) <= 0 THEN 0
          ELSE (
              CASE
                WHEN AVG(orders.sales) / (AVG(orders.discount) + 0.001) <= 0 THEN 0
                ELSE LN(1 + AVG(orders.sales) / (AVG(orders.discount) + 0.001))
              END *
              CASE
                WHEN AVG(orders.profit) / (AVG(orders.shipping_cost) + 0.001) <= 0 THEN 0
                ELSE LN(1 + AVG(orders.profit) / (AVG(orders.shipping_cost) + 0.001))
              END *
              CASE
                WHEN AVG(orders.quantity) / (AVG(CASE
                  WHEN orders.order_priority = 'High' THEN 3
                  WHEN orders.order_priority = 'Medium' THEN 2
                  WHEN orders.order_priority = 'Low' THEN 1
                  ELSE 0
                END) + 0.001) <= 0 THEN 0
                ELSE LN(1 + AVG(orders.quantity) / (AVG(CASE
                  WHEN orders.order_priority = 'High' THEN 3
                  WHEN orders.order_priority = 'Medium' THEN 2
                  WHEN orders.order_priority = 'Low' THEN 1
                  ELSE 0
                END) + 0.001))
              END
          )
        END ;;
  }




  set: detail {
    fields: [
      order_id,
      order_date_time,
      ship_date_time,
      ship_mode,
      customer_id,
      customer_name,
      segment,
      city,
      state,
      country,
      postal_code,
      market,
      region,
      product_id,
      category,
      sub_category,
      product_name,
      sales,
      quantity,
      discount,
      profit,
      shipping_cost,
      order_priority
    ]
  }
}
