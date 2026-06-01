set search_path to public;


/*

(BR-05) Au moment de sa création ou de sa modification,
l'heure d'une réservation doit correspondre à un créneau de réservation (slot) pour le restaurant.

Un créneau de réservation doit toujours correspondre
à une heure exacte (sans minutes) augmentée d'un multiple de la durée du créneau de réservation.


TABLES :

reservations :

    - INSERT : Oui
    - UPDATE : Oui
    - DELETE : Non

restaurants :

    - INSERT : Non
    - UPDATE : Oui
    - DELETE : Non

*/

select * from restaurants;
select * from reservations;


create or replace function valid_slot_fct() returns trigger as
    $$
    begin
        if new.slot_duration not in (10,15,20,30,60)
            then
            raise exception 'Le créneau horaire doit être parmi : 10, 15, 20, 30, 60';
        end if;
        return new;
    end;
    $$ language plpgsql;

create or replace trigger tg_slot_duration
    before insert or update
    on restaurants
    for each row
execute function valid_slot_fct();


create or replace function reservations_valid_datetime_fct() returns trigger as
$$
begin
        if not exists(
            select
                1
            from
                restaurants r
            where
                r.id = new.restaurant
                and r.slot_duration in (10,15,20,30,60)
                and extract(minute from new.datetime) % r.slot_duration = 0
        )
        then
            raise exception 'La réservation ne correspond pas à un créneau valide';
        end if;
    return new;
end;
$$ language plpgsql;


create or replace trigger tg_reservation_datetime
    before insert or update
    on reservations
    for each row
execute function reservations_valid_datetime_fct();