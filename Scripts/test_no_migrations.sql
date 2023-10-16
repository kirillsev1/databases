drop table if exists expedition, car, car_expedition, explorer, future_explore, expedition_explorer, equipment, explorer_equipment cascade;

create table if not exists explorer(
	id int primary key generated always as identity,
	name text,
	height int,
	width int
);
create table if not exists equipment(
	id int primary key generated always as identity,
	name text,
	production_country text
);

create table if not exists explorer_equipment(
	explorer_id int references explorer(id),
	equipment_id int references equipment(id)
);

insert into explorer(name, height, width) values
('Tom', 180, 77),
('Jack', 190, 88),
('Ban', 160, 60),
('Bob', 155, 77),
('Jack', 140, 88),
('Ban', 160, 70);

insert into equipment(name, production_country) values
('map', 'China'),
('compass', 'USA'),
('backpack', 'Russia'),
('map-1', 'Russia'),
('compass-3', 'China'),
('backpack', 'USA');

create table if not exists expedition(
	id int primary key generated always as identity,
	name text,
	expedition_result text,
	start_date date,
	end_date date
);
insert into explorer_equipment (explorer_id, equipment_id) values (1, 1), (1, 2), (2, 1), (2, 3);
select * from expedition e ;



create table if not exists car(
	id int generated always as identity primary key,
	name text,
	type text
);

create table if not exists car_expedition(
	car_id int references car(id) on delete cascade,
	expedition_id int references expedition(id) on delete cascade,
	primary key(car_id, expedition_id)
);

create table if not exists expedition_explorer(
	expedition_id int references expedition(id) on delete cascade,
	explorer_id int references explorer(id) on delete cascade
);

insert into expedition (name, expedition_result, start_date, end_date) values 
('first expedition', 'success', '08-09-2022', '8-10-2022'),
('second expedition', 'failure', '2-01-2022', '1-03-2022'),
('third expedition', 'success', '3-04-2020', '3-04-2022'),
('fourth expedition', 'success', '1-01-2000', '1-01-2022'),
('fifth expedition', 'failure', '2-04-2030', '2-04-2030'),
('sixth expedition', 'success', '1-05-2001', '2-06-2002');
select * from expedition;

insert into expedition_explorer(expedition_id, explorer_id) values 
(1, 1),
(2, 2),
(2, 3),
(3, 3),
(4, 4),
(5, 5),
(6, 6);

insert into car(name, type) values
('Jeep', '1-1'),
('Jeep', '2-1'),
('Jeep', '3-1'),
('Jeep', '1-1'),
('Jeep', '2-1'),
('Jeep', '3-1');
select * from car;

insert into car_expedition (car_id, expedition_id) values
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6);
select * from car_expedition;



insert into car_expedition (car_id, expedition_id) values (5, 6);

select * from explorer_equipment;

select * from expedition_explorer exe
join expedition e on exe.expedition_id =e.id
join explorer expl on exe.explorer_id=expl.id ;



select e.id, e.name, e.expedition_result, e.start_date, e.end_date, (jsonb_agg(jsonb_build_object('id', car.id, 'name', car.name, 'type', car.type))) from expedition e
join car_expedition cae on cae.expedition_id=e.id 
join car on cae.car_id=car.id
group by e.id
order by e.id;

with explorer_with_equipment as (select ex.id, ex.name, ex.height, ex.width, coalesce(jsonb_agg(jsonb_build_object('id', e.id, 'name', e.name, 'product_country', e.production_country))filter (where e.id is not null), '[]') from explorer ex
left join explorer_equipment ee on ex.id=ee.explorer_id 
left join equipment e on ee.equipment_id=ee.equipment_id
group by ex.id 
order by ex.id) select jsonb_agg(jsonb_build_object('explorer_id', exaseq.id, 'explorer_name', exaseq.name, 'explorer_height', exaseq.height, 'explorer_width', exaseq.width, 'equipment', exaseq.coalesce)) from explorer_with_equipment exaseq
join expedition_explorer ex_er on ex_er.explorer_id=exaseq.id
group by exaseq.id
order by exaseq.id;

