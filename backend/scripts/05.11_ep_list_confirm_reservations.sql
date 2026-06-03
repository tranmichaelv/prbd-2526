set search_path to public, auth;

drop function if exists complete_reservation(_reservation_id int);
create or replace function complete_reservation(_reservation_id int)
    returns void as

$$
begin
        perform auth.check_manager_logged();
    update reservations set status = 'completed'::status_type where id = _reservation_id;
end;
$$ language plpgsql security definer ;

grant execute on function  complete_reservation(_reservation_id int) to authenticated;


