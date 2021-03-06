{#

#}

{% macro eaupot_canalisations_labelled(translated_source_relation) %}

{% set modelVersion ='_v3' %}

{% set fieldPrefix = var('use_case_prefix') + 'can_' %}

with translated as (

    select * from {{ translated_source_relation }}
    {% if var('limit', 0) > 0 %}
    LIMIT {{ var('limit') }}
    {% endif %}

), labelled as (

    select
        translated.*,

        "data_owner_label" as "{{ fieldPrefix }}data_owner_label", -- TODO org_title ; OR data_owner_id becomes org_business_id or SIREN ??

        mat."Valeur" as "{{ fieldPrefix }}materiau_label",
        circ."Valeur" as "{{ fieldPrefix }}modeCirculation_label",
        geol."Valeur" as "{{ fieldPrefix }}qualiteGeolocalisation_label",
        source_mat."Champs" as "{{ fieldPrefix }}sourceMateriau_label",
        source_diam."Champs" as "{{ fieldPrefix }}sourceDiametreNominal_label",
        source_date_pose."Champs" as "{{ fieldPrefix }}sourceDatePose_label",
        source_date_abandon."Champs" as "{{ fieldPrefix }}sourceDateAbandon_label"

    from translated

        left join {{ ref('eaupot_def_l_canalisations_materiau' + modelVersion) }} mat -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}materiau" = mat."Code"
        left join {{ ref('eaupot_def_l_canalisations_modeCirculation' + modelVersion) }} circ -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}modeCirculation" = circ."Code"
        left join {{ ref('eaupot_def_l_canalisations_qualiteGeolocalisation' + modelVersion) }} geol -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}qualiteGeolocalisation" = geol."Code"
        left join {{ ref('eaupot_def_l_canalisations_source' + modelVersion) }} source_mat -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}sourceMateriau" = source_mat."Type"
        left join {{ ref('eaupot_def_l_canalisations_source' + modelVersion) }} source_diam -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}sourceDiametreNominal" = source_diam."Type"
        left join {{ ref('eaupot_def_l_canalisations_source' + modelVersion) }} source_date_pose -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}sourceDatePose" = source_date_pose."Type"
        left join {{ ref('eaupot_def_l_canalisations_source' + modelVersion) }} source_date_abandon -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}sourceDateAbandon" = source_date_abandon."Type"

)

select * from labelled

{% endmacro %}