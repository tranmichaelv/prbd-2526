set search_path to public;


create or replace function datetime_between_start_and_endtime()
returns trigger as
$$
declare
    day int;
begin
   if new.status in ('confirmed', 'completed', 'pending') then
       day := extract(isodow from new.datetime );

       if not exists(
           select *
           from services s
           where s.restaurant = new.restaurant
           and s.day_of_week = day
           and new.datetime::time >= s.start_time
           and new.datetime::time < s.end_time
       ) then
           raise exception 'Reservation datetime % is outside service hours for restaurant %',
               new.datetime, new.restaurant;
        end if;
    end if;

    return new;
end;
$$ LANGUAGE plpgsql;

create or replace trigger tg_datetime_between_start_and_endtime
    before insert or update
    on reservations
    for each row
execute function datetime_between_start_and_endtime();

begin;
    update reservations set status = ('confirmed') where id = 5;
rollback;
