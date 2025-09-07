WITH stg_store AS (
  SELECT
    business_entity_id AS store_id,
    store_name
  FROM {{ ref('stg_sales_store') }}
),

stg_store_addresses AS (
  SELECT
    business_entity_id,
    address_line_1,
    city,
    state_province_name,
    postal_code,
    country_region_name
  FROM {{ ref('stg_sales_storewithaddresses')}}
)

SELECT
  stg_store.store_id,
  stg_store.store_name,
  stg_store_addresses.address_line_1,
  stg_store_addresses.city,
  stg_store_addresses.state_province_name,
  stg_store_addresses.postal_code,
  stg_store_addresses.country_region_name
FROM stg_store
LEFT JOIN stg_store_addresses
  ON stg_store.store_id = stg_store_addresses.business_entity_id