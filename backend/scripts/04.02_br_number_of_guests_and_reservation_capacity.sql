set search_path to public;

/*

(BR-02) Le nombre de convives d'une réservation confirmée ou terminée
ne peut pas dépasser la capacité totale des tables associées à la réservation.

Ceci implique qu'une réservation confirmée ou terminée doit avoir
au moins une table réservée appartenant au restaurant de la réservation.
*/

/*
    TABLES :
    - reservations -> after insert or update
    - reservation_tables
    - tables

- reservations :
    INSERT : oui au cas où le status est directement 'confirmed' ou 'completed'

        => si un user essaye de reserver (insérer) avec status confirmed ou completed,
            je dois vérifier alors capacity >= nb_guests

    UPDATE : oui sur les colonnes status et number_of_guests

        => si un user essaye de changer le status a confirmed/completed
            je dois vérifier capacity >= nb_guest

    DELETE : non car on supprime les tables associées en cascade


- reservation_tables :
    INSERT : non car l'ajout d'une table augmente la capacité (*)
    UPDATE : non car update interdit
    DELETE : oui au cas où on supprime une table d'une réservation confirmée/completed
                (différé pour suppression tables associées avant annulation)


 - tables :
    INSERT : non car la capacité d'une nouvelle table n'affecte pas les réservations existantes
    UPDATE : oui sur la colonne capacity car cela peut réduire la capacité totale
    DELETE : oui car la suppression d'une table réduit la capacité totale

*/
 -- fonction générique pour les trois trigger des trois tables : reservations, reservations_tables, tables
drop function if exists reservation_number_of_guests_rule_fct();
create or replace function  reservation_number_of_guests_rule_fct() returns trigger
    set search_path from current as
    $$
    begin
        if exists(
            select
                1
            from
                reservations r
                    -- j'ai choisi left join pour les reservations sans table,
                    -- donc pour traiter le cas de : reservation terminée ou confirmée doit avoir au moins une table associe
                    left join reservation_tables rt on r.id = rt.reservation
                    left join tables t on rt."table" = t.id
            where
                r.status in ('confirmed', 'completed')
            group by r.id, number_of_guests
            having count(t.id) = 0 OR coalesce(sum(t.capacity),0) < r.number_of_guests
        ) then
            raise exception 'Total capaity must be greater than or equals to number of guests !';
        end if;

        return null;
    end;
    $$ language plpgsql security definer ;

drop trigger if exists  tg_reservation_number_of_guests on reservations;
create constraint trigger tg_reservation_number_of_guests
    after insert or update
    on reservations
    deferrable initially deferred
    for each row
    execute function reservation_number_of_guests_rule_fct();

drop trigger if exists  tg_res_tables_capacity on reservation_tables;
create constraint trigger tg_res_tables_capacity
    after delete
    on reservation_tables
    deferrable initially deferred
    for each row
    execute function reservation_number_of_guests_rule_fct();

drop trigger if exists tg_tables_capacity_update on tables;
create constraint trigger tg_tables_capacity_update
    after update or delete
    on tables
    deferrable initially deferred
    for each row
    execute function reservation_number_of_guests_rule_fct();


