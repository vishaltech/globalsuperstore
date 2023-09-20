connection: "lookersnowflakesuperstore"

datagroup: globalsuperstorelooker_default_datagroup {
  max_cache_age: "1 hour"
}

include: "/views/orders.view.lkml" # Assuming the view file is named "orders.view.lkml"

explore: orders {
  label: "Orders"
  from: orders # This specifies which view to use for this explore
  persist_with: globalsuperstorelooker_default_datagroup
  # Add joins, always_filter, and other explore-level configurations if needed
}
