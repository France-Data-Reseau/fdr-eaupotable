with detected as (
    select *,
        case when (geometrie is null and geometrie__src is not null) then 1 else 0 end as geometrie__ko,
        case when ("eaupotcan_datePose" is null and "eaupotcan_datePose__src" is not null) then 1 else 0 end as "eaupotcan_datePose__ko"
    from {{ ref('eaupot_src_canalisations_en_service_parsed') }}
), counted as (
   select *,
        (geometrie__ko + "eaupotcan_datePose__ko") as err_nb
   from detected
)
select *
from counted
where err_nb > 0