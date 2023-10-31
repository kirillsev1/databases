begin;
create materialized view expedition_with_explorers_and_equipment as
    with explorer_with_equipment as (
		select ex.id, ex.name, ex.height, ex.width, ex.education, ex.forum,
		json_agg(json_build_object('id', e.id, 'name', e.name, 'product_country', e.production_country)) as equipment
	from explorer ex
		left join explorer_equipment ee on ex.id = ee.explorer_id
		left join equipment e on ee.equipment_id = e.id
		group by ex.id),
	expedition_with_cars as (
		select e.id, e.name, e.expedition_result, e.start_date, e.end_date,
		coalesce (json_agg(json_build_object('id', car.id, 'name', car.name, 'type', car.type)), '[]') as cars
	from expedition e
		left join car_expedition ce on ce.expedition_id = e.id
		left join car on ce.car_id = car.id
		group by e.id)
	select expexp.id, expexp.name, expexp.expedition_result, expexp.start_date, expexp.end_date, jsonb_agg(jsonb_build_object('explorer_id', exaseq.id, 'explorer_name', exaseq.name, 'explorer_height', exaseq.height, 'explorer_width', exaseq.width,
	'equipment', exaseq.equipment, 'education', exaseq.education, 'explorer_forums', exaseq.forum)) as explorers, jsonb_agg(expexp.cars) as cars
	from explorer_with_equipment exaseq
		right join expedition_explorer ex_er on ex_er.explorer_id = exaseq.id
		right join expedition_with_cars expexp on expexp.id = ex_er.expedition_id
	group by expexp.id, expexp.expedition_result, expexp.start_date, expexp.end_date, expexp.name;

drop index if exists expedition_with_explorers_and_equipment_id;
create unique index on expedition_with_explorers_and_equipment(id);

create function refresh_expedition_view()
    returns trigger as
    $$
    begin
        refresh materialized view concurrently expedition_with_explorers_and_equipment;
        return new;
    end
    $$
    language 'plpgsql';

create trigger update_on_expedition
    after insert or update or delete
    on expedition
    for each row
    execute function refresh_expedition_view();

commit;