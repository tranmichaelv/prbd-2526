set search_path to public;


create or replace function datetime_between_start_and_endtime()
returns trigger as
$$
begin
    if exists (
        select 1
        from reservations r
        where r.status in ('confirmed','completed','pending')
          and not exists (
            select 1
            from services s
            where s.restaurant = r.restaurant
              and s.day_of_week = extract(isodow from r.datetime)
              and r.datetime::time between s.start_time and s.end_time
        )
    ) then
           raise exception 'Reservation datetime % is outside service hours for restaurant %',
               new.datetime, new.restaurant;
        end if;

    return new;
end;
$$ LANGUAGE plpgsql;

select *
from services s
where s.restaurant = 2
  and s.day_of_week = extract(isodow from timestamp '2024-12-05 20:00:00')
  and time '20:00:00' between s.start_time and s.end_time;

create or replace trigger tg_datetime_between_start_and_endtime_reservations
    before insert or update
    on reservations
    for each row
execute function datetime_between_start_and_endtime();

create or replace trigger tg_datetime_between_start_and_endtime_services
    before delete or update
    on services
    for each row
execute function datetime_between_start_and_endtime();
rollback;
