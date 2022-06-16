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
{{ eaupot_canalisations_en_service_from_csv(ref(model.name[:-4])) }}
#}

{% macro eaupot_canalisations_en_service_from_csv(source_model=ref(model.name | replace('_stg', ''))) %}

{% set fieldPrefix = 'eaupotcan_' %}
{% set def_model = ref('eaupot_def_canalisations_en_service_lower_example') %}{# NOT USED #}
{% set source_relation = source_model %}{# TODO rename #}
{% set source_alias = None %}{# 'source' TODO rename #}

select

       {#
       listing all fields for doc purpose, and not only those having to be transformed using {{ dbt_utils.star(def_model, except=[...
       because this is the actual definition of the standardized "echange" format
       #}

        ---- TODO '{{ source_relation }}' as "{{ fieldPrefix }}src_name", -- source name (else won't have it anymore once unified with other sources)
        --id as "{{ fieldPrefix }}src_index", -- index in source
        ---- TODO "idCanalisation"::text as "{{ fieldPrefix }}src_id", -- 50337, 1645f993-f749-4e6f-acd8-46045ea408bf ; ID_2725 ; TODO Q uuid ? ; source own id
        "idCanalisation"::text as "{{ fieldPrefix }}idCanalisation", -- 50337, 1645f993-f749-4e6f-acd8-46045ea408bf ; ID_2725 ; TODO Q uuid ? ; source own id
        ST_GeomFROMText("geometrie", 4326) as "geometrie", -- geometrie as "geometrie", -- Line, required
        materiau::text as "{{ fieldPrefix }}materiau", -- 18, 11, FG ; Fonte grise (LABEL !), required
        {{ fdr_appuiscommuns.to_numeric_or_null('diametreNominal', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}diametreNominal", -- TODO int (selon que pour test ou translate ?) ; 200, int
        {{ fdr_appuiscommuns.to_date_or_null('datePose', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}datePose", -- 2021-05-25 ; AAAA-mm-jj
        "maitreOuvrage"::text as "{{ fieldPrefix }}maitreOuvrage", -- 74176, MMM ; required
        exploitant::text as "{{ fieldPrefix }}exploitant", -- GRAND ANNECY, NULL ; required
        {{ fdr_appuiscommuns.to_boolean_or_null('enService', source_relation, source_alias) }} as "{{ fieldPrefix }}enService", -- bool or 1 int4 ; required
        {{ fdr_appuiscommuns.to_boolean_or_null('branchement', source_relation, source_alias) }} as "{{ fieldPrefix }}branchement", -- bool or 1 int4 ; required
        "modeCirculation" as "{{ fieldPrefix }}modeCirculation", -- ENUM TODO PAS BIEN ! ; Gravitaire, required
        {{ fdr_appuiscommuns.to_date_or_null('anPoseInf', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}anPoseInf", -- 1925-01-01 ; AAAA-mm-jj
        {{ fdr_appuiscommuns.to_date_or_null('anPoseSup', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}anPoseSup", -- 1936-01-01 ; AAAA-mm-jj
        {{ fdr_appuiscommuns.to_numeric_or_null('longueur', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}longueur", -- 31.47597935 ; 15.29, float
        "metaRAEPA" as "{{ fieldPrefix }}metaRAEPA", -- TODO pas fournies, format ? (jons, ou plutôt en champs ?)
        "qualiteGeolocalisation" as "{{ fieldPrefix }}qualiteGeolocalisation", -- ENUM TODO PAS BIEN ! ; Classe A, required
        "sourceMateriau" as "{{ fieldPrefix }}sourceMateriau", -- ENUM TODO PAS BIEN ! ; Mémoire, required
        "sourceDiametreNomin" as "{{ fieldPrefix }}sourceDiametreNomin", -- ENUM TODO PAS BIEN ! ; Récolement, required
        "sourceDatePose" as "{{ fieldPrefix }}sourceDatePose" -- ENUM TODO PAS BIEN ! ; Récolement, required

    from {{ source_model }}

{% endmacro %}