set search_path to public,auth;

drop function if exists cancel_reservation(integer);

create or replace function cancel_reservation(_reservation_id integer)
returns integer
language plpgsql security definer
as
$$
    declare
        result_id integer;
    begin
        delete from reservation_tables
        where reservation = _reservation_id;

        update reservations
        set status = 'cancelled'::status_type
        where id = _reservation_id
        returning id into result_id;

        return result_id;
    end;
$$;

grant execute on function cancel_reservation(integer) to authenticated;