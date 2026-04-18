set search_path to public;

/*

(BR-02) Le nombre de convives d'une réservation confirmée ou terminée
ne peut pas dépasser la capacité totale des tables associées à la réservation.

Ceci implique qu'une réservation confirmée ou terminée doit avoir
au moins une table réservée appartenant au restaurant de la réservation.
*/

create or replace function reservation_number_of_guests_rule_fct() returns trigger as
    $$
    declare
        restaurant_total_capacity int;
    begin
        --  check if reservations is : confirmed or completed
        if (new.status in ('confirmed','completed'))
            then
                select
                    sum(tb.capacity)
                from
                    reservations res
                        join reservation_tables res_tb on res.id = res_tb.reservation
                        join tables tb on res_tb.table = tb.id
                where
                    res.id = new.id
                group by
                    res.id
                into restaurant_total_capacity;
        end if;

        if not (restaurant_total_capacity >= new.number_of_guests) then
            raise exception 'Number of guests cannot be grater than total capacity of tables for this reservation';
        end if;

        return new;
    end;
    $$ language plpgsql;


create or replace trigger reservation_number_of_guests_rule

    -- after making new reservation, to have the id of the reservation
    -- if the reservation is invalid a rollback will be done
    after insert or update
    on reservations
    for each row
    execute function reservation_number_of_guests_rule_fct();

