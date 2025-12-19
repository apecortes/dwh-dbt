{{ config(materialized = 'table') }}

with orders_in_default as (

    select
        order_id,
        shopper_id,
        merchant_id,
        product_id,
        days_unbalanced,
        default_type_name,
        order_date

    from {{ ref('int_orders') }}
    where is_in_default is true

),

delayed_periods as (

    -- delayed periods are modeled as a dbt seed for simplicity
    -- this represents a static business configuration that could
    -- be materialized as a table in a production environment
    select
        delayed_period

    from {{ ref('delayed_periods') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'o.order_id',
            'o.shopper_id',
            'o.merchant_id',
            'o.product_id',
            'd.delayed_period'
        ]) }} as order_delayed_period_id,
        o.order_id,
        o.shopper_id,
        o.merchant_id,
        o.product_id,

        o.days_unbalanced,
        o.default_type_name,
        d.delayed_period,

        o.order_date

    from orders_in_default o
    cross join delayed_periods d
    where d.delayed_period <= o.days_unbalanced

)

select * from final
