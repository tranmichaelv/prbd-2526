set search_path to public;

drop function if exists prevent_restaurant_change();
create or replace function prevent_restaurant_change()
    returns trigger as $$
begin
    if exists(
        select *
        from services
        where new.id = id
        and new.restaurant != restaurant
    ) then
        raise exception 'Modification of restaurant is not allowed';
    end if;

    return null;
end;
$$ language plpgsql;

create or replace function prevent_client_change()
    returns trigger as $$
begin
    if exists(
        select *
        from tables
        where new.id = id
          and new.restaurant != restaurant
    ) then
        raise exception 'Modification of restaurant is not allowed';
    end if;

    return null;
end;
$$ language plpgsql;

create or replace function prevent_restaurant_or_client_change()
    returns trigger as $$
begin
    if exists(
        select *
        from reservations
        where new.id = id
          and new.restaurant != restaurant
        or new.client != client
    ) then
        raise exception 'Modification of restaurant is not allowed';
    end if;

    return null;
end;
$$ language plpgsql;

drop trigger if exists trg_prevent_restaurant_change_from_services on services;
create trigger trg_prevent_restaurant_change_from_services
    before update of restaurant
    on services
    for each row
execute function prevent_restaurant_change();

drop trigger if exists trg_prevent_restaurant_change_from_tables on tables;
create trigger trg_prevent_restaurant_change_from_tables
    before update of restaurant
    on tables
    for each row
execute function prevent_client_change();

drop trigger if exists trg_prevent_restaurant_or_client_change_from_reservations on reservations;
create trigger trg_prevent_restaurant_or_client_change_from_reservations
    before update of restaurant, client
    on reservations
    for each row
execute function prevent_restaurant_or_client_change();

create or replace function prevent_update()
    returns trigger as $$
begin
    raise exception 'Modification interdite de reservation_tables';
end;
$$ language plpgsql;

create trigger tg_prevent_update_reservation_tables
    before update on reservation_tables
    for each row
execute function prevent_update();

create trigger tg_prevent_update_restaurant_managers
    before update on restaurant_managers
    for each row
execute function prevent_update();
