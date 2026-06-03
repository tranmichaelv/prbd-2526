set search_path to public;


begin;
do
$test$

    begin

        raise notice 'TEST BR-07: service overlap for the same day';
        perform should_fail($$
            insert into services (restaurant, day_of_week, start_time, end_time)
            values (1,1,'13:00:00','15:00:00');
    $$, 'raise_exception');
    end;
$test$;

rollback;

begin;
do
$test$

    begin

        raise notice 'TEST BR-07: service overlap for the same day';
        perform should_fail($$
            update services
            set start_time = '13:30:00'
            where id = 4
    $$, 'raise_exception');
    end;
$test$;

rollback;


