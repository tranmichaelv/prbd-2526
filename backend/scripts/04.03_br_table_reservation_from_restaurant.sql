set search_path to public;

/*
 Les tables associées à une réservation doivent appartenir au restaurant de la réservation.

table tables : INSERT :  non pas lié à une reservation
               UPDATE  : oui peut modifier le restaurant et donc sa reservation
                         MAIS on a déjà le check : On ne peut pas modifier le restaurant d'une table
               DELETE  : non

table reservation_table : INSERT : oui une reservation dans un restaurant avec une table d'une reservation d'un autre restaurant
                          UPDATE  : oui meme chose que insert
                          DELETE  : non supprimer un lien ne casse jamais la règle

 table reservations : INSERT   : non, au début pas lié à la table
                      UPDATE    : oui, peut modififier le restaurant de la reservation
                                  MAIS on a déjà le check : On ne peut pas modifier le restaurant d'une résarvation
                      DELETE    : non

*/

create or replace function table_reservation_from_restaurant_reservation()
returns trigger as
    $$
        begin
            if exists(
                select 1
                from reservations r
                join tables t on t.id = new."table"
                where r.id = new.reservation
                and r.restaurant <> t.restaurant
            ) then
                raise exception '(BR-03) Les tables associées à une réservation doivent appartenir au restaurant de la réservation.';
            end if;
            return new;
        end;
    $$ language plpgsql;

create trigger trg_check_table_reservation_from_restaurant_reservation
before insert or update
on reservation_tables
for each row
execute function table_reservation_from_restaurant_reservation();