{{ config(materialized = 'table') }}

with orders as (

    select
        order_id,
        shopper_id,
        merchant_id,
        product_id,
        order_date,
        is_in_default,
        days_unbalanced,
        current_order_value,
        overdue_principal,
        overdue_fees

    from {{ ref('stg_seqdb__orders') }}

),

rel_default_order_type as (

    select
        order_id,
        default_type_id

    from {{ ref('stg_seqdb__rel_default_order_type') }}

),

default_type as (

    select
        default_type_id,
        default_type_name

    from {{ ref('stg_seqdb__default_order_type') }}

),

final as (

    select
        -- id columns
        o.order_id,
        o.shopper_id,
        o.merchant_id,
        o.product_id,

        -- amounts
        o.current_order_value,
        o.overdue_principal,
        o.overdue_fees,

        -- default info
        o.is_in_default,
        o.days_unbalanced,
        dt.default_type_name,

        -- dates
        o.order_date

    from orders o
    left join rel_default_order_type r
        on o.order_id = r.order_id
    left join default_type dt
        on r.default_type_id = dt.default_type_id

)

select * from final
