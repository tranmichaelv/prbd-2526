set search_path to public;


begin;
do
$test$
begin
    raise notice 'TEST:  Le nombre de convives d''une réservation confirmée ou terminée ne peut pas dépasser la capacité totale des tables associées à la réservation. Ceci implique qu''une réservation confirmée ou terminée doit avoir au moins une table réservée appartenant au restaurant de la réservation. (cas valide)';
    insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
    VALUES (25,3,1,'2024-12-15 19:00:00.000000',6,'pending');

    update reservations set status = 'confirmed'::status_type where id = 25;

    insert into reservation_tables (reservation, "table")
    values (25,1);

    insert into reservation_tables (reservation, "table")
    values (25,2);
    set constraints all immediate;
end;
$test$ ;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST:  Le nombre de convives d''une réservation confirmée ou terminée ne peut pas dépasser la capacité totale des tables associées à la réservation. Ceci implique qu''une réservation confirmée ou terminée doit avoir au moins une table réservée appartenant au restaurant de la réservation. (cas invalide)';
        perform should_fail($$
            update reservations
    set number_of_guests = 4 where id = 1;
       $$, 'raise_exception');
    end;
$test$ ;
rollback;

--     update reservations
--     set status = 'confirmed'
--     where id = 22;


