set search_path to public;

create or replace function no_table_for_cancelled_or_pending_reservations() returns trigger
    set search_path from current as
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
language plpgsql security definer;

drop trigger if exists trg_no_table_for_cancelled_or_pending_reservations on reservations;
create constraint trigger trg_no_table_for_cancelled_or_pending_reservations
    after update
    on reservations
    deferrable initially deferred
for each row
execute function no_table_for_cancelled_or_pending_reservations();

drop trigger if exists trg_no_table_for_cancelled_or_pending_reservations_tables on reservation_tables;
create constraint trigger trg_no_table_for_cancelled_or_pending_reservations_tables
    after insert
    on reservation_tables
    deferrable initially deferred
    for each row
execute function no_table_for_cancelled_or_pending_reservations();