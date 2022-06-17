{#
Generically parsed
#}

{{
  config(
    materialized="view",
  )
}}

{% set use_case_prefix = 'eaupot' %}
{% set FDR_SOURCE_NOM = this.name | replace(use_case_prefix ~ '_src_', '') | replace('_parsed', '') | replace('_dict', '') %}
{% set has_dictionnaire_champs_valeurs = this.name.endswith('_dict') %}

{{ fdr_appuiscommuns.fdr_source_union_from_name(FDR_SOURCE_NOM,
    has_dictionnaire_champs_valeurs,
    this,
    translated_macro=eaupot_canalisations_en_service_translated,
    def_model=ref('eaupot_def_canalisations_en_service_definition')) }}