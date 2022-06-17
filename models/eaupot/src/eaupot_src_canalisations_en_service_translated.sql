{#
Fully translated, indexed
#}


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

with canalisations_en_service as (
  {{ eaupot_canalisations_en_service_translated(ref('eaupot_src_canalisations_en_service_parsed')) }}
), canalisations_abandonnees as (
  {{ eaupot_canalisations_en_service_translated(ref('eaupot_src_canalisations_abandonnees_parsed')) }}
)
select * from canalisations_en_service
UNION
select * from canalisations_abandonnees

{# MISSING eaupot_canalisations_en_service_translated()
{ dbt_utils.union_relations(relations=[
        ref('eaupot_src_canalisations_en_service_parsed'),
        ref('eaupot_src_canalisations_abandonnees_parsed')
    ],
    source_column_name=None,
    column_override={"geometrie": "geometry"},)
}}
#}