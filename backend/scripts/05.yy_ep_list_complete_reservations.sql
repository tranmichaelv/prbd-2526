set search_path to public, auth;

drop function if exists cancel_reservation(_reservation_id int);
create or replace function cancel_reservation(_reservation_id int)
    returns void as

$$
begin
--     perform auth.check_manager_logged();
    delete from reservation_tables where reservation = _reservation_id;

    update reservations set status = 'cancelled'::status_type where id = _reservation_id;
end;
$$ language plpgsql security definer ;

-- a mettre apres quand login ok
-- grant execute on function get_my_restaurants_test() to authenticated;
grant execute on function  cancel_reservation(_reservation_id int) to anon;


