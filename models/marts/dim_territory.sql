with base as (
    select 
        territory_id
        , territory_name
        , territory_group
        , country_region_code
    from {{ ref('stg_sales_territory') }}
)

select * from base