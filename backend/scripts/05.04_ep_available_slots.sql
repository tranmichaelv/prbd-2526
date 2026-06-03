set search_path to public,auth;

create or replace function get_available_slots(
    _restaurant_id integer,
    _date date
)
    returns table (
                      slot_datetime timestamp
                  )
    language sql
    security definer
as
$$
select
    generate_series(
            (_date + s.start_time)::timestamp,
            (_date + s.end_time - (rest.slot_duration * interval '1 minute'))::timestamp,
            rest.slot_duration * interval '1 minute'
    ) as slot_datetime
from services s
         join restaurants rest on rest.id = s.restaurant
where s.restaurant = _restaurant_id
  and s.day_of_week = extract(isodow from _date)::integer
order by slot_datetime;
$$;;

grant execute on function get_available_slots(integer, date) to authenticated;



-- select * from get_available_slots(1,'2024-12-08');

