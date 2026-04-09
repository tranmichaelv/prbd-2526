set search_path to public;
/*************************************************************************
    User
*************************************************************************/

-- Le nom complet doit avoir une longueur d'au moins 3 caractères.

alter table users
    drop constraint if exists users_full_name_length_check;

alter table users
add constraint users_full_name_length_check
check ( length(trim(full_name)) >= 3 );

-- MDP >= 8 + chiffre + MAJ + MIN + carac spéciale
alter table users
    drop constraint if exists users_password_ok_check;

alter table users
add constraint users_password_ok_check
check ( password ~ '^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[,;.:!?/$%&@#]).{8,}$');

-- ################ TABLE #############################
alter table tables
    drop constraint if exists only_positive_tables_number_check;

alter table tables
add constraint only_positive_tables_number_check
check (table_number > 0);


alter table tables
    drop constraint if exists only_positive_tables_capacity_check;

alter table tables
    add constraint only_positive_tables_capacity_check
        check (capacity > 0);

-- ################ SERVICES #############################
alter table services
    drop constraint if exists must_be_day_of_the_week_check;

alter table services
    add constraint must_be_day_of_the_week_check
        check (day_of_week >= 1 and day_of_week <= 7 );

alter table services
    drop constraint if exists service_time_check;

ALTER TABLE services
    ADD CONSTRAINT service_time_check
        CHECK (end_time >= start_time + INTERVAL '1 hour');

