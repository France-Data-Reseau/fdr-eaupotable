{#

TODO USED to produce definition ! as well as parse  tests.

Parsing of
- sources that are directly in the apcom types
- a priori (made-up), covering examples of the definition / interface.
- test _expected
Examples have to be **as representative** of all possible data as possible because they are also the basis of the definition.
For instance, for a commune INSEE id field, they should also include a non-integer value such as 2A035 (Belvédère-Campomoro).
Methodology :
1. copy the first line(s) from the specification document
2. add line(s) to contain further values for until they are covering for all columns
3. NB. examples specific to each source type are provided in _source_example along their implementation (for which they are covering)

TODO or _parsed, _definition_ ?
TODO can't be replaced by generic from_csv because is the actual definition, BUT could instead be by guided by metamodel !
{{ eaupot_reparations_from_csv(ref(model.name[:-4])) }}
#}

{% macro eaupot_reparations_from_csv(source_model=ref(model.name | replace('_stg', ''))) %}

{% set fieldPrefix = var('use_case_prefix') + 'rep_' %}
{% set source_relation = source_model %}{# TODO rename #}
{% set source_alias = None %}{# 'source' TODO rename #}

select

       {#
       listing all fields for doc purpose, and not only those having to be transformed using {{ dbt_utils.star(def_model, except=[...
       because this is the actual definition of the standardized "echange" format
       #}

        ---- TODO '{{ source_relation }}' as "{{ fieldPrefix }}src_name", -- source name (else won't have it anymore once unified with other sources)
        --id as "{{ fieldPrefix }}src_index", -- index in source
        "idReparation"::text as "{{ fieldPrefix }}idReparation", --  ; 20181219135200_dsire3m, c1528e18-e993-42ee-b812-990f7f84018c ; ID_D981 ; TODO Q uuid ? ; source own id ; required
        ST_GeomFROMText("geometrie", 2154) as "geometrie", -- geometrie as "geometrie", -- Point, required
        "supportIncident"::text as "{{ fieldPrefix }}supportIncident", --  ; 6823, 6e8e4623-0788-49d5-bad8-5d3071103922 ; ID_C617 ; source own id of canalisations
        {{ fdr_appuiscommuns.to_date_or_null('dateIntervention', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}dateIntervention", -- 2014-03-19 ; AAAA-mm-jj
        "qualiteGeolocalisation"::text as "{{ fieldPrefix }}qualiteGeolocalisation", -- 02 Classe A, required
        materiau::text as "{{ fieldPrefix }}materiau", -- 18, 11, FG ; Fonte grise (LABEL !), required ; TODO PAS liste ouverte comme le suggère "code" plutôt que "ENUM"
        {{ fdr_appuiscommuns.to_numeric_or_null('diametreNominal', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}diametreNominal", -- TODO int (selon que pour test ou translate ?) ; 200, int
        {{ fdr_appuiscommuns.to_date_or_null('datePose', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}datePose", -- 2000-01-01 ; AAAA-mm-jj
        "emplacement"::text as "{{ fieldPrefix }}emplacement", -- 02 Canalisation, required
        "type"::text as "{{ fieldPrefix }}type", -- 02 Casse nette, required
        "causeProbable"::text as "{{ fieldPrefix }}causeProbable" -- 08 Tiers, required

    from {{ source_model }}

{% endmacro %}