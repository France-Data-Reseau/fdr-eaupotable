{#
Enrichissement (par les communes et données démographiques dont population) des données normalisées
de toutes les sources de type eaupotable.reparations.

Donc le bon point de départ sur tous les indicateurs sur les reparations (et leurs enrichissements).

#}

{% set fieldPrefix = 'eaupot' + '_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="view",
  )
}}


select
    rep.*,

    repcan.dist, -- NULL if already known through eaupotrep_SupportIncident

    {{ dbt_utils.star(ref('eaupot_std_canalisations_unified'), relation_alias="can", prefix="repcan_",
        except=fdr_francedatareseau.list_import_fields()) }} -- prefix because of geometrie ; TODO "none"
    {# prefix="can_",  #}
    {#, { dbt_utils.star(ref('eaupot_std_canalisations_unified'), relation_alias="closestcan", prefix="closestcan_",
        except=fdr_francedatareseau.list_import_fields()) }#}
    -- NB. prefix because else conflict
    {# or instead of except, list fields using using eaupot_def_*_definition #}

    -- AODE :
    -- already within above fields

    -- reg & com (outside geo) :
    -- already within above enriched fields
    ,
    can.com_code as repcan_com_code,
    can.com_name as repcan_com_name,
    can.epci_code as repcan_epci_code,
    can.epci_name as repcan_epci_name,
    can.dep_code as repcan_rep_code,
    can.dep_name as repcan_dep_name,
    can.reg_code as repcan_reg_code,
    can.reg_name as repcan_reg_name
    -- demo :
    , can."Population" as "repcan_Population"

    -- enrich with region : NOT NEEDED
    --,
    --region.geometry,
    --region.geometry_shape_2154

    from {{ ref('eaupot_std_reparations_unified') }} rep
        {#
        -- not faster when commented (if not used)
        -- communes :
        -- TODO TODO join on fields unique across data_owner_id / FDR_SIREN !
        left join {{ ref('eaupot_std_reparations_commune_linked') }} repcom -- LEFT join sinon seulement les lignes qui ont une valeur !!
                on rep."eaupotrep_id" = repcom."eaupotrep_id" -- on rep."com_code" = repcom."com_code"
        #}
        -- no need to join to AODE, because no more of its fields are required.
        -- no need to join also to commune, because the very common fields we require have already been included in the link table NO NOT ALL :
        {#
        -- not faster when commented (because not used)
        left join {{ source('france-data-reseau', 'fdr_std_communes_ods') }} com -- LEFT join sinon seulement les lignes qui ont une valeur !!
                on repcom.com_code = com.com_code
        -- enrich with region : NOT NEEDED
        --left join {{ source('france-data-reseau','fdr_std_regions_ods') }} region --  LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
        --    on "reg_code" = region."Code Officiel Région"
        #}

        {#
        -- canalisations, given :
        left join {{ ref('eaupot_std_canalisations_commune_demo_enriched') }} can on rep."eaupotrep_supportIncident" = can."eaupotcan_idCanalisation" and rep.data_owner_id = can.data_owner_id

        -- canalisations, closest found :
        left join {{ ref('eaupot_std_reparations_canalisations_linked') }} repcan -- LEFT join sinon seulement les lignes qui ont une valeur !!
                on rep."eaupotrep_id" = repcan."eaupotrep_id" -- on rep."com_code" = repcom."com_code"
        left join {{ ref('eaupot_std_canalisations_commune_demo_enriched') }} closestcan on repcan."eaupotcan_id" = closestcan."eaupotcan_id"
        #}


        {#
        -- canalisations - merged, inlined (too long, 1 min for first line...) :
        left join (
            select distinct on (eaupotrep_id) * from ( -- https://stackoverflow.com/questions/24042359/how-to-join-only-one-row-in-joined-table-with-postgres
            select r."eaupotrep_id", c.* from {{ ref('eaupot_std_canalisations_commune_demo_enriched') }} c
            left join {{ ref('eaupot_std_reparations') }} r on r."eaupotrep_supportIncident" = c."eaupotcan_idCanalisation" and r.data_owner_id = c.data_owner_id
            union
            select rc."eaupotrep_id" , c.* from {{ ref('eaupot_std_canalisations_commune_demo_enriched') }} c
            left join {{ ref('eaupot_std_reparations_canalisations_linked') }} rc on c."eaupotcan_id" = rc."eaupotcan_id"
            ) cc
        ) can on rep."eaupotrep_id" = can."eaupotrep_id"
        #}

        -- canalisations - merged, externalized :
        left join {{ ref('eaupot_std_reparations_canalisations_linked') }} repcan -- LEFT join sinon seulement les lignes qui ont une valeur !!
                on rep."eaupotrep_id" = repcan."eaupotrep_id" -- on rep."com_code" = repcom."com_code"
        left join {{ ref('eaupot_std_canalisations_commune_demo_enriched') }} can on repcan."eaupotcan_id" = can."eaupotcan_id"

