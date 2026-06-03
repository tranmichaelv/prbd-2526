set search_path to public, auth;



drop function if exists get_available_table_for_restaurant(_restaurant_id integer);
create or replace function get_available_table_for_restaurant(_restaurant_id integer)
    returns setof table_info as
$$
    perform auth.check_manager_logged();
select t.*
from tables t
where t.restaurant = _restaurant_id;

$$ language sql security definer ;

grant execute on function get_available_table_for_restaurant(_restaurant_id integer) to authenticated;


