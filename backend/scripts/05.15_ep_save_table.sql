set search_path to public, auth;

drop function if exists save_table(_number_table int, _capacity int, _table_id int);
create or replace function save_table(_number_table int, _capacity int, _table_id int)
    returns void as
$$
begin
    perform auth.check_manager_logged();
    update tables
    set table_number = _number_table, capacity = _capacity
    where id = _table_id;
end;

$$ language plpgsql security definer ;

grant execute on function save_table(_number_table int, _capacity int, _table_id int) to authenticated;

drop function if exists add_table(_restaurant_id int, _number_table int, _capacity int);
create or replace function add_table(_restaurant_id int, _number_table int, _capacity int)
    returns  void as
$$

    begin
        perform auth.check_manager_logged();

        insert into tables(restaurant, table_number, capacity)
        VALUES (_restaurant_id, _number_table, _capacity);
    end;


$$ language plpgsql security definer;

grant execute on function add_table(int, int, int) to authenticated;