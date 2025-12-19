
select
    cast(order_id as int64) as order_id,
    cast(shopper_id as int64) as shopper_id,
    cast(order_date as date) as order_date,
    cast(product_id as int64) as product_id,
    cast(merchant_id as int64) as merchant_id,
    cast(is_in_default as bool) as is_in_default,
    cast(days_unbalanced as int64) as days_unbalanced,
    cast(current_order_value as numeric) as current_order_value,
    cast(overdue_principal as numeric) as overdue_principal,
    cast(overdue_fees as numeric) as overdue_fees
    
from {{ source('seqdb', 'orders') }}
