-- This test validates that the maximum delayed_period generated for each order
-- does not exceed the days_unbalanced value from the original order.
-- If this query returns rows, the test will fail.

with max_delayed_period_per_order as (

    select
        order_id,
        shopper_id,
        merchant_id,
        product_id,
        max(delayed_period) as max_delayed_period

    from {{ ref('int_orders_delayed_periods') }}
    group by
        order_id,
        shopper_id,
        merchant_id,
        product_id

),

orders_days_unbalanced as (

    select
        order_id,
        shopper_id,
        merchant_id,
        product_id,
        days_unbalanced

    from {{ ref('int_orders') }}

)

select
    m.order_id,
    m.shopper_id,
    m.merchant_id,
    m.product_id,
    m.max_delayed_period,
    o.days_unbalanced

from max_delayed_period_per_order m
join orders_days_unbalanced o
    on m.order_id = o.order_id
   and m.shopper_id = o.shopper_id
   and m.merchant_id = o.merchant_id
   and m.product_id = o.product_id
where m.max_delayed_period > o.days_unbalanced
