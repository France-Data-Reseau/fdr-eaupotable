{#
shortcut (TODO or DBT alias ?)
#}

{{
  config(
    materialized="view",
  )
}}

select * from {{ ref('eaupot_src_canalisations_translated') }}