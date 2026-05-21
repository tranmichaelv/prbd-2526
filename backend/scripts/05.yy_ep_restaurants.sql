set search_path to public;

create or replace function get_my_restaurants(manager_id integer)
    returns setof restaurants as
$$
    select *
    from restaurants
    where id in (select restaurant
                 from restaurant_managers
                 where manager = manager_id);
$$ language sql security definer;


drop function if exists get_my_restaurants(manager_id integer);
grant execute on function get_my_restaurants(integer) to anon, manager;
revoke execute on function get_my_restaurants(integer) from anon, manager;

select * from restaurants;
select * from restaurant_managers;
select * from pg_roles;

create or replace function get_my_restaurants_test()
    returns setof restaurants as
$$
select *
from restaurants
$$ language sql security definer;

grant execute on function get_my_restaurants_test() to anon;
revoke execute on function get_my_restaurants_test() from anon;