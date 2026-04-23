set search_path to public;

begin;

do $test$
    begin
        raise notice 'TEST BR-09: new reservation with pending status (valid)';

        insert into reservations(client, restaurant, datetime, number_of_guests, status, special_requests)
        values (3, 1, '2024-12-05 19:00:00', 2, 'pending', null);
        set constraints all immediate;
    end;
$test$;

do $test$
    begin
        raise notice 'TEST BR-09: new reservation with confirmed status (invalid)';

        perform should_fail($$
        insert into reservations(client, restaurant, datetime, number_of_guests, status, special_requests)
        values (3, 1, '2024-12-05 19:00:00', 2, 'confirmed', null);
    $$, 'raise_exception');
    end;
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST BR-09: pending -> confirmed (valid)';

        update reservations
        set status = 'confirmed'
        where id = 22;

        insert into reservation_tables (reservation, "table")
        values (22, 10);

        set constraints all immediate;
    end;
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST BR-09: pending -> cancelled (valid)';

        update reservations
        set status = 'cancelled'
        where id = 22;

        set constraints all immediate;
    end;
$test$;
rollback;

begin;

do $test$
    begin
        raise notice 'TEST BR-09: pending -> completed (invalid)';

        perform should_fail($$
        update reservations
        set status = 'completed'
        where id = 21;
    $$, 'raise_exception');
    end;
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST BR-09: confirmed -> completed (valid)';

        update reservations
        set status = 'completed'
        where id = 20;

        set constraints all immediate;
    end;
$test$;
rollback;

begin;

do $test$
    begin
        raise notice 'TEST BR-09: confirmed -> cancelled (valid)';

        delete from reservation_tables where reservation = 20;

        update reservations
        set status = 'cancelled'
        where id = 20;

        set constraints all immediate;
    end;
$test$;
rollback;

begin;
do $test$
    declare
        rid int;
    begin
        raise notice 'TEST BR-09: confirmed -> pending in future (valid)';

        insert into reservations(client, restaurant, datetime, number_of_guests, status, special_requests)
        values (3, 1, '2024-12-06 19:00:00', 2, 'pending', null)
        returning id into rid;

        update reservations
        set status = 'confirmed'
        where id = rid;

        update reservations
        set status = 'pending'
        where id = rid;

        set constraints all immediate;
    end;
$test$;
rollback;

begin;
do $test$
    begin
        raise notice 'TEST BR-09: confirmed -> pending in past (invalid)';

        perform should_fail($$
        update reservations
        set status = 'pending'
        where id = 20;
    $$, 'raise_exception');
    end;
$test$;

do $test$
    begin
        raise notice 'TEST BR-09: completed -> pending (invalid)';

        perform should_fail($$
        update reservations
        set status = 'pending'
        where id = 12;
    $$, 'raise_exception');
    end;
$test$;

do $test$
    begin
        raise notice 'TEST BR-09: cancelled -> confirmed (invalid)';

        perform should_fail($$
        update reservations
        set status = 'confirmed'
        where id = 18;
    $$, 'raise_exception');
    end;
$test$;

rollback;