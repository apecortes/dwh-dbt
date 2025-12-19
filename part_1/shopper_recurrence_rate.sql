-- ============================================================
-- PART I - Data Extraction (SQL)
-- ============================================================

with orders as (

    select
        order_id,
        shopper_id,
        merchant_id,
        date(order_date) as order_date

    from `sequra-dwh.source_one.orders`
    where date(order_date) < date_trunc(current_date(), month)

),

merchants as (

    select
        merchant_id,
        merchant_name

    from `sequra-dwh.source_one.merchant`

),

orders_with_previous_order as (

    select
        *,
        date_trunc(order_date, month) as order_month,
        date_trunc(
            lag(order_date) over (
                partition by shopper_id, merchant_id
                order by order_date
            ),
            month
        ) as previous_order_month

    from orders

),

orders_with_recurrence_flag as (

    select
        *,
        case
            when date_diff(order_month, previous_order_month, month) <= 11
                then true
            else false
        end as is_recurrent_order

    from orders_with_previous_order

),

aggregated_metrics as (

    select
        m.merchant_name,
        order_month,
        count(distinct shopper_id) as total_shoppers,
        count(distinct
            case
                when is_recurrent_order then shopper_id
                else null
            end) as recurrent_shoppers

    from orders_with_recurrence_flag f
    left join merchants m
        on f.merchant_id = m.merchant_id
    group by merchant_name, order_month

)

select
    merchant_name,
    order_month as month,
    round(
        safe_divide(recurrent_shoppers, total_shoppers),
        2
    ) as recurrence_rate

from aggregated_metrics
order by merchant_name, month
