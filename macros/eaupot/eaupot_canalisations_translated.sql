{#
Normalisation vers le modèle de données
à appliquer après le spécifique _from_csv, ou après le générique from_csv guidé par le modèle produit par _from_csv,
qui, eux, gèrent renommage et parsing générique
en service ET abandonnées (données et champs)

TODO dire lenient, errors

TODO :
- accepter en parsing lenient / souple ou pas de la part des collectivités ?? (ou les aide à corriger avec quelle info)
- uuid ?? OUI pbs : idCanalisation
   - (idCanalisation : pas unique donc rendu unique en rajoutant src_id ; ou par uuid ? (certains le sont déjà !))
   - est text dans le modèle du jdb,
   - et pas unique entre les sources => préfixer par par _src_name le _src_id
- !!! EN DEHORS de ceux de standards réutilisés (tel ici le Géostandard RAEPA), les codes devraient être lisibles / sémantiquement significatif ! (de plus cela éviterait certains typés int4 où manque un zéro en tête)
  - ex. âme tôle => ame_tole
  - Alias : sert à unifier 2 valeurs en une
- 5 ENUM : mauvais, à interdire (ou interpréter comme codes) !! heureusement dans les données ce n'en est pas, mais hélas soit des int sans sémantique (dans certains cas typés en varchar, notamment les source* dans ...19)
  - = liste fermée et non ENUM SQL
- code : liste ouverte NON...
  - (NB. dans LibreOffice, attention, les zéros en tête du Code disparaissent)
- + colonnes valeurs source en text, pour aider debug erreurs
- (patch ogr2ogr to be able to quote columns !)
- RAEPA : format pas clair, table externe ou json ou champs ? :
  - normalement une table externe (mais requiert FDR_SOURCE_NOM !)
  - les champs source* sont déjà des métadonnées RAEPA,
  - et le plus simple est pareil de rajouter des champs raepa_*
- le ...19 (Grand Annecy) a :
  - des "geometrie" varchar Line, mais le bon type dans "geom" ?! => détecter le type ??
  - des dates 2999-12-31 01:00:00.000 +0100, pour NULL ? mais anposeinf est fourni NULL...
  - les source* en int4 donc (et non text), et donc dans certains manque un zéro en tête

- OUI OU à chaque fois pour plus de concision et lisibilité select * (les champs en trop sont alors enlevés à la fin par la __definition) ?
#}

{% macro eaupot_canalisations_translated(parsed_source_relation, src_priority=None) %}

{% set modelVersion ='_v3' %}

{% set containerUrl = 'http://' + 'datalake.francedatareseau.fr' %}
{% set typeUrlPrefix = containerUrl + '/dc/type/' %}
{% set type = 'eaupotable_canalisation_raw/nativesrc_extract' %} -- spécifique à la source ; _2021 ? from this file ? prefix:typeName ?
{% set type = 'eaupotable_canalisation' %} -- _2021 ? from this file ? prefix:typeName ?
{% set ns = 'canalisation.eaupotable.francedatareseau.fr' %} -- ?
{% set typeName = 'Canalisation' %}
{% set sourcePrefix = 'osmposup' %} -- ?
{% set prefix = 'eaupotcan' %} -- ?
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
            fieldPrefix + 'idCanalisation',
            fieldPrefix + 'materiau',
            fieldPrefix + 'modeCirculation',
            fieldPrefix + 'qualiteGeolocalisation',
            fieldPrefix + 'sourceMateriau',
            fieldPrefix + 'sourceDiametreNomin',
            fieldPrefix + 'sourceDatePose',
            fieldPrefix + 'sourceDateAbandon']) }},

        "{{ fieldPrefix }}idCanalisation" as "{{ fieldPrefix }}src_id", -- 50337, 1645f993-f749-4e6f-acd8-46045ea408bf ; ID_2725 ; TODO Q uuid ? ; source own id

        -- pad with leading zeroes :
        LPAD("{{ fieldPrefix }}materiau", 2, '0') as "{{ fieldPrefix }}materiau", -- NB. if int would be : TO_CHAR("{{ fieldPrefix }}materiau", 'fm000')
        LPAD("{{ fieldPrefix }}modeCirculation", 2, '0') as "{{ fieldPrefix }}modeCirculation",
        LPAD("{{ fieldPrefix }}qualiteGeolocalisation", 2, '0') as "{{ fieldPrefix }}qualiteGeolocalisation",
        -- dont pris de métadonnées RAEPA :
        LPAD("{{ fieldPrefix }}sourceMateriau", 2, '0') as "{{ fieldPrefix }}sourceMateriau",
        LPAD("{{ fieldPrefix }}sourceDiametreNomin", 2, '0') as "{{ fieldPrefix }}sourceDiametreNomin",
        LPAD("{{ fieldPrefix }}sourceDatePose", 2, '0') as "{{ fieldPrefix }}sourceDatePose",
        LPAD("{{ fieldPrefix }}sourceDateAbandon", 2, '0') as "{{ fieldPrefix }}sourceDateAbandon"

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
        "{{ fieldPrefix }}src_name" || '_' || "{{ fieldPrefix }}src_id" as "{{ fieldPrefix }}idCanalisation"

    from src_renamed

), computed as (

    select
        *,

        uuid_generate_v5(uuid_generate_v5(uuid_ns_dns(), '{{ ns }}}}'), "{{ fieldPrefix }}src_id") as "{{ fieldPrefix }}uuid" -- in case of uuid
        --ST_GeomFROMText('POINT(' || cast("X" as text) || ' ' || cast("Y" as text) || ')', 4326) as geometry, -- OU prefix ? forme ?? ou /et "Geom" ? TODO LATER s'en servir pour réconcilier si < 5m

    from src_computed

)

select * from computed

{% endmacro %}