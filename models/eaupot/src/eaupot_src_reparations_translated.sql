{#
Fully translated, indexed
en service ET abandonnées (données et champs)
#}


{% set fieldPrefix = 'eaupotrep_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="table",
    indexes=[{'columns': ['"' + fieldPrefix + 'idReparation"']},
      {'columns': order_by_fields},
      ]
  )
}}

with translated as (
  {{ eaupot_reparations_translated(ref('eaupot_src_reparations_parsed')) }}
)
select * from translated