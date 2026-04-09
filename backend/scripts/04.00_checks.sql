set search_path to public;
/*************************************************************************
    User
*************************************************************************/

-- Le nom complet doit avoir une longueur d'au moins 3 caractères.

alter table users
    drop constraint if exists users_full_name_length_check;

alter table users
add constraint users_full_name_length_check
check ( length(trim(full_name)) >= 3 );

-- MDP >= 8 + chiffre + MAJ + MIN + carac spéciale
alter table users
    drop constraint if exists users_password_ok_check;

alter table users
add constraint users_password_ok_check
check ( password ~ '^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[,;.:!?/$%&@#]).{8,}$');

-- On ne peut pas modifier le rôle d'un utilisateur.

create or replace function auth.role_change() returns trigger as
$$
begin
    if tg_op = 'UPDATE' and new.role != old.role
    then raise exception 'Role cannot be changed for user %', new.full_name;

    end if;
    return new;
end;
$$ language plpgsql security definer ;

drop trigger if exists role_change on users;
create trigger role_change
    -- Before trying to update on table users
    before update
    on users
    for each row
execute function auth.role_change();

alter table restaurants drop constraint restaurant_name_length_check;
alter table restaurants
add constraint restaurant_name_length_check
check (
    length(trim(name)) >= 5
    );


alter table restaurants drop constraint restaurant_phone_number_format_check;
alter table restaurants
add constraint restaurant_phone_number_format_check
check (
    phone ~ '^\+32( ?\d){8,9}$'
    );

alter table restaurants drop constraint restaurants_address_length_check;
alter table restaurants
add constraint restaurants_address_length_check
check ( length(trim(address)) >= 5 );

alter table restaurants drop constraint restaurants_desc_length_check;
alter table restaurants
add constraint restaurants_desc_length_check
check ( length(trim(description)) >= 10 );

alter table restaurants drop constraint restaurants_slot_duration_check;
alter table restaurants
add constraint  restaurants_slot_duration_check
check ( slot_duration in(10,15,20,30,60));


-- check restaurants city length
alter table restaurants drop constraint restaurant_city_length_check;
alter table restaurants
    add constraint restaurant_city_length_check
        check (
            length(trim(city)) >= 3
            );

alter table restaurants drop constraint restaurant_rating_bounds_check;
alter table restaurants
    add constraint restaurant_rating_bounds_check
        check (
            rating between 0.0 and 5.0
            );

alter table restaurants drop constraint restaurant_price_range_check;
alter table restaurants
    add constraint restaurant_price_range_check
        check (
            price_range between 1 and 4
            );

alter table reservations drop constraint reservations_status_check;
alter table reservations
    add constraint reservations_status_check
        check (
            status in ('pending','confirmed', 'cancelled','completed')
            );

alter table reservations drop constraint  reservations_nb_of_guests_check;
alter table reservations
    add constraint reservations_nb_of_guests_check
        check ( number_of_guests >= 1 );


alter table reservations drop constraint reservations_special_request_check;
alter table reservations
    add constraint reservations_special_request_check
        check ( length(trim(special_requests)) >= 10 );
