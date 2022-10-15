{#
Enrichissement (par les communes et données démographiques dont population) des données normalisées
de toutes les sources de type eaupotable.canalisations.

Donc le bon point de départ sur tous les indicateurs sur les canalisations (et leurs enrichissements).

- on ne garde que les champs officiels
#}

{{
  config(
    materialized="view"
  )
}}

{% set source_model = ref('eaupot_std_canalisations_unified') %}

with enriched as (
{#
Alternative : implicit SELECT * or=dbt_utils.star(my_model_definition_relation) or all fields explicitly...
#}
select
    -- eaupotcan :
    eaupotcan.*,
    -- com :
    {#{ dbt_utils.star(source('france-data-reseau', 'fdr_std_communes_ods'),
        except=['geometry'] + fdr_francedatareseau.list_import_fields(), relation_alias='com') }},#} -- _id is most probably added by CKAN to all imports
    com.geometry as com_geometry,
    com.com_code,
    com.com_name,
    com.epci_code,
    com.epci_name,
    com.dep_code,
    com.dep_name,
    com.reg_code,
    com.reg_name
    -- demo :
    {#{ dbt_utils.star(source('france-data-reseau', 'fdr_std_demographie_communes_2014_typed'),
        except=fdr_francedatareseau.list_import_fields()) }#} -- _id is most probably added by CKAN to all imports
    --, demo."Population"
    , com."Population"

    from {{ source_model }} eaupotcan

        left join {{ ref('eaupot_std_canalisations_commune_linked') }} cancom -- LEFT join sinon seulement les lignes qui ont une valeur !!
                on eaupotcan."eaupotcan_id" = cancom."eaupotcan_id" -- on eaupotcan."com_code" = cancom."com_code"
        -- no need to join also to commune, because the very common fields we require have already been included in the link table NO NOT ALL :
        left join {{ source('france-data-reseau', 'fdr_std_communes_ods') }} com -- LEFT join sinon seulement les lignes qui ont une valeur !!
                on cancom.com_code = com.com_code
)
select * from enriched