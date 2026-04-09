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


-- Le mot de passe doit être stocké de manière sécurisée (hachage + sel).
create or replace function auth.encrypt_pass()
    returns trigger as
$$
declare
    hash text;
begin
    -- Si insert ou mot de passe modifié et pas déjà hashé
    if TG_OP = 'INSERT'
        or new.password != old.password and
           not (new.password ~ '^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$')
    then
        -- Hash du mot de passe
        hash = auth.crypt(new.password, auth.gen_salt('bf'));
        update users
        set password = hash
        where users.full_name = new.full_name;
    end if;

    return null;
end;
$$ language plpgsql security definer;

drop trigger if exists encrypt_pass on users;
create trigger encrypt_pass
    -- after trigger to allow constraints to be executed
    after insert or update
    on users
    for each row
execute procedure auth.encrypt_pass();

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