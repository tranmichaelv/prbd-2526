set search_path to public, auth;

drop type if exists reservation_info_manager cascade;
drop type if exists table_info cascade;

create type reservation_info_manager as
(
    id integer,
    client_name varchar,
    client_email varchar,
    client_phone varchar,
    restaurant_name varchar,
    datetime timestamp,
    number_of_guests integer,
    status status_type,
    special_requests text,
    tables table_info[]
);

create type table_info as
    (
        id integer,
        restaurant integer,
        table_number integer,
        capacity integer
    );


drop function if exists get_reservations_from_resto_manager(_restaurant_id integer)
create or replace function get_reservations_from_resto_manager(_restaurant_id integer)
    returns setof reservation_info_manager as
$$
begin
--     perform auth.check_manager_logged();
    return query
    select
        res.id,
        u.full_name,
        u.email,
        u.phone,
        resto.name,
        res.datetime,
        res.number_of_guests,
        res.status,
        res.special_requests,
        (
            select array_agg(
                           (
                            t.id,
                            t.restaurant,
                            t.table_number,
                            t.capacity
                           )::table_info
                   )
            from reservation_tables rt
                join tables t on t.id = rt."table"
            where rt.reservation = res.id
        )

    from reservations res
        join restaurants resto on resto.id = res.restaurant
        join users u on u.id = res.client
--         join reservation_tables rt on res.id = rt.reservation
--         join tables t on t.id = rt."table"

    where resto.id = _restaurant_id
    order by res.datetime desc, res.id;
end;

$$ language plpgsql security definer ;

-- grant execute on function get_reservations_from_resto_manager(idResto integer) to authenticated;
grant execute on function get_reservations_from_resto_manager(_restaurant_id integer) to anon;


-- tests
-- select auth.login_for_test('boverhaegen@epfc.eu');
-- select get_reservations_from_resto_manager(2);
-- select current_user, auth.id(), auth.email(), auth.role();
-- select auth.check_manager_logged();
-- select auth.logout_for_test();
-- select * from users;