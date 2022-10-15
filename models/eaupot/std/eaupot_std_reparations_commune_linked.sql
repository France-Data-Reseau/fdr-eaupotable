{#
Produces the table (materialized because computes) of the n-n relationship between eaupotrep and commune,
materialized as DBT incremental (filtered on eaupot_std_reparations_unified last_changed)

time : TODO
#}

{% set fieldPrefix = 'eaupotrep' + '_' %}

{{
  config(
    materialized="incremental",
    unique_key=['"' + fieldPrefix + "id" + '"', 'com_code'],
    tags=["incremental", "long"],
    indexes=[
      {'columns': ['"' + fieldPrefix + 'id"']},
      {'columns': ['com_code']},
    ]
  )
}}

{% set source_model = ref('eaupot_std_reparations_unified') %}

{{ fdr_francedatareseau.fdr_2phase1link_commune_geometry(source_model,
    id_field=fieldPrefix + "id", geometry_field="geometrie", srid="2154") }}