with expedition_with_explorer as (select e.id, e.name, e.expedition_result, e.start_date, e.end_date, (jsonb_agg(jsonb_build_object('id', car.id, 'name', car.name, 'type', car.type))) from expedition e
	join car_expedition cae on cae.expedition_id=e.id 
	join car on cae.car_id=car.id
	group by e.id
	order by e.id), equipment_with_explorer as (select ex.id, ex.name, ex.height, ex.width, coalesce(jsonb_agg(jsonb_build_object('id', e.id, 'name', e.name, 'product_country', e.production_country))filter (where e.id is not null), '[]') from explorer ex
	left join explorer_equipment ee on ex.id=ee.explorer_id 
	left join equipment e on ee.equipment_id=ee.equipment_id
	group by ex.id 
	order by ex.id)select * from expedition_with_explorer expexp
left join equipment_with_explorer eqex on eqex.id=expexp.id;






with explorer_with_equipment as (
		select ex.id, ex.name, ex.height, ex.width,
		coalesce(json_agg(json_build_object('id', e.id, 'name', e.name, 'product_country', e.production_country)) filter (where e.id is not null), '[]') as equipment
	from explorer ex
		left join explorer_equipment ee on ex.id = ee.explorer_id
		left join equipment e on ee.equipment_id = e.id
		group by ex.id),
	expedition_with_cars as (
		select e.id, e.name, e.expedition_result, e.start_date, e.end_date,
		json_agg(json_build_object('id', car.id, 'name', car.name, 'type', car.type)) as cars
	from expedition e
		join car_expedition ce on ce.expedition_id = e.id
		join car on ce.car_id = car.id
		group by e.id)
	select expexp.id, expexp.expedition_result, expexp.start_date, expexp.end_date, jsonb_agg(jsonb_build_object('explorer_id', exaseq.id, 'explorer_name', exaseq.name, 'explorer_height', exaseq.height, 'explorer_width', exaseq.width,
	'equipment', exaseq.equipment, 'cars', expexp.cars)) as explorers
	from explorer_with_equipment exaseq
		join expedition_explorer ex_er on ex_er.explorer_id = exaseq.id
		join expedition_with_cars expexp on expexp.id = ex_er.expedition_id
	group by expexp.id, expexp.expedition_result, expexp.start_date, expexp.end_date;



begin;

create extension if not exists "uuid-ossp";

alter table car_expedition
	drop constraint car_expedition_car_id_fkey;

alter table car_expedition
	drop constraint car_expedition_expedition_id_fkey;

alter table car_expedition
	rename column car_id to old_car_id;

alter table car_expedition
	rename column expedition_id to old_expedition_id;

alter table car_expedition
	add column car_id uuid;

alter table car_expedition
	add column expedition_id uuid;



alter table expedition_explorer
	drop constraint expedition_explorer_expedition_id_fkey;

alter table expedition_explorer
	drop constraint expedition_explorer_explorer_id_fkey;

alter table expedition_explorer
	rename column explorer_id to old_explorer_id;

alter table expedition_explorer
	rename column expedition_id to old_expedition_id;

alter table expedition_explorer
	add column explorer_id uuid;

alter table expedition_explorer
	add column expedition_id uuid;



alter table explorer_equipment
	drop constraint explorer_equipment_explorer_id_fkey;

alter table explorer_equipment
	drop constraint explorer_equipment_equipment_id_fkey;

alter table explorer_equipment
	rename column explorer_id to old_explorer_id;

alter table explorer_equipment
	rename column equipment_id to old_equipment_id;

alter table explorer_equipment
	add column explorer_id uuid;

alter table explorer_equipment
	add column equipment_id uuid;


alter table car
	rename column id to old_id;

alter table car
	add column id uuid default uuid_generate_v4();



alter table equipment
	rename column id to old_id;

alter table equipment 
	add column id uuid default uuid_generate_v4();



alter table expedition
	rename column id to old_id;

alter table expedition
	add column id uuid default uuid_generate_v4();



alter table explorer
	rename column id to old_id;

alter table explorer
	add column id uuid default uuid_generate_v4();



do
$$
	declare 
		car_row record;
	begin
		for car_row in select * from car
			loop
				update car_expedition set car_id = car_row.id where old_car_id = car_row.old_id;
			end loop;
		
	end
	
$$;



do
$$
	declare
		explorer_row record;
	begin
		for explorer_row in select * from explorer
			loop
				update expedition_explorer set explorer_id = explorer_row.id where old_explorer_id = explorer_row.old_id;
				update explorer_equipment set explorer_id = explorer_row.id where old_explorer_id = explorer_row.old_id;
			end loop;
			
	end
	
$$;



do
$$
	declare
		equipment_row record;
	begin
		for equipment_row in select * from equipment
			loop
				update explorer_equipment set equipment_id = equipment_row.id where old_equipment_id = equipment_row.old_id;
			end loop;
			
	end
	
