set search_path to public;


create or replace function start_and_endtime_align_to_reservations()
returns trigger as
$$
begin
       if exists(
           select *
           from reservations
           where restaurant = new.restaurant
            and extract(isodow from datetime) = new.day_of_week
             and datetime::time not between new.start_time and new.end_time
       ) then
           raise exception 'Service is collapsing with one or more reservations';
    end if;

    return new;
end;
$$ LANGUAGE plpgsql;

create or replace trigger tg_start_and_endtime_align_to_reservations
    before insert or update
    on services
    for each row
execute function start_and_endtime_align_to_reservations();
