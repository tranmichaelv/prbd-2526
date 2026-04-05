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

rollback;