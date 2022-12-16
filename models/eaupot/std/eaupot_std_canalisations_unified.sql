{#
en incrémental (table)

indexes : if dedup
      {'columns': order_by_fields},
#}

{% set fieldPrefix = 'eaupotcan' + '_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="incremental",
    unique_key=fieldPrefix + 'id',
    tags=["incremental"],
    indexes=[{'columns': ['"' + fieldPrefix + 'id"']},
      {'columns': ['geometrie'], 'type': 'gist'},]
  )
}}

with unioned as (

{{ dbt_utils.union_relations(relations=[
      ref('eaupot_def_canalisations_definition'),
      ref('eaupot_src_canalisations_translated')],
    include=(adapter.get_columns_in_relation(ref('eaupot_def_canalisations_definition')) | map(attribute='name') | list)
        + fdr_francedatareseau.list_generic_fields(fieldPrefix) + fdr_francedatareseau.list_import_fields(),
    source_column_name='eaupotcan_src_relation',
    column_override={"geometrie": "geometry"})
}}

), labelled as ( -- not before else hard to filter out non-def fields
  {{ eaupot_canalisations_labelled('unioned') }}
)

select *
-- adding stored geo field used to compute distances in dedupe :
--, ST_Transform(geometry, 2154) as geometry_2154
--, ST_X(geometry) as x, ST_Y(geometry) as y
from labelled
-- same order by as for _deduped : not really too long but index on it is enough
----order by "{{ order_by_fields | join('" asc, "') }}" asc -- NOO too long, index on it is enough

{% if is_incremental() %}
  where last_changed > (select coalesce(max(last_changed), to_timestamp('1970-01-01T00:00:00', 'YYYY-MM-DD"T"HH24:MI:SS')) from {{ this }})
{% endif %}