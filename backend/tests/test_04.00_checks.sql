set search_path to public;


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