set search_path to public;

create or replace function restaurant_must_have_manager()
    returns trigger as
$$
begin
    -- après suppression d'un manager
    if tg_op = 'DELETE' then
        if not exists (
            select 1
            from restaurant_managers
            where restaurant = old.restaurant
        ) then
            raise exception 'BR-10: a restaurant must have at least one manager';
        end if;

        return old;
    end if;

    -- après update
    if tg_op = 'UPDATE' then
        if not exists (
            select 1
            from restaurant_managers
            where restaurant = old.restaurant
        ) then
            raise exception 'BR-10: a restaurant must have at least one manager';
        end if;

        return new;
    end if;

    return null;
end;
$$ language plpgsql;



create trigger trg_br_10_restaurant_manager
    after delete or update
    on restaurant_managers
    for each row
execute function restaurant_must_have_manager();