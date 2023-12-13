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
('first_expedition', 'success', '08-09-2022', '8-10-2022'),
('second_expedition', 'failure', '2-01-2022', '1-03-2022'),
('third_expedition', 'success', '3-04-2020', '3-04-2022'),
('fourth_expedition', 'success', '1-01-2000', '1-01-2022'),
('fifth_expedition', 'failure', '2-04-2030', '2-04-2030'),
('sixth_expedition', 'success', '1-05-2001', '2-06-2002');
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
