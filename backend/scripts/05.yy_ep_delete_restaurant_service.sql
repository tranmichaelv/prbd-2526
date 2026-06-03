create or replace function delete_restaurant_service(_service_id integer, _restaurant_id integer)
returns void
language plpgsql security definer as
$$
    begin
        perform auth.check_manager_logged();
        delete from services
               where  id = _service_id
               and restaurant = _restaurant_id;
    end;

$$;

grant execute on function delete_restaurant_service(integer, integer) to authenticated;