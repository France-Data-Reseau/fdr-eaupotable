
{% set fieldPrefix = 'eaupotcan_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="table",
    indexes=[{'columns': ['"' + fieldPrefix + 'idCanalisation"']},
      {'columns': order_by_fields},
      ]
  )
}}

with a as (
  {{ eaupot_canalisations_en_service_translated(ref('eaupot_src_canalisations_en_service_parsed')) }}
)
select * from a