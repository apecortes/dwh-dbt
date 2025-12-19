
select
    cast(shopper_id as int64) as shopper_id,
    cast(age as int64) as shopper_age
    
from {{ source('seqdb', 'shopper') }}
