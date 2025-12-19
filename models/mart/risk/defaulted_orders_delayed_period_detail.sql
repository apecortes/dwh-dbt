{{ config(materialized = 'table') }}

-- Final mart for Risk monitoring purposes.
-- This model exposes a detailed, non-aggregated dataset of defaulted orders
-- expanded by delayed period. It is intended for monitoring and analysis,
-- not for aggregation.

with orders_delayed_periods as (

    select
        order_delayed_period_id,
        order_id,
        shopper_id,
        merchant_id,
        product_id,
        default_type_name,
        delayed_period,
        order_date

    from {{ ref('int_orders_delayed_periods') }}

),

shoppers as (

    select
        shopper_id,
        shopper_age
    from {{ ref('int_shopper') }}

),

products as (

    select
        product_id,
        product_name
    from {{ ref('int_product') }}

),

merchants as (

    select
        merchant_id,
        merchant_name
    from {{ ref('int_merchant') }}

),

final as (

    select
        s.shopper_age,
        format_date('%Y-%m', odp.order_date) as month_year_order,
        p.product_name as product,
        m.merchant_name as merchant,
        odp.default_type_name as default_type,
        odp.delayed_period
    from orders_delayed_periods odp
    left join shoppers s
        on odp.shopper_id = s.shopper_id
    left join products p
        on odp.product_id = p.product_id
    left join merchants m
        on odp.merchant_id = m.merchant_id

)

select * from final
