{#
Fully translated, indexed
en service ET abandonnées (données et champs)

#}


{% set fieldPrefix = 'eaupotcan_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="view",
  )
}}

with canalisations_en_service as (
  {{ eaupot_canalisations_translated(ref('eaupot_src_canalisations_en_service_parsed')) }}
), canalisations_en_service_dict as (
  {{ eaupot_canalisations_translated(ref('eaupot_src_canalisations_en_service_dict_parsed')) }}
), canalisations_abandonnees as (
  {{ eaupot_canalisations_translated(ref('eaupot_src_canalisations_abandonnees_parsed')) }}
), canalisations_abandonnees_dict as (
  {{ eaupot_canalisations_translated(ref('eaupot_src_canalisations_abandonnees_dict_parsed')) }}

), unioned as (
select * from canalisations_en_service
UNION ALL -- without ALL removes duplicates lines according to the columns of the first column statement !
select * from canalisations_en_service_dict
UNION ALL -- without ALL removes duplicates lines according to the columns of the first column statement !
select * from canalisations_abandonnees
UNION ALL -- without ALL removes duplicates lines according to the columns of the first column statement !
select * from canalisations_abandonnees_dict

{# 60s, but will mostly not solve the Grand Annecy duplicate problem (several identical except for material ex. 18, 00 Indéterminée)
), geometry_deduped as (
    {{ fdr_francedatareseau.dedupe('unioned', id_fields=['"geometrie"']) }}
#}
)
select * from unioned

{# MISSING eaupot_canalisations_en_service_translated()
{ dbt_utils.union_relations(relations=[
        ref('eaupot_src_canalisations_en_service_parsed'),
        ref('eaupot_src_canalisations_en_service_dict_parsed'),
        ref('eaupot_src_canalisations_abandonnees_parsed'),
        ref('eaupot_src_canalisations_abandonnees_dict_parsed')
    ],
    source_column_name=None,
    column_override={"geometrie": "geometry"},)
}}
#}
