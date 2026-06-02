set search_path to public;

begin;
do
$test$
begin
       raise notice 'TEST:  L''heure d''une réservation confirmée, terminée ou en attente doit être comprise entre l''heure de début et l''heure de fin d''un service pour le même jour de la semaine. (cas invalide)';
       perform should_fail($$
           update reservations set datetime = '2024-11-15 17:00:00' where id = 1;
       $$, 'raise_exception');
end
$test$;


do
$test$
begin
       raise notice 'TEST:  L''heure d''une réservation confirmée, terminée ou en attente doit être comprise entre l''heure de début et l''heure de fin d''un service pour le même jour de la semaine. (cas valide)';
        update reservations set datetime = '2024-12-02 19:00:00.000000' where id = 1;
end
$test$;


rollback;


