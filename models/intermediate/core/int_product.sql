{{ config(materialized = 'table') }}

-- core product dimension
-- created to replicate a realistic analytical environment

select
    product_id,
    product_name

from {{ ref('stg_seqdb__product') }}
