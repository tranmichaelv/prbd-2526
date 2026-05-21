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
    returns  setof restaurant_search_info as

$$
select
    rest.id,
    rest.name,
    rest.city,
    rest.address,
    rest.phone,
    rest.description,
    rest.rating,
    rest.price_range,
    (select max(r2.datetime)
     from reservations r2
     where r2.restaurant = rest.id)
        as last_reservation_at,

    (select count(*)::integer
     from reservations r3
     where r3.restaurant = rest.id
       and r3.status = 'pending'::status_type)
        as pending_requests_count

from restaurants rest
order by
    last_reservation_at desc nulls last,
    pending_requests_count desc,
    rest.name;
$$ language sql security definer ;

grant execute on function get_my_restaurants_test() to anon;
revoke execute on function get_my_restaurants_test() from anon;