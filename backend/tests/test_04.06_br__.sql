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
       set constraints all immediate;

end
$test$;

do
$test$
begin
       raise notice 'TEST:  Une table ne peut pas faire l''objet de deux réservations terminées ou confirmées pour une même date et un même service. (cas invalide)';
       perform should_fail($$
        update reservations set datetime = '2024-11-15 19:00:00.000000' where id = 10;
        update reservations set status = 'confirmed'::status_type where id = 10;
        insert into reservation_tables(reservation, "table") values(10,1);

       $$, 'raise_exception');
end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST:  Une table ne peut pas faire l''objet de deux réservations terminées ou confirmées pour une même date et un même service. (cas valide)';
        update reservations set datetime = '2024-11-15 13:00:00.000000', status = 'confirmed'::status_type where id = 10;

        insert into reservation_tables(reservation, "table") values(10,2);
        set constraints all immediate;
    end
$test$;


rollback;






