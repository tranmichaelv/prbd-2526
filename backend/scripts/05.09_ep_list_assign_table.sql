set search_path to public, auth;

drop type if exists table_info_extended cascade;
create type table_info_extended as
    (
    id integer,
    restaurant integer,
    table_number integer,
    capacity integer,
    occupied boolean
    );


drop function if exists get_available_table_for_reservations(_reservation_id integer);
create or replace function get_available_table_for_reservations(_reservation_id integer)
    returns setof table_info_extended as
$$
declare
    r1 reservations%ROWTYPE;
begin
    perform auth.check_manager_logged();
select *
into r1
from reservations
where id = _reservation_id;

RETURN QUERY

select t.*, exists(select 1
              from reservation_tables rt
                       join reservations r on rt.reservation = r.id
              where rt."table" = t.id
                and  get_service(r.datetime) = get_service(r1.datetime)
                and r.datetime::date = r1.datetime::date
                and r.id <> r1.id)
from tables t
where t.restaurant = r1.restaurant;

end;

$$ language plpgsql security definer ;

grant execute on function get_available_table_for_reservations(_reservation_id integer) to authenticated;
