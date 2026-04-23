set search_path to public;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-11: completed reservation cannot be modified (invalid)';

        perform should_fail($$
        update reservations
        set special_requests = 'changed'
        where id = 12;
    $$, 'raise_exception');
    end;
$test$;

rollback;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-11: cancelled reservation cannot be modified (invalid)';

        perform should_fail($$
        update reservations
        set number_of_guests = 5
        where id = 18;
    $$, 'raise_exception');
    end;
$test$;

rollback;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-11: pending reservation can be modified (valid)';

        update reservations
        set special_requests = 'updated request'
        where id = 21;
    end;
$test$;

rollback;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-11: confirmed reservation can be modified (valid)';

        update reservations
        set special_requests = 'updated request'
        where id = 20;
    end;
$test$;

rollback;