set search_path to public, auth;


drop function if exists get_simulated_time();
create or replace function get_simulated_time()
    returns timestamp as

$$
select * from system_time limit 1;
$$ language sql security definer ;

grant execute on function  get_simulated_time() to authenticated, anon;




drop function if exists save_simulated_time(_dateTime timestamp);
create or replace function save_simulated_time(_dateTime timestamp)
    returns timestamp  as
$$
begin
update system_time
set simulated_time = _dateTime
where _dateTime is not null;
return _dateTime;
end;
$$ language plpgsql security definer ;

grant execute on function  save_simulated_time( timestamp) to authenticated, anon;

drop function if exists null_simulated_time();
create or replace function null_simulated_time()
    returns void  as
$$
begin
    update system_time
    set simulated_time = null
    where simulated_time = get_simulated_time();
end;
$$ language plpgsql security definer ;

grant execute on function  null_simulated_time() to authenticated, anon;


