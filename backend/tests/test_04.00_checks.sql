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


-- test restaurant name length
do
$$
    begin
        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (10,'resta','Rue neuve','Bruxelles (1)','+32486514357','test1',5,3,15);

        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (11,'restaurant','Rue josse de boek','Bruxelles (2)','+32486514357','test2',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (12,'rest','Rue josse de boek','Bruxelles (3)','+32486514357','test3',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (12,'','Rue josse de boek','Bruxelles (4)','+32486514357','test4',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (12,null,'Rue josse de boek','Bruxelles (5)','+32486514357','test5',5,3,15);
    end;
$$ language plpgsql;


-- test restaurant phone number format

do
$$
    begin
        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (13,'name1','Rue josse de boek','Bruxelles','+32 4 76 51 43 57','test1',5,3,15);

        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (14,'name2','Rue josse de boek','Bruxelles','+32 47 65 14 35','test2',5,3,15);

        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (15,'name3','Rue josse de boek','Bruxelles','+32 476 51 43 57','test3',5,3,15);

        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (16,'name4','Rue josse de boek','Bruxelles','+32476514357','test4',5,3,15);

        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (22,'name5','Rue josse de boek','Bruxelles','+32 2 568 56 45','test5',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (17,'name6','Rue josse de boek','Bruxelles','+33 47 88 12 12','test6',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (18,'name7','Rue josse de boek','Bruxelles','32 456 56 45 21','test7',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (19,'name8','Rue josse de boek','Bruxelles','+32 456 56 45','test8',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (20,'name9','Rue josse de boek','Bruxelles','32 456 56 45 32','test9',5,3,15);

        -- valid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (23,'name10','Rue josse de boek','Bruxelles','+32 2 568 56 45','test10',5,3,15);

        -- invalid
        delete from restaurants where id = 24;
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (24,'name11','Rue josse de boek','Bruxelles','+32 whatever','test11',5,3,15);

        -- invalid
        insert into restaurants (id,name,address,city,phone,description,rating,price_range,slot_duration)
        values (25,'name12','Rue josse de boek','Bruxelles','','test12',5,3,15);
    end;
$$ language plpgsql;