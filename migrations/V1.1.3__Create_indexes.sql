create index expedition_start_date on expedition using btree(start_date);
create index expedition_start_date_expedition_result on expedition using btree(start_date, expedition_result);
create index expedition_name on expedition using hash(name);
