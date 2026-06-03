create  or replace function  save_restaurant_service(
    _service_id integer,
    _restaurant_id integer,
    _day_of_week integer,
    _start_time time,
    _end_time time
) returns integer
  language plpgsql security definer as
$$
    declare
        result_id integer;
    begin
        perform auth.check_manager_logged();
        if _service_id is null then
            insert into services(restaurant, day_of_week, start_time, end_time)
            VALUES (_restaurant_id, _day_of_week, _start_time, _end_time)
            returning id into result_id;
        else
            update services
            set day_of_week = _day_of_week, start_time = _start_time, end_time = _end_time
            where id = _service_id
            and restaurant = _restaurant_id
            returning  id into result_id;
        end if;

        return  result_id;
    end;
$$;

grant execute on function  save_restaurant_service(integer, integer, integer, time,time) to  authenticated;