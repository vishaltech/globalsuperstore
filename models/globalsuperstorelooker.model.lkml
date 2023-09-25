connection: "lookersnowflakesuperstore"

datagroup: globalsuperstorelooker_default_datagroup {
  max_cache_age: "1 hour"
}

include: "/views/orders.view.lkml" # Assuming the view file is named "orders.view.lkml"
include: "/views/product_profit.view.lkml"
include: "/views/customer_churn.view.lkml"
include: "/views/discount_model.view.lkml"



explore: orders {
  label: "Orders"
  from: orders # This specifies which view to use for this explore
  persist_with: globalsuperstorelooker_default_datagroup
  # Add joins, always_filter, and other explore-level configurations if needed
join: product_profit {
  type: left_outer
  relationship: many_to_one
  sql_on: ${orders.product_id} =  ${product_profit.product_id};;
}
  join: customer_churn {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.customer_id} =  ${customer_churn.customer_id};;
  }
  join: discount_model {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.customer_id} =  ${discount_model.customer_id};;
  }
}
