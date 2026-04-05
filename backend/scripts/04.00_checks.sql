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