$$;



do
$$
	declare
		expedition_row record;
	begin
		for expedition_row in select * from expedition
		loop
			update expedition_explorer set expedition_id = expedition_row.id where old_expedition_id = expedition_row.old_id;
			update car_expedition set expedition_id = expedition_row.id where old_expedition_id = expedition_row.old_id;
		end loop;
		
	end
	
$$;



alter table car 
	drop constraint car_pkey;

alter table car 
	drop column old_id;

alter table car 
	add primary key(id);



alter table expedition  
	drop constraint expedition_pkey;

alter table expedition 
	drop column old_id;

alter table expedition  
	add primary key(id);
	


alter table equipment  
	drop constraint equipment_pkey;

alter table equipment 
	drop column old_id;

alter table equipment  
	add primary key(id);
	


alter table explorer  
	drop constraint explorer_pkey;

alter table explorer 
	drop column old_id;

alter table explorer 
	add primary key(id);
	


alter table expedition_explorer 
	drop column old_expedition_id;

alter table expedition_explorer 
	drop column old_explorer_id;

alter table expedition_explorer 
	add constraint fk_expedition_id foreign key (expedition_id) references expedition;

alter table expedition_explorer 
	add constraint fk_explorer_id foreign key (explorer_id) references explorer;



alter table car_expedition
	drop column old_car_id;

alter table car_expedition
	drop column old_expedition_id;

alter table car_expedition
	add constraint fk_car_id foreign key (car_id) references car;

alter table car_expedition
	add constraint fk_expedition_id foreign key (expedition_id) references expedition;



alter table explorer_equipment
	drop column old_explorer_id;

alter table explorer_equipment
	drop column old_equipment_id;

alter table explorer_equipment
	add constraint fk_explorer_id foreign key (explorer_id) references explorer;

alter table explorer_equipment
	add constraint fk_equipment_id foreign key (equipment_id) references equipment;



commit;




create index expedition_start_date on expedition using btree(start_date);
create index expedition_start_date_expedition_result on expedition using btree(start_date, expedition_result);
create index expedition_name on expedition using hash(name);

drop materialized view expedition_with_explorers_and_equipment;
drop index if exists expedition_with_explorers_and_equipment_id;
drop trigger update_on_expedition on expedition;
rollback
begin;
create materialized view expedition_with_explorers_and_equipment as
    with explorer_with_equipment as (
		select ex.id, ex.name, ex.height, ex.width,
		json_build_object('id', e.id, 'name', e.name, 'product_country', e.production_country) as equipment
	from explorer ex
		left join explorer_equipment ee on ex.id = ee.explorer_id
		left join equipment e on ee.equipment_id = e.id
		group by ex.id, e.id),
	expedition_with_cars as (
		select e.id, e.name, e.expedition_result, e.start_date, e.end_date,
		coalesce (json_agg(json_build_object('id', car.id, 'name', car.name, 'type', car.type)), '[]') as cars
	from expedition e
		left join car_expedition ce on ce.expedition_id = e.id
		left join car on ce.car_id = car.id
		group by e.id)
	select expexp.id, expexp.name, expexp.expedition_result, expexp.start_date, expexp.end_date, jsonb_agg(jsonb_build_object('explorer_id', exaseq.id, 'explorer_name', exaseq.name, 'explorer_height', exaseq.height, 'explorer_width', exaseq.width,
	'equipment', exaseq.equipment)) as explorers, jsonb_agg(expexp.cars) as cars
	from explorer_with_equipment exaseq
		right join expedition_explorer ex_er on ex_er.explorer_id = exaseq.id
		right join expedition_with_cars expexp on expexp.id = ex_er.expedition_id
	group by expexp.id, expexp.expedition_result, expexp.start_date, expexp.end_date, expexp.name;


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
select * from expedition e 
select * from expedition_with_explorers_and_equipment
insert into expedition (name, expedition_result, start_date, end_date) values 
('last one expedition', 'success', '08-09-2022', '8-10-2022');
insert into expedition_explorer (explorer_id, expedition_id) values('cbd76a7f-bbdc-44f3-9b15-35707a362935', 'e5da48a7-8245-42aa-aac5-41d7a8205bc2')
insert into car_expedition (car_id, expedition_id) values ('0d258e53-b720-45d6-8dab-38ad64ae755e', 'd320096b-fe13-4702-9fc1-0bfcd2d04e2b')
select * from expedition;
select * from explorer;
select * from car;

