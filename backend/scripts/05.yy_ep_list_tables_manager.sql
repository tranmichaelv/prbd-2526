set search_path to public, auth;

drop function if exists link_table_to_reservation(_reservation_id int, _table_id int);
create or replace function link_table_to_reservation(_reservation_id int, _table_ids int[])
    returns void as

$$
begin
    perform auth.check_manager_logged();

    update reservations set status = 'confirmed'::status_type where id = _reservation_id;

    insert into reservation_tables(reservation, "table")
    select _reservation_id, unnest(_table_ids);
end;
$$ language plpgsql security definer ;

grant execute on function  link_table_to_reservation(_reservation_id int,  _table_ids int[]) to authenticated;
