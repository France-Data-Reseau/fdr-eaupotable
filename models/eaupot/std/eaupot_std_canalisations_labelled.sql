
{{
  config(
    materialized="view",
  )
}}

select * from {{ ref('eaupot_std_canalisations_unified') }}