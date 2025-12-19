
-- this table is included to replicate a more realistic analytical environment.
-- default types are modeled as a separate dimension to allow
-- default classification analysis in the final output dataset.

select
    cast(dt.default_type_id as int64) as default_type_id,
    cast(dt.default_type_name as string) as default_type_name

from {{ source('seqdb', 'default_order_type') }} as dt
