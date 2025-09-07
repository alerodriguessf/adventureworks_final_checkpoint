with source as (
    select * 
    from {{ source('databricks_dw_aw', 'raw_sqlserver_sales_store_db') }}
),

revised as (

    select
        Name as store_name
        , BusinessEntityID as business_entity_id
        , rowguid as row_guid
        , ModifiedDate as modified_date 

    from source
)

select * from revised