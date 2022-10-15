{#
Produces the table (materialized because computes) of the n-n relationship between eaupotrep and eaupotcan,
according first to known reference (eaupotrep_SupportIncident) and otherwise the closest eaupotcan within 5m
(both done together, costs only becomes 18s from 4s, because if left in view becomes 1 min rather than 1s),

Though materialized as DBT incremental, it is NOT filtered on last_changed because it would need to be done
both for eaupotcan and eaupotrep versus all of them, and for now it is fast enough.

TODO true incremental as said

time :
eaupot_std_reparations_canalisations_linked  [INSERT 0 34698 in 17.96s]
#}

{{
  config(
    materialized="incremental",
    unique_key=['"eaupotrep_id"', 'eaupotcan_id'],
    tags=["incremental", "long"],
    indexes=[
      {'columns': ['"eaupotrep_id"']},
      {'columns': ['eaupotcan_id']},
    ]
  )
}}

select distinct on (eaupotrep_id) * from ( -- https://stackoverflow.com/questions/24042359/how-to-join-only-one-row-in-joined-table-with-postgres

select r."eaupotrep_id", c.eaupotcan_id, NULL as dist from {{ ref('eaupot_std_canalisations_unified') }} c
left join {{ ref('eaupot_std_reparations_unified') }} r on r."eaupotrep_supportIncident" = c."eaupotcan_idCanalisation" and r.data_owner_id = c.data_owner_id

union

(
SELECT
   DISTINCT ON (eaupotrep.eaupotrep_id) eaupotrep.eaupotrep_id, eaupotcan.eaupotcan_id,
   ST_Distance(eaupotcan."geometrie", eaupotrep."geometrie")  as dist
FROM {{ ref('eaupot_std_reparations_unified') }} As eaupotrep, {{ ref('eaupot_std_canalisations_unified') }} As eaupotcan
WHERE ST_DWithin(eaupotcan."geometrie", eaupotrep."geometrie", 5)
AND eaupotrep.eaupotrep_id is not null -- else single null (?!)
ORDER BY eaupotrep.eaupotrep_id, eaupotcan.eaupotcan_id, ST_Distance(eaupotcan."geometrie", eaupotrep."geometrie")
)

) rc
