set search_path to public, auth;

drop function if exists save_table(_number_table int, _capacity int, _table_id int);
create or replace function save_table(_number_table int, _capacity int, _table_id int)
    returns void as
$$
    perform auth.check_manager_logged();
update tables
set table_number = _number_table, capacity = _capacity
where id = _table_id

$$ language sql security definer ;

grant execute on function save_table(_number_table int, _capacity int, _table_id int) to authenticated;
