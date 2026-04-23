set search_path to public;

create or replace function no_double_table_booking()
returns trigger as
$$
begin
    if exists(
        select *
        from reservations r
                 join reservation_tables rt on rt.reservation = r.id
                 join reservations r1 on r1.datetime::date = r.datetime::date
                 join reservation_tables rt1 on rt1.reservation = r1.id
        where get_service(r.datetime) = get_service(r1.datetime)
          and r.datetime::date = r1.datetime::date
          and rt."table" = rt1."table"
          and r.id > r1.id
          and r.status in ('confirmed'::status_type, 'completed'::status_type)
    ) then
       raise exception 'Table already reserved for this service and date';
    end if;

    return null;
end;
$$
language plpgsql;



create or replace function get_service(datetime timestamp)
    returns integer as
$$
    select id
    from services
    where datetime::time between start_time and end_time
        and day_of_week = extract(isodow from datetime )
$$ language sql;


create or replace trigger trg_no_double_table_booking_reservation_tables
    after insert
    on reservation_tables
    for each row
execute function no_double_table_booking();

create or replace trigger trg_no_double_table_booking_reservations
    after update
    on reservations
    for each row
execute function no_double_table_booking();



