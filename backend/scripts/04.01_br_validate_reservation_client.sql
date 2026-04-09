
create or replace function validate_reservation_client_role()
    returns trigger AS
$$
begin
        if not exists(
            select 1
            from users
            where id = new.client
            and role = 'client'
        ) then
            raise exception 'BR-01 :  Une réservation doit être associée à un utilisateur ayant le rôle de clien';
end if;
return new;
end;
$$ language plpgsql;

drop trigger if exists trg_validate_reservation_client_role on reservations;
create trigger trg_validate_reservation_client_role
    before insert or update on reservations
                         for each row
                         execute function validate_reservation_client_role();