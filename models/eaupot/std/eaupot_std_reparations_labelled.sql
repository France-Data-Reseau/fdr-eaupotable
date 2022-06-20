
{{
  config(
    materialized="view",
  )
}}

with labelled as (
  {{ eaupot_reparations_labelled(ref('eaupot_src_reparations_translated')) }}
)
select * from labelled