set search_path to public;

-- ne peut pas changer le restaurant ou le client d'une table
begin;
-- table
do
$test$
    begin
        raise notice 'TEST: restaurant lié à une table est inchangeable (cas invalide)';
        perform should_fail($$
            update tables set restaurant = '1' where id = 22;
        $$, 'raise_exception');
    end
$test$;

-- services
do
$test$
begin
        raise notice 'TEST: restaurant lié à un service est inchangeable (cas invalide)';
        perform should_fail($$
            update services set restaurant = '2' where id = 1;
        $$, 'raise_exception');
end
$test$;

-- reservations
do
$test$
    begin
        raise notice 'TEST: restaurant lié à une réservation est inchangeable (cas invalide)';
        perform should_fail($$
            update reservations set restaurant = '2' where id = 1;
        $$, 'raise_exception');

        raise notice 'TEST: client lié à une réservation est inchangeable (cas invalide)';
        perform should_fail($$
            update reservations set client = '1' where id = 1;
        $$, 'raise_exception');
    end
$test$;

rollback;
