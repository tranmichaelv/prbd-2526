set search_path to public;
begin;
do
$test$
    begin
        raise notice 'TEST BR-01: réservation avec un client (valide)';

        insert into reservations(client, restaurant, datetime, number_of_guests, special_requests)
        values (3,1,'2026-11-17 19:30:00.000000',5,null);
    end;

$test$;


do
$test$
    begin
        raise notice 'TEST BR-01: réservation avec un non-client (invalide)';

        perform should_fail($$
        insert into reservations (client, restaurant, datetime, number_of_guests)
        values (1, 1, now(), 2);
    $$, 'raise_exception');
    end;
$test$;
rollback;
