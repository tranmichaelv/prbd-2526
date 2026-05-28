set search_path to public;


create or replace function datetime_between_start_and_endtime()
returns trigger as
$$
begin
       if exists(
           select *
           from services s
           join reservations r on r.restaurant = s.restaurant
            where s.day_of_week = extract(isodow from r.datetime)
            and r.status in ('confirmed', 'completed', 'pending')
            and r.datetime::time not between s.start_time AND s.end_time
       ) then
           raise exception 'Reservation datetime % is outside service hours for restaurant %',
               new.datetime, new.restaurant;
        end if;

    return new;
end;
$$ LANGUAGE plpgsql;

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
