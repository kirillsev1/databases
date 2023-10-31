alter table explorer add column forum text[];


update explorer set forum = (
    '{
        "ResearchGate",
        "Academia.edu",
        "Reddit - AskAcademia"
    }'
) where height >= 160;


update explorer set forum = (
    '{
        "Stack Exchange - Academia",
        "ResearchGate",
        "Elsevier Community"
    }'
) where height < 160;

create index explorer_forum on explorer using gin (forum);

begin;
create materialized view explorer_and_equipment as
    with explorer_with_equipment as (
        select ex.id, ex.name, ex.height, ex.width, ex.education, ex.forum,
        json_agg(json_build_object('id', e.id, 'name', e.name, 'product_country', e.production_country)) as equipment
    from explorer ex
        left join explorer_equipment ee on ex.id = ee.explorer_id
        left join equipment e on ee.equipment_id = e.id
        group by ex.id)
    select id, name, height, width, education, equipment, forum from explorer_with_equipment;


drop index if exists explorers_and_equipment_id;
create unique index on explorer_and_equipment(id);

create function refresh_explorer_view()
    returns trigger as
    $$
    begin
        refresh materialized view concurrently explorers_and_equipment;
        return new;
    end
    $$
    language 'plpgsql';

create trigger update_on_explorer
    after insert or update or delete
    on explorer
    for each row
    execute function refresh_explorer_view();

commit;