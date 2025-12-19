{{ config(materialized = 'table') }}

-- core shopper dimension
-- includes demographic and personal attributes used for segmentation

select
    shopper_id,
    shopper_age

from {{ ref('stg_seqdb__shopper') }}
