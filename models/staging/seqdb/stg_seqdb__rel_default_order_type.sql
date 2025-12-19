
select
    cast(order_id as int64) as order_id,
    cast(default_type_id as int64) as default_type_id

from {{ source('seqdb', 'rel_default_order_type') }}
