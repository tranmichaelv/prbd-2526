set search_path to public;


begin;
do
$test$
begin
       raise notice 'TEST:  Au moment de leur création ou de leur modification, les heures de début et de fin d''un service doivent être alignées sur les créneaux de réservation pour le restaurant. (cas invalide)';
       perform should_fail($$
           update services set start_time = '13:15:00' where id = 1;
       $$, 'raise_exception');
end
$test$;


do
$test$
begin
       raise notice 'TEST:  Au moment de leur création ou de leur modification, les heures de début et de fin d''un service doivent être alignées sur les créneaux de réservation pour le restaurant. (cas valide)';
       update services set end_time = '15:00:00' where id = 1;
       set constraints all immediate;
end
$test$;


rollback;




