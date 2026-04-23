set search_path to public;



do
$test$

    begin

        raise notice 'TEST BR-05: slot_duration invalide pour un restaurant';
        perform should_fail($$
            insert into restaurants (name, address, city, phone, description, rating, price_range, slot_duration)
            VALUES ('test','rue test test','Bruxlles','+32 2 123 45 67','test test', 4, 3,12);
    $$, 'raise_exception');
    end;
$test$;

rollback;

do
$test$
    begin
        raise notice 'TEST BR-XX: reservation avec une heure incompatible avec le slot du restaurant';

        perform should_fail($$
            insert into reservations (client, restaurant, datetime, number_of_guests,status)
            VALUES (3,1,'2024-11-20 20:10:00',2,'confirmed');
    $$, 'raise_exception');

    end;
$test$;

rollback;