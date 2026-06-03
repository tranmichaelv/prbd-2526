set search_path to public, auth;


drop function if exists get_simulated_time();
create or replace function get_simulated_time()
    returns timestamp as

$$
select * from current_time_for_rules();
$$ language sql security definer ;

grant execute on function  get_simulated_time() to authenticated;




drop function if exists save_simulated_time(_dateTime timestamp);
create or replace function save_simulated_time(_dateTime timestamp)
    returns timestamp  as
$$
begin
update system_time
set simulated_time = _dateTime
where simulated_time = get_simulated_time();
return _dateTime;
end;
$$ language plpgsql security definer ;

grant execute on function  save_simulated_time(_dateTime timestamp) to authenticated;