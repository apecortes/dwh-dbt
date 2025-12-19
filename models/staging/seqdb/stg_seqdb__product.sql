
-- this table is included to replicate a more realistic analytical environment.
-- although minimal, it allows the final dataset to expose product-level analysis
-- as required by the output specification of part 2 of the challenge.

select
    cast(product_id as int64) as product_id,
    cast(product_name as string) as product_name
    
from {{ source('seqdb', 'product') }}
