set search_path to public;

drop type if exists reservation_info cascade;

create type reservation_info as
    (
      id integer,
        restaurant_id integer,
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
    select r.id, r.restaurant, rest.name, rest.city, rest.address, rest.phone, r.datetime, r.number_of_guests, r.status, r.special_requests
        from reservations r
        join restaurants rest on rest.id = r.restaurant
     -- where auth.role() = 'client'
            where r.client = auth.id()
    -- where r.client = 6
        order by r.datetime desc


$$;

grant execute on function get_reservations() to client, authenticated;

create or replace function add_reservation(_restaurant_id int, _datetime timestamp, _number_of_guests int, _special_requests text) returns void
    as
    $$
    declare
        _client int;
        begin
            _client := auth.id();
            -- pour tester
            -- _client = 6;
            insert into reservations(client,restaurant, datetime, number_of_guests,status, special_requests)
            values (_client,_restaurant_id,_datetime,_number_of_guests,'pending',_special_requests);
        end;
    $$ language plpgsql security definer ;
grant execute on function add_reservation(int,timestamp,int,text) to client, authenticated;


create or replace function update_reservation(_reservation_id int,_datetime timestamp,_number_of_guests int, _special_requests text) returns void as
    $$
    begin
        update reservations
        set datetime = _datetime,
            number_of_guests = _number_of_guests,
            special_requests = _special_requests
            where id = _reservation_id
            and client = auth.id();

        if not found then
            raise exception 'Reservation not found';
        end if;
    end;

    $$ language plpgsql security definer ;

grant execute on function  update_reservation(int,timestamp,int,text) to client, authenticated;
