
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