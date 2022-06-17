
{{
  config(
    materialized="view",
  )
}}

with labelled as (
  {{ eaupot_canalisations_labelled(ref('eaupot_src_canalisations_translated')) }}
)
select * from labelled