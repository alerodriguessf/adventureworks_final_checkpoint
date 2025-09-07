with source as (
    select * 
    from {{ source('databricks_dw_aw', 'raw_sqlserver_sales_vstorewithaddresses_db') }}
),

revised as (

    select
        BusinessEntityID as business_entity_id
        , Name as store_name
        , AddressType as address_type
        , AddressLine1 as address_line_1
        , AddressLine2 as address_line_2
        , City as city
        , StateProvinceName as state_province_name
        , PostalCode as postal_code
        , CountryRegionName as country_region_name
    from source
)

select * from revised