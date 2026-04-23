set search_path to public;

create or replace function no_double_reservations_for_client()
returns trigger as
$$
begin
    if exists(
        select *
        from
            reservations r, reservations r1
        where r > r1
          and r.client = r1.client
          and r.datetime::date = r1.datetime::date
          and get_service(r.datetime) = get_service(r1.datetime)
          and r.status in ('confirmed'::status_type, 'completed'::status_type, 'pending'::status_type)
    ) then
        raise exception 'Client can''t have two times the same reservations';
    end if;
return null;
end;
$$
language plpgsql;

create or replace trigger trg_no_double_reservations_for_client
    after update or insert
    on reservations
    for each row
execute function no_double_reservations_for_client();
