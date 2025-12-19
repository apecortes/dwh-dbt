{{ config(materialized = 'table') }}

-- core merchant dimension
-- minimal by design, but structured for future enrichment

select
    merchant_id,
    merchant_name

from {{ ref('stg_seqdb__merchant') }}
