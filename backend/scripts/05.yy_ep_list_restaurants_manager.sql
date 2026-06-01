set search_path to public, auth;

create or replace function get_my_restaurants_test()
    returns setof restaurant_search_info as

$$
    begin
--         perform auth.check_manager_logged();
    return query
        select rest.id,
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
            join restaurant_managers rm on rest.id = rm.restaurant
--            where rm.manager = auth.id()
        where rm.manager = 2
           order by last_reservation_at desc nulls last,
                    pending_requests_count desc,
                    rest.name;
    end;
$$ language plpgsql security definer ;

-- a mettre apres quand login ok
-- grant execute on function get_my_restaurants_test() to authenticated;
grant execute on function get_my_restaurants_test() to anon;


-- tests
-- select auth.login_for_test('boverhaegen@epfc.eu');
-- select get_my_restaurants_test();
-- select current_user, auth.id(), auth.email(), auth.role();
-- select auth.check_manager_logged();
-- select auth.logout_for_test();
-- select * from users;