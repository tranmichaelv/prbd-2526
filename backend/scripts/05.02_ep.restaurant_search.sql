set search_path to public;


drop type if exists restaurant_search_info cascade;


create type restaurant_search_info as
    (
        id integer,
        name varchar,
        city varchar,
        address varchar,
        phone varchar,
        description text,
        rating double precision,
        price_range integer,
        last_reservation_at timestamp,
        pending_requests_count integer,
        slot_duration integer
    );


create or replace function search_restaurants(search_text text default null, result_limit integer default 6)
returns  setof restaurant_search_info language sql security definer as

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
        where r2.restaurant = rest.id
          and r2.client = 6)
    as last_reservation_at,

    (select count(*)::integer
        from reservations r3
        where r3.restaurant = rest.id
          and r3.client = 6
          and r3.status = 'pending'::status_type)
     as pending_requests_count,
    rest.slot_duration

from restaurants rest

where
    nullif(trim(search_text), '') is null
   or rest.name ilike '%' || trim(search_text) || '%'
   or rest.city ilike '%' || trim(search_text) || '%'
   or rest.address ilike '%' || trim(search_text) || '%'
   or rest.description ilike '%' || trim(search_text) || '%'

order by rest.name

limit greatest(1, least(result_limit, 50));
$$;

grant execute on function search_restaurants(text, integer) to authenticated;


-- select * from search_restaurants('sushi', 6);


-- select * from search_restaurants('gastro',3);