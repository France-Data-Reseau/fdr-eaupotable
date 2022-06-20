{#

#}

{% macro eaupot_reparations_labelled(translated_source_relation) %}

{% set modelVersion ='_v3' %}

{% set fieldPrefix = 'eaupotrep_' %}

with translated as (

    select * from {{ translated_source_relation }}
    {% if var('limit', 0) > 0 %}
    LIMIT {{ var('limit') }}
    {% endif %}

), labelled as (

    select
        translated.*,

        "data_owner_label" as "{{ fieldPrefix }}data_owner_label", -- TODO org_title ; OR data_owner_id becomes org_business_id or SIREN ??

        geol."Valeur" as "{{ fieldPrefix }}qualiteGeolocalisation_label",
        mat."Valeur" as "{{ fieldPrefix }}materiau_label",
        empl."Valeur" as "{{ fieldPrefix }}emplacement_label",
        type."Valeur" as "{{ fieldPrefix }}type_label",
        cause."Valeur" as "{{ fieldPrefix }}causeProbable_label"

    from translated

        left join {{ ref('eaupot_def_l_canalisations_qualiteGeolocalisation' + modelVersion) }} geol -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}qualiteGeolocalisation" = geol."Code"
        left join {{ ref('eaupot_def_l_canalisations_materiau' + modelVersion) }} mat -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}materiau" = mat."Code"
        left join {{ ref('eaupot_def_l_reparations_emplacement' + modelVersion) }} empl -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}emplacement" = empl."Code"
        left join {{ ref('eaupot_def_l_reparations_type' + modelVersion) }} type -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}type" = type."Code"
        left join {{ ref('eaupot_def_l_reparations_causeProbable' + modelVersion) }} cause -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}causeProbable" = cause."Code"

)

select * from labelled

{% endmacro %}