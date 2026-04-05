
/*************************************************************************
    User
*************************************************************************/

-- Le nom complet doit avoir une longueur d'au moins 3 caractères.

alter table users
    drop constraint if exists users_full_name_length_check;


alter table users
add constraint users_full_name_length_check
check ( length(trim(full_name)) >= 3 );