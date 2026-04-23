set search_path to public;

-- (BR-14) Une réservation ne peut pas être créée dans le passé (ne doit être vérifié qu'au moment de la création)

create or replace function cannot_create_reservation_from_past()
    returns trigger as
$$
begin
    if new.datetime < current_time_for_rules() then
        raise exception 'BR-14 : Une réservation ne peut pas être créée dans le passé';
    end if;
    return new;
end;
$$ language plpgsql security definer;

create or replace trigger  trg_br_14_cannot_create_reservation_from_past
    before insert
    on reservations
    for each row
execute function cannot_create_reservation_from_past();