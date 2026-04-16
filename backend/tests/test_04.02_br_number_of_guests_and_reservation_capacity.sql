set search_path to public;

select * from reservations;
select * from tables;
begin;
do
$test$
begin
        -- Invalid
    insert into reservations (id, client, restaurant, datetime, number_of_guests, status)
    VALUES (25,3,1,'2024-11-15 19:00:00.000000',6,'confirmed');

    insert into reservation_tables (reservation, "table")
    values (25,1);
    commit;

    update reservations
    set number_of_guests = 4
    where
        id = 1;
    commit;

    update reservations
    set status = 'confirmed'
    where id = ;
end;
$test$ ;
rollback;
