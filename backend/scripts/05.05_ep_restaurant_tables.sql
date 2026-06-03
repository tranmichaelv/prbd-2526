set search_path to public, auth;



drop function if exists get_available_table_for_restaurant(_restaurant_id integer);
create or replace function get_available_table_for_restaurant(_restaurant_id integer)
    returns table (id integer,
                   restaurant integer,
                   table_number integer,
                   capacity integer
                  ) as
$$
begin
    perform auth.check_manager_logged();

    return query
    select t.*
    from tables t
    where t.restaurant = _restaurant_id;
end;
$$ language plpgsql  security definer ;

grant execute on function get_available_table_for_restaurant(_restaurant_id integer) to authenticated;


