
-- this table is included to replicate a more realistic analytical environment.
-- it allows the final dataset to expose merchant-level information,
-- which is required by the output specification of part 2 of the challenge.

select
    cast(merchant_id as int64) as merchant_id,
    cast(merchant_name as string) as merchant_name

from {{ source('seqdb', 'merchant') }}
