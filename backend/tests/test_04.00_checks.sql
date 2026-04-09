set search_path to public;

-- ######### TABLE ###########

-- unique
begin;
do
$test$
    begin
        raise notice 'TEST: table est unique a un restaurant (cas valide)';
        update tables set table_number = '4' where id = 1;
    end
$test$;

do
$test$
    begin
        raise notice 'TEST: table est unique a un restaurant (cas invalide)';
        perform should_fail($$
            update tables set table_number = '2' where id = 1;
        $$, 'unique_violation');
    end
$test$;

--only_positive_tables_number_check
do
$test$
    begin
        raise notice 'TEST: le numero de la tables est positif (cas valide)';
        update tables set table_number = '4' where id = 1;
    end
$test$;

do
$test$
    begin
        raise notice 'TEST: le numero de la tables est positif (cas invalide)';
        perform should_fail($$
            update tables set table_number = '-2' where id = 1;
        $$,'check_violation');
    end
$test$;

-- only_positive_tables_capacity_check
do
$test$
    begin
        raise notice 'TEST: la capacité de la tables est positif (cas valide)';
        update tables set capacity = '10' where id = 1;
    end
$test$;

do
$test$
    begin
        raise notice 'TEST: la capacité de la tables est positif (cas invalide)';
        perform should_fail($$
            update tables set capacity = '-2' where id = 1;
        $$,'check_violation');
    end
$test$;
rollback;
-- ######### SERVICES ###########

-- unique
begin;
do
$test$
    begin
        raise notice 'TEST: service est unique a un restaurant, jour, debut et fin de service (cas valide)';
        update services set end_time = '15:00:00' where id = 1;
    end
$test$;

do
$test$
    begin
        raise notice 'TEST: service est unique a un restaurant, jour, debut et fin de service (cas invalide)';
        perform should_fail($$
            update services set start_time = '12:00:00', end_time = '15:00:00' where id = 2;
        $$, 'unique_violation');
    end
$test$;

--must_be_day_of_the_week_check
do
$test$
    begin
        raise notice 'TEST: le numero du jour de la semaine doit être entre 1 et 7 (cas valide)';
        update services set day_of_week = '2' where id = 1;
    end
$test$;

do
$test$
    begin
        raise notice 'TEST: le numero du jour de la semaine doit être entre 1 et 7 (cas invalide)';
        perform should_fail($$
            update services set day_of_week = '8' where id = 1;
        $$,'check_violation');
    end
$test$;

-- service_time_check
do
$test$
    begin
        raise notice 'TEST: L''heure de fin doit être postérieure à l''heure de début d''au moins une heure. (cas valide)';
        update services set start_time = '14:00:00' where id = 1;
    end
$test$;

do
$test$
    begin
        raise notice 'TEST: L''heure de fin doit être postérieure à l''heure de début d''au moins une heure. (cas invalide)';
        perform should_fail($$
            update services set start_time = '14:30:00' where id = 1;
        $$,'check_violation');
    end
$test$;
rollback;

-- Test user full name >= 3

begin;

do $test$
    begin
        raise notice 'TEST: users.full_name >= 3 (cas positif)';

        insert into users(id, email, password, full_name, role, phone)
        values (9, 'walid1@epfc.eu', 'Password1!', 'Walid', 'client', null);
    end
$test$;

do $test$
    begin
        raise notice 'TEST: users.full_name >= 3 (cas negatif)';

        perform should_fail($$
        insert into users(id, email, password, full_name, role, phone)
        values (10, 'walid2@epfc.eu', 'Password1!', 'Wa', 'client', null);
    $$, 'check_violation');
    end
$test$;
-- Test user  password
    -- password OK
do $test$
    begin
        raise notice 'TEST: password OK';
        insert into users(id, email, password, full_name, role, phone)
        values (30, 'ok1@epfc.eu', 'Password1!', 'User Test', 'client', null);
    end
$test$;

    -- password trop court
do $test$
    begin
        raise notice 'TEST: password trop court';
        perform should_fail($$
        insert into users(id, email, password, full_name, role, phone)
        values (31, 'fail1@epfc.eu', 'Pass1!', 'User Test', 'client', null);
    $$, 'check_violation');
    end
$test$;

    -- pas de MAJ
do $test$
    begin
        raise notice 'TEST: pas de majusucule';

        perform should_fail($$
        insert into users(id, email, password, full_name, role, phone)
        values (21, 'wwwalid@epfc.eu', 'password1!', 'Test User', 'client', null);
    $$, 'check_violation');
    end
$test$;

    -- pas de carac spécial
do $test$
    begin
        raise notice 'TEST: pas de caractère spéciale';

        perform should_fail($$
        insert into users(id, email, password, full_name, role, phone)
        values (22, 'walid@epfc.eu', 'Password15', 'Test User', 'client', null);
    $$, 'check_violation');
    end
$test$;

rollback;