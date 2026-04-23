set search_path to public;

create or replace function no_table_for_cancelled_or_pending_reservations()
returns trigger as
$$
begin
    if exists(
        select *
        from reservations r
            join reservation_tables rt on r.id = rt.reservation
        where status in('pending'::status_type, 'cancelled'::status_type)
    ) then
        raise exception 'Cancelled or pending tables can''t have a table allocated';
    end if;

    return null;
end;
$$
language plpgsql;

create or replace trigger trg_no_table_for_cancelled_or_pending_reservations
    after update
    on reservations
for each row
execute function no_table_for_cancelled_or_pending_reservations();

create or replace trigger trg_no_table_for_cancelled_or_pending_reservations_tables
    after insert
    on reservation_tables
    for each row
execute function no_table_for_cancelled_or_pending_reservations();