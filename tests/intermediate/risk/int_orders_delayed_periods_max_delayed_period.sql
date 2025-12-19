-- This test validates that the maximum delayed_period generated for each order
-- does not exceed the days_unbalanced value from the original order.
-- If this query returns rows, the test will fail.

with orders_delayed_periods as (

    select * from {{ ref('int_orders_delayed_periods') }}

),

max_delayed_period_per_order as (

    select
        order_id,
        days_unbalanced,
        max(delayed_period) as max_delayed_period

    from orders_delayed_periods
    group by
        order_id,
        days_unbalanced

)

select * from max_delayed_period_per_order
where max_delayed_period > days_unbalanced
