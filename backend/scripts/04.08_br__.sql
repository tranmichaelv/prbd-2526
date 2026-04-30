set search_path to public;


create or replace function services_times_align_to_reservations_slots()
returns trigger as
$$
    declare slot int;
begin
        select slot_duration   into slot
        from restaurants
        where id = new.restaurant;

        if extract(minute  from new.start_time):: int % slot <> 0
           or extract(minute from new.end_time):: int % slot <> 0 then
            raise exception 'Services times must align with reservation slots';
        end if;
    return new;
end;
$$ LANGUAGE plpgsql;

create or replace trigger tg_service_times_align
    before insert or update
    on services
    for each row
execute function services_times_align_to_reservations_slots()
