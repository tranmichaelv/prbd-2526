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

-- test password on table users
do
$$
    begin
        insert into users(id, email, password, full_name, role, phone) -- must succeed
        values (9,'driszekhnini@epfc.eu','Test password1!', 'dris', 'client', null);
        insert into users(id, email, password, full_name, role, phone) -- must succeed
        values (10,'test2@epfc.eu','$2a$06$AqLHN8lgmR/RuJzhUWiEf.TsAnFCIjen3n.j1lLKKY8zoKNPJVZEC', 'Test2 name', 'client', null);
        insert into users(id, email, password, full_name, role, phone) -- must fail
        values (11,'test3@epfc.eu','invalid password', 'Test3 name', 'client', null);
        update users set password = 'Valid password1/' where id = 9; -- must succeed
    end;
$$ language plpgsql;



-- test change role

do
$$
    begin
        update users
        set role = 'manager'
        where id = 10;
    end;
$$ language plpgsql;