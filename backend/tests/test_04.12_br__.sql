set search_path to public;


begin;
do
$test$
begin
       raise notice 'TEST:  Une réservation en attente ou annulée ne peut être associée à aucune une table. (cas invalide)';
       perform should_fail($$
            update reservations set status = 'pending'::status_type where id = 1;
       $$, 'raise_exception');
end
$test$;


do
$test$
begin
       raise notice 'TEST:  Une réservation en attente ou annulée ne peut être associée à aucune une table. (cas valide)';
       update reservations set number_of_guests = 1 where id = 1;
    set constraints all immediate;
end
$test$;

do
$test$
    begin
        raise notice 'TEST:  Une réservation en attente ou annulée ne peut être associée à aucune une table. (cas invalide)';
        perform should_fail($$
            insert into reservation_tables(reservation, "table") values(22,11);
       $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST:  Une réservation en attente ou annulée ne peut être associée à aucune une table. (cas valide)';
        update reservations set status = 'confirmed'::status_type where id = 22;
        insert into reservation_tables(reservation, "table") values(22, 10);
        set constraints all immediate;
    end
$test$;


rollback;




