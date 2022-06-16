
{{
  config(
    materialized="view",
  )
}}

with a as (
  {{ eaupot_canalisations_en_service_labelled(ref('eaupot_src_canalisations_en_service_translated')) }}
)
select * from a