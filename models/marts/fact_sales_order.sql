with order_detail as (
    select *
    from {{ ref('stg_sales_order_detail') }}
),

order_header as (
    select *
    from {{ ref('stg_sales_order_header') }}
),

currency_rate as (
    select *
    from {{ ref('stg_sales_currency_rate') }}
),

joined as (
    select
        -- IDs principais
        od.order_id
        , od.order_detail_id

        -- Produto e oferta
        , od.product_id

        -- Cliente e vendedor
        , oh.customer_id
        , oh.sales_person_id
        , oh.territory_id

        -- Datas relevantes
        , oh.order_date
        , oh.due_date
        , oh.ship_date

        -- Informações de envio e pagamento
        , oh.ship_method_id
        , oh.currency_rate_id

        -- Quantidade e preço originais
        , od.order_quantity
        , od.unit_price
        , od.unit_price_discount
        , od.line_total

        -- Valor convertido para USD (se tiver currency_rate, multiplica; se não, já está em USD)
        , case 
            when oh.currency_rate_id is not null 
                 then od.unit_price * cr.average_rate
            else od.unit_price
          end as unit_price_usd

        -- Receita bruta ajustada em USD (segue mesma lógica)
        , case 
            when oh.currency_rate_id is not null 
                 then od.order_quantity * (od.unit_price * cr.average_rate) * (1 - od.unit_price_discount)
            else od.order_quantity * od.unit_price * (1 - od.unit_price_discount)
          end as gross_revenue_usd

        -- Receita bruta ajustada original (sem considerar impostos ou frete)
        , (od.order_quantity * od.unit_price * (1 - od.unit_price_discount)) as gross_revenue

        -- Flags e rastreabilidade
        , oh.is_online_order
        , current_timestamp() as ingestion_timestamp

    from order_detail od
    left join order_header oh
        on od.order_id = oh.order_id
    left join currency_rate cr
        on oh.currency_rate_id = cr.currency_rate_id
)

select *
from joined
