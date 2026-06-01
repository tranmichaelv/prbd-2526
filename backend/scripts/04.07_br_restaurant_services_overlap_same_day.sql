set search_path to public;

create or replace function services_overlap_same_day_fct() returns trigger as
    $$
    begin
        if new.start_time >= new.end_time then
            raise exception 'l''heure de début doit être avant l heure de fin';
        end if;
        if exists(
            select
                 1
            from
                services s
            where
                s.restaurant = new.restaurant
                and s.id <> new.id -- gère le cas d'un update
                and s.day_of_week = new.day_of_week
                and  new.start_time < s.end_time
                and new.end_time > s.start_time
        ) then
            raise exception 'Les services ne peuvent pas se chevaucher';
        end if;
        return new;
    end;
    $$ language plpgsql;

create or replace trigger tg_overlap_same_day
    before insert or update
    on services
    for each row
    execute function services_overlap_same_day_fct();


