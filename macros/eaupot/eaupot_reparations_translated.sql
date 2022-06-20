{#
Normalisation vers le modèle de données
à appliquer après le spécifique _from_csv, ou après le générique from_csv guidé par le modèle produit par _from_csv,
qui, eux, gèrent renommage et parsing générique
en service ET abandonnées (données et champs)

voir eaupot_canalisations_translated

- OUI OU à chaque fois pour plus de concision et lisibilité select * (les champs en trop sont alors enlevés à la fin par la __definition) ?
#}

{% macro eaupot_reparations_translated(parsed_source_relation, src_priority=None) %}

{% set modelVersion ='_v3' %}

{% set containerUrl = 'http://' + 'datalake.francedatareseau.fr' %}
{% set typeUrlPrefix = containerUrl + '/dc/type/' %}
{% set type = 'eaupotable_reparation_raw/nativesrc_extract' %} -- spécifique à la source ; _2021 ? from this file ? prefix:typeName ?
{% set type = 'eaupotable_repasation' %} -- _2021 ? from this file ? prefix:typeName ?
{% set ns = 'reparation.eaupotable.francedatareseau.fr' %} -- ?
{% set typeName = 'Reparation' %}
{% set sourcePrefix = 'osmposup' %} -- ?
{% set prefix = 'eaupotrep' %} -- ?
{% set sourceFieldPrefix = sourcePrefix + ':' %}
{% set sourceFieldPrefix = sourcePrefix + '_' %}
{% set fieldPrefix = prefix + ':' %}
{% set fieldPrefix = prefix + '_' %}
{% set idUrlPrefix = typeUrlPrefix + type + '/' %}

with import_parsed as (

    select * from {{ parsed_source_relation }}
    {% if var('limit', 0) > 0 %}
    LIMIT {{ var('limit') }}
    {% endif %}

{#
rename and generic parsing is rather done
- in specific _from_csv
- in generic from_csv (called by fdr_source_union), which is guided by the previous one
#}

), specific_parsed as (

    -- handle official "echange" fields that are not fully perfect :
    select
        --*,
        {{ dbt_utils.star(parsed_source_relation, except=[
            fieldPrefix + 'idReparation',
            fieldPrefix + 'qualiteGeolocalisation',
            fieldPrefix + 'materiau',
            fieldPrefix + 'emplacement',
            fieldPrefix + 'type',
            fieldPrefix + 'causeProbable']) }},

        "{{ fieldPrefix }}idReparation" as "{{ fieldPrefix }}src_id", -- 20181219135200_dsire3m (intervenant ?!), 1645f993-f749-4e6f-acd8-46045ea408bf ; ID_2725 ; TODO Q uuid ? ; source own id

        -- pad with leading zeroes :
        LPAD("{{ fieldPrefix }}qualiteGeolocalisation", 2, '0') as "{{ fieldPrefix }}qualiteGeolocalisation",
        LPAD("{{ fieldPrefix }}materiau", 2, '0') as "{{ fieldPrefix }}materiau", -- NB. if int would be : TO_CHAR("{{ fieldPrefix }}materiau", 'fm000')
        LPAD("{{ fieldPrefix }}emplacement", 2, '0') as "{{ fieldPrefix }}emplacement",
        LPAD("{{ fieldPrefix }}type", 2, '0') as "{{ fieldPrefix }}type",
        LPAD("{{ fieldPrefix }}causeProbable", 2, '0') as "{{ fieldPrefix }}causeProbable"

    from import_parsed

), src_renamed as (

    select
        *,

        --'{{ parsed_source_relation }}' as "{{ fieldPrefix }}src_name", -- source name, for src_id (with data_owner_id) and _priority (else won't have it anymore once unified with other sources)
        "FDR_SOURCE_NOM" as "{{ fieldPrefix }}src_kind", -- source kind / type, for src_id (with data_owner_id) and _priority (else won't have it anymore once unified with other sources)
        "FDR_SOURCE_NOM" || '_' || data_owner_id as "{{ fieldPrefix }}src_name", -- source name, for src_id (else won't have it anymore once unified with other sources)
        import_table as "{{ fieldPrefix }}src_table" -- (bonus)
        --id as "{{ fieldPrefix }}src_index", -- index in source

    from specific_parsed

), src_computed as (

    select
        *,

        {% if src_priority %}'{{ src_priority }}_' || {% endif %}"{{ fieldPrefix }}src_name" as "{{ fieldPrefix }}src_priority",  -- 0 is highest, then 10, 100, 1000... src_name added to differenciate
        "{{ fieldPrefix }}src_name" || '_' || "{{ fieldPrefix }}src_id" as "{{ fieldPrefix }}id" -- overall unique id

    from src_renamed

), computed as (

    select
        *,

        "{{ fieldPrefix }}id" as "{{ fieldPrefix }}idReparation",
        uuid_generate_v5(uuid_generate_v5(uuid_ns_dns(), '{{ ns }}}}'), "{{ fieldPrefix }}id") as "{{ fieldPrefix }}uuid" -- in case of uuid
        --ST_GeomFROMText('POINT(' || cast("X" as text) || ' ' || cast("Y" as text) || ')', 4326) as geometry, -- OU prefix ? forme ?? ou /et "Geom" ? TODO LATER s'en servir pour réconcilier si < 5m

    from src_computed

)

select * from computed

{% endmacro %}