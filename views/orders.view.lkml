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
