set search_path to public;

create or replace function reservation_locked_when_completed_or_cancelled()
returns trigger as
$$
    begin
        if old.status in ('completed','cancelled') then
            raise exception 'BR-11:completed or cancelled reservations cannot be modified';
        end if;
        return new;
    end;
$$ language plpgsql;

create trigger trg_br_11_reservation_locked
    before update on reservations
    for each row
execute function reservation_locked_when_completed_or_cancelled();