set search_path to public;

create or replace function prevent_restaurant_and_client_change()
    returns trigger AS $$
begin
    raise exception 'Modification of restaurant or client is not allowed';
end;
$$ language plpgsql;

drop trigger if exists trg_prevent_restaurant_change_from_services on services;
create trigger trg_prevent_restaurant_change_from_services
    before update of restaurant
    on services
    for each row
execute function prevent_restaurant_and_client_change();

drop trigger if exists trg_prevent_restaurant_change_from_tables on tables;
create trigger trg_prevent_restaurant_change_from_tables
    before update of restaurant
    on tables
    for each row
execute function prevent_restaurant_and_client_change();

drop trigger if exists trg_prevent_restaurant_or_client_change_from_reservations on reservations;
create trigger trg_prevent_restaurant_or_client_change_from_reservations
    before update of restaurant, client
    on reservations
    for each row
execute function prevent_restaurant_and_client_change();
