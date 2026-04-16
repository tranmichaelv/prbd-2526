set search_path to public;


do
$test$

    begin
        raise notice 'TEST BR-03: table associé à une réservation -> même restaurant associé à la réservation (valide)';

        -- reservation 1 appartient au restaurant 1
        -- table 2 appartient aussi au restaurant 1
        insert into reservation_tables (reservation, "table") values (1,2);
    end;
$test$;

do
$test$

    begin

        raise notice 'TEST BR-03: table associé à une réservation  -> même restaurant associé à la réservation (invalide)';
        perform should_fail($$
        insert into reservation_tables(reservation, "table")
        values (1, 4);
    $$, 'raise_exception');

    end;
$test$;

rollback;

