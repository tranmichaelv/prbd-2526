set search_path to public, auth;

drop function if exists save_table(_number_table int, _capacity int, _table_id int);
create or replace function save_table(_number_table int, _capacity int, _table_id int)
    returns void as
$$
update tables
set table_number = _number_table, capacity = _capacity
where id = _table_id

$$ language sql security definer ;

-- grant execute on function get_available_table_for_restaurant(_restaurant_id integer) to authenticated;
grant execute on function save_table(_number_table int, _capacity int, _table_id int) to anon;
