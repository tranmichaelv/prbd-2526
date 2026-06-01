set search_path to public;


create or replace function current_time_for_rules()
returns timestamp as
$$
    select coalesce((
        select  system_time.simulated_time from system_time limit  1),
        now_local()
    );

$$ language sql;

create or replace function reservation_status()
returns trigger as
$$
    begin
        -- INSERT ; une nouvelle réservation doit être pending
        if tg_op = 'INSERT' then
            if new.status is distinct from 'pending' then
                raise exception 'BR-09: new reservation must be pending';
            end if;
            return new;
        end if;

        -- UPDATE : si le status ne change pas -> ok
        if new.status = old.status then
            return new;
        end if;

        -- pending -> confirmed / cancelled
        if old.status = 'pending' and new.status in('confirmed','cancelled') then
            return new;
        end if;

        -- confirmed -> completed / cancelled
        if old.status = 'confirmed' and new.status in('completed', 'cancelled') then
            return new;
        end if;

        -- confirmed -> pending ( seulement si réservation est dans le futur)
        if old.status = 'confirmed' and new.status = 'pending' and new.datetime > current_time_for_rules() then
            return  new;
        end if;

        -- completed et cancelled : aucune transition autorisée
        if old.status in ('completed', 'cancelled') then
            raise exception 'BR-09; no transition allowed from %', old.status;
        end if;

        raise exception 'BR-09 : invalid status transition from % to %', old.status, new.status;
    end;
$$ language plpgsql;


create or replace trigger trg_br_09_resarvation_status
before insert or update on reservations
for  each row
execute function reservation_status()