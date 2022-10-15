
{{
  config(
    materialized="view",
  )
}}

select * from {{ ref('eaupot_std_reparations_unified') }}