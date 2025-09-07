-- models/marts/fact_demand_forecast_weekly.sql
-- Grain: 1 linha por (order_date, product_id, territory_id)
-- Ajuste: remover dependência da dim_date p/ ano/mês/semana e derivar direto de order_date.
-- Compatível com Spark/Databricks, Postgres e similares (funções padrão).

with orders as (
    select
        cast(order_date as date)                                  as order_date,
        order_id,
        cast(product_id as int)                                   as product_id,
        cast(territory_id as int)                                 as territory_id,
        greatest(coalesce(order_quantity, 0), 0)                  as order_quantity,
        coalesce(is_online_order, false)                          as is_online_order,
        coalesce(gross_revenue_usd, 0.0)                          as gross_revenue_usd
    from {{ ref('fact_sales_order') }}
),

products as (
    select
        cast(product_id as int)       as product_id,
        coalesce(product_name, 'N/A') as product_name,
        product_line,
        product_class,
        product_style
    from {{ ref('dim_product') }}
),

territories as (
    select
        cast(territory_id as int)       as territory_id,
        coalesce(territory_name, 'N/A') as territory_name,
        coalesce(country_region_code,'N/A') as country_region_code
    from {{ ref('dim_territory') }}
),

/* 🔧 NOVO: derivar calendário direto de order_date (sem dim_date) */
orders_with_calendar as (
    select
        o.*,
        -- campos de calendário derivados
        year(o.order_date)                                   as year,
        month(o.order_date)                                  as month,
        quarter(o.order_date)                                as quarter,
        /* dayofweek: em Spark 1=Domingo..7=Sábado; ajuste a leitura se precisar */
        dayofweek(o.order_date)                              as day_of_week,
        case when dayofweek(o.order_date) in (1,7) then true else false end as is_weekend,
        weekofyear(o.order_date)                             as week_of_year,
        date_trunc('week', o.order_date)                     as week_start_date,
        last_day(o.order_date)                               as month_end_date
    from orders o
),

joined as (
    select
        oc.order_date,
        oc.order_id,

        oc.product_id,
        p.product_name,
        p.product_line,
        p.product_class,
        p.product_style,

        oc.territory_id,
        t.territory_name,
        t.country_region_code,

        -- calendário derivado
        oc.year,
        oc.month,
        oc.quarter,
        oc.day_of_week,
        oc.is_weekend,
        oc.week_of_year,
        oc.week_start_date,
        oc.month_end_date,

        -- medidas
        oc.order_quantity,
        oc.is_online_order,
        oc.gross_revenue_usd
    from orders_with_calendar oc
    left join products    p on oc.product_id   = p.product_id
    left join territories t on oc.territory_id = t.territory_id
),

aggregated as (
    select
        order_date,
        product_id,
        product_name,
        product_line,
        product_class,
        product_style,

        territory_id,
        territory_name,
        country_region_code,

        year,
        month,
        quarter,
        day_of_week,
        is_weekend,

        week_of_year,
        week_start_date,
        month_end_date,

        sum(order_quantity)          as total_items_sold,
        count(distinct order_id)     as total_orders,
        sum(gross_revenue_usd)       as total_gross_revenue,
        bool_or(is_online_order)     as any_online_order
    from joined
    where order_date is not null
      and product_id is not null
      and territory_id is not null
    group by
        order_date,
        product_id,
        product_name,
        product_line,
        product_class,
        product_style,
        territory_id,
        territory_name,
        country_region_code,
        year,
        month,
        quarter,
        day_of_week,
        is_weekend,
        week_of_year,
        week_start_date,
        month_end_date
)

select *
from aggregated
order by order_date, product_id, territory_id;
