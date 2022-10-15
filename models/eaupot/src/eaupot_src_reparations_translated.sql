{#
Fully translated, indexed
en service ET abandonnées (données et champs)

#}


{% set fieldPrefix = 'eaupotrep_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="view",
  )
}}

with translated as (
  {{ eaupot_reparations_translated(ref('eaupot_src_reparations_parsed')) }}
), translated_dict as (
  {{ eaupot_reparations_translated(ref('eaupot_src_reparations_dict_parsed')) }}

), unioned as (
select * from translated
UNION ALL -- without ALL removes duplicates lines according to the columns of the first column statement !
select * from translated_dict

), labelled as (
  {{ eaupot_reparations_labelled('unioned') }}
)
select * from labelled