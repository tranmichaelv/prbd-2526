set search_path to public;

drop type if exists reservation_info cascade;

create type reservation_info as
    (
      id integer,
      restaurant_name varchar,
      restaurant_city  varchar,
      restaurant_address varchar,
      restaurant_phone varchar,
      datetime timestamp,
      number_of_guests integer,
      status status_type,
      special_requests text
    );

create or replace function get_reservations()
returns setof reservation_info language sql security definer as
$$
    select r.id, rest.name, rest.city, rest.address, rest.phone, r.datetime, r.number_of_guests, r.status, r.special_requests
        from reservations r
        join restaurants rest on rest.id = r.restaurant
     --   where auth.role() = 'client'
     --   and r.client = auth.id()
    where r.client = 6
        order by r.datetime desc


$$;

grant execute on function get_reservations() to anon, authenticated;

create or replace function add_reservation(_restaurant_id int, _datetime timestamp, _number_of_guests int, _special_requests text) returns void
    as
    $$
    declare
        _client int;
        begin
            -- _client := auth.id();
            -- pour tester
            _client = 6;
            insert into reservations(client,restaurant, datetime, number_of_guests,status, special_requests)
            values (_client,_restaurant_id,_datetime,_number_of_guests,'pending',_special_requests);
        end;
    $$ language plpgsql security definer ;
-- anon juste pour tester
grant execute on function add_reservation(int,timestamp,int,text) to anon, authenticated;
