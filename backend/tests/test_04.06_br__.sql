set search_path to public;


begin;
do
$test$
begin
       raise notice 'TEST:  Une table ne peut pas faire l''objet de deux réservations terminées ou confirmées pour une même date et un même service. (cas invalide)';
       perform should_fail($$
          update reservations set datetime = '2024-11-15 21:00:00.000000' where id = 13;
       $$, 'raise_exception');
end
$test$;


do
$test$
begin
       raise notice 'TEST:  Une table ne peut pas faire l''objet de deux réservations terminées ou confirmées pour une même date et un même service. (cas valide)';
update reservations set datetime = '2024-11-15 21:00:00.000000' where id = 1;
end
$test$;


rollback;






