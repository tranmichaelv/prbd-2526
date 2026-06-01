set search_path to public, auth;

drop function if exists link_table_to_reservation(_reservation_id int, _table_id int);
create or replace function link_table_to_reservation(_reservation_id int, _table_ids int[])
    returns void as

$$
begin

    update reservations set status = 'confirmed'::status_type where id = _reservation_id;

    insert into reservation_tables(reservation, "table")
    select _reservation_id, unnest(_table_ids);
end;
$$ language plpgsql security definer ;

-- a mettre apres quand login ok
-- grant execute on function get_my_restaurants_test() to authenticated;
grant execute on function  link_table_to_reservation(_reservation_id int,  _table_ids int[]) to anon;


-- tests
-- select auth.login_for_test('boverhaegen@epfc.eu');
-- select get_my_restaurants_test();
-- select current_user, auth.id(), auth.email(), auth.role();
-- select auth.check_manager_logged();
-- select auth.logout_for_test();
-- select * from users;