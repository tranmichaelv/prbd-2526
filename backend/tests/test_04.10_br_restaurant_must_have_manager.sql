
set search_path to public;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-10: delete one manager when another remains (valid)';

        delete from restaurant_managers
        where restaurant = 1 and manager = 1;
    end;
$test$;

rollback;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-10: delete last manager of a restaurant (invalid)';

        perform should_fail($$
        delete from restaurant_managers
        where restaurant = 3 and manager = 2;
    $$, 'raise_exception');
    end;
$test$;

rollback;

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-10: update manager assignment from restaurant with several managers (valid)';

        update restaurant_managers
        set restaurant = 6
        where restaurant = 1 and manager = 1;
    end;
$test$;

rollback;

begin;

select reset_database();

begin;

select reset_database();

do $test$
    begin
        raise notice 'TEST BR-10: update that removes the last manager from a restaurant (invalid)';

        perform should_fail($$
        update restaurant_managers
        set restaurant = 6
        where restaurant = 3 and manager = 2;
    $$, 'raise_exception');
    end;
$test$;

rollback;
