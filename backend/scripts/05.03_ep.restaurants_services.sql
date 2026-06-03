set search_path to public;


create or replace function get_restaurants_services(_restaurant_id integer)
returns table ( id integer, day_of_week integer, start_time time, end_time time)
language sql security definer  as
$$
    select  s.id ,s.day_of_week, s.start_time, s.end_time
    from services s
    where s.restaurant = _restaurant_id
    order by s.day_of_week, s.start_time;
$$;


grant execute on function get_restaurants_services(integer) to anon, authenticated;