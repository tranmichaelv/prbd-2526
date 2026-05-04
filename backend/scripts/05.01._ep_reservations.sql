set search_path to public;

drop type if exists reservation_info cascade;

create type reservation_info as
    (
      id integer,
      restaurant_name varchar,
      restaurant_city  varchar,
      datetime timestamp,
      number_of_guests integer,
      status status_type
    );

create or replace function get_reservations()
returns setof reservation_info language sql security definer as
$$
    select r.id, rest.name, rest.city, r.datetime, r.number_of_guests, r.status
        from reservations r
        join restaurants rest on rest.id = r.restaurant
     --   where auth.role() = 'client'
     --   and r.client = auth.id()
    where r.client = 6
        order by r.datetime desc


$$;

grant execute on function get_reservations() to anon, authenticated;