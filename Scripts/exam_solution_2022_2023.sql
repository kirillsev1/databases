/*
1. Вывести названия продуктов (без повторений) из бронзы или гранита и ценой от 3_000 до 7_000
2. Вывести названия компаний, содержащие в названии цифры.
3. Вывести названия компаний (без повторений), поставляющие компьютеры, но не клавиатуры.
4. Вывести названия компаний (без повторений), поставляющие как машины, так и мотоциклы.
5. Для компании, имеющей максимальную суммарную грузоподъемность, вывести минимальную цену продуктов.
6. Для каждой компании, имеющей суммарную грузоподъемность транспортых средств более 100, вывести количество продуктов компании.
7. Вывести названия компаний, имеющих товаров на сумму не менее 1_000_000_000 или не менее 10 единиц транспорта.
*/

/*1*/
select distinct xiq.name from supplier_goods_info_wcj wc
join goods_62l g62 on g62.id = wc.goods_id 
join supplier_xiq xiq on xiq.id = wc.supplier_id 
where g62.material = 'Bronze' or g62.material = 'Granite' and 3000 <= wc .price and wc .price <= 7000 
/*1*/

/*2*/
select * from supplier_xiq where name ~ '[0-9]+'
/*2*/

/*3*/
select distinct xiq.name from supplier_goods_info_wcj wc
join goods_62l g62 on g62.id = wc.goods_id 
join supplier_xiq xiq on xiq.id = wc.supplier_id 
where g62.name = 'Computer' and xiq.name not in (
	select xiq.name from supplier_goods_info_wcj wc
	join goods_62l g62 on g62.id = wc.goods_id 
	join supplier_xiq xiq on xiq.id = wc.supplier_id
	where g62.name = 'Keyboard'
)
/*3*/

/*4*/
select distinct xiq.name from supplier_goods_info_wcj wc
join goods_62l g62 on g62.id = wc.goods_id 
join supplier_xiq xiq on xiq.id = wc.supplier_id 
where g62.name = 'Car' and xiq.name in (
	select xiq.name from supplier_goods_info_wcj wc
	join goods_62l g62 on g62.id = wc.goods_id 
	join supplier_xiq xiq on xiq.id = wc.supplier_id
	where g62.name = 'Bike'
)
/*4*/

/*5*/
with temp as (
	select xiq.id, sum(vi.load_capacity) as total_load from vehicle_ixo vi
	join supplier_xiq xiq on vi.supplier_id = xiq.id 
	group by xiq.id
)
select xiq.name from supplier_xiq xiq
join temp tm on tm.id=xiq.id
where tm.total_load in (select max(tm.total_load) from temp tm)
/*5*/

/*6*/
with temp as (
	select xiq.id, sum(vi.load_capacity) as total_load from vehicle_ixo vi
	join supplier_xiq xiq on vi.supplier_id = xiq.id 
	group by xiq.id
)
select xiq.name, sum(wc.quantity) from supplier_goods_info_wcj wc
join supplier_xiq xiq on xiq.id = wc.supplier_id
join temp tm on tm.id=xiq.id
where tm.total_load >= 100
group by xiq.name
/*6*/

/*7*/
with cars as (
	select xiq.id, xiq.name, count(xiq.name) as number_of_cars from vehicle_ixo vi 
	join supplier_xiq xiq on vi.supplier_id = xiq.id 
	group by xiq.name, xiq.id
)
select wc.supplier_id, sum(wc.price*wc.quantity) from supplier_goods_info_wcj wc
join cars on cars.id = wc.supplier_id
group by wc.supplier_id
having sum(wc.price*wc.quantity) >= 100000000 or (select count(*) from cars where id = wc.supplier_id) >= 10
/*7*/

drop table if exists supplier_xiq, goods_62l, supplier_goods_info_wcj, vehicle_ixo cascade;

create table supplier_xiq
(
    id      uuid primary key,
    name    text,
    address text,
    phone   text
);

create table goods_62l
(
    id       uuid primary key,
    name     text,
    material text
);

create table supplier_goods_info_wcj
(
    goods_id  uuid references goods_62l,
    supplier_id uuid references supplier_xiq,
    primary key (goods_id, supplier_id),
    price       numeric,
    quantity    integer
);

create table vehicle_ixo
(
    id                uuid primary key,
    registration_mark text,
    load_capacity     integer,
    supplier_id uuid references supplier_xiq
);

insert into supplier_xiq values
('37db7326-7ac9-4804-97fd-f76da33c01a1', 'Medhurst, Batz and Zieme', '1970 Hilda Curve', '739.706.1867'),
('b5bf55de-7675-415a-9350-f777acab0120', 'Wisozk Inc', '028 White Lane', '439-991-7721 x4340'),
('de21664a-dc56-48cb-b24a-e89f1ab57dcd', 'Wisoky, Stanton and Barton', '34003 Walter Rest', '312.259.4750 x562'),
('d9b990c8-98e7-4ed4-9620-76715f9448cc', 'Cartwright, Stracke and Towne', '2200 Boehm Forest', '228-471-0223'),
('fbcc1cab-c1c3-4e04-ba6e-f56b98407496', 'Romaguera - Weber', '3691 Spinka Causeway', '617-918-8682 x79608'),
('9fe7a6c0-802c-4f46-b51d-c90cef9cb38f', 'Boyer, O''Hara and Spinka', '803 Conroy Station', '717-557-4211 x58497'),
('95553969-a023-407e-b97d-d755aad5dd68', 'Bauch, Wiegand and Kunde', '8836 Ebert River', '(247) 281-7994 x1400'),
('7917d6b5-6d6c-4e73-ac62-59400054cf0a', 'Renner and Sons', '4290 Arlene Courts', '1-253-560-9364 x665'),
('acee385d-5fd9-49e6-a21b-bbf1a8109163', 'Brown, Gislason and Rolfson', '289 McDermott Forges', '1-205-220-3889 x337'),
('4b3edfd8-a1ad-4f15-928d-727ff814ffad', 'Ruecker and Sons', '811 O''Hara Points', '1-276-818-8945 x6921'),
('27e72c8e-9462-48ad-9dfb-2c124c9a76ee', 'Wisoky LLC', '2073 White Rapid', '964-286-6591'),
('d09f9ca9-5c22-4376-983a-9aed513a562a', 'Gottlieb - Nienow', '39040 Willms Passage', '1-776-431-7847 x89195'),
('a6cda5b2-fcac-444e-8971-0bf2430d6110', 'White, Thompson and Harvey', '919 Funk Streets', '448.716.3867 x4714'),
('bd48a611-3639-494d-86f5-9be8db540274', 'Rutherford, Harber and Williamson', '38691 Johns Ranch', '363.556.9411'),
('276c4517-d5af-4eec-93f0-44933b96240c', 'Satterfield, Terry and Dicki', '0673 Justen Prairie', '787-675-6231 x22168'),
('aa682ae7-0259-4a09-8f76-ecd4007bc109', 'Bayer - Beier', '361 Eudora Falls', '1-780-590-7796 x29101'),
('f883023f-496c-46a4-a179-38185d1ac2a6', 'Will Inc', '527 Enrique Groves', '1-869-817-0004 x912'),
('90ab7cc0-1c38-49b0-9ebd-819b2fcc75be', 'Wisoky, Barton and Stokes', '2042 Elias Islands', '1-646-213-8609 x3208'),
('f9eb3dc9-be2b-42c5-a0fa-62312fa9668a', 'Lubowitz Group', '7865 Hoeger Road', '661-997-0669'),
('1dc5f17f-8d63-458a-ae44-aafe7237d1c2', 'Bartell - Torphy', '1604 Connelly Inlet', '803.636.9098 x329');

insert into goods_62l values
('337d24fd-28fe-4e01-9a8d-19202c20b890', 'Sausages', 'Bronze'),
('6b81f8ee-1087-4fa9-88eb-d4747c4cc080', 'Shirt', 'Soft'),
('acaa6871-a56c-479d-97fa-898b5ca77d0f', 'Sausages', 'Rubber'),
('13826020-22d9-4d00-a0bf-9d08681b61f1', 'Gloves', 'Wooden'),
('a5ba5839-fbe4-4bee-871a-44b313e4f52a', 'Fish', 'Granite'),
('623a3d0f-f113-4719-ac8c-5de0f15c7cb8', 'Mouse', 'Granite'),
('6134da7a-f06d-4d15-b22b-f0e8cc4a21a9', 'Salad', 'Concrete'),
('b342c4f2-704c-462a-9960-3e91be90f4da', 'Hat', 'Metal'),
('50810205-d784-4107-b7d7-de66293a1591', 'Gloves', 'Rubber'),
('4eda243a-682a-46be-864d-b686f613c605', 'Hat', 'Metal'),
('d1e4f93a-eb22-4887-886a-e1d2df1a0642', 'Car', 'Soft'),
('62a32d00-672e-46f6-91a9-826371c39a17', 'Sausages', 'Plastic'),
('e6a5332a-0dc9-44f0-be61-7a768bcb9737', 'Pizza', 'Wooden'),
('4e25e86b-dc88-4732-a507-c9abee6301b0', 'Ball', 'Fresh'),
('f3e2ca42-9059-45bf-8889-2581862d5154', 'Bacon', 'Wooden'),
('b1f76963-6429-49c7-8bf4-2fd1761074e9', 'Pizza', 'Steel'),
('184e0df2-47ee-4b9b-928f-e91f2f163f44', 'Chair', 'Frozen'),
('a4b4115d-b111-4ed6-89e2-72c9dc2cd56e', 'Towels', 'Cotton'),
('1156030f-3d2b-4459-b8c0-17b752785b37', 'Salad', 'Bronze'),
('2ad53dd8-632f-4278-8949-0614167e0e5b', 'Hat', 'Wooden'),
('0742e007-7161-4f3d-94d0-54450bd0f57d', 'Sausages', 'Plastic'),
('024c024b-243d-4494-934c-8faa6a9f79ef', 'Bike', 'Frozen'),
('6280f24d-a3e6-4067-ba26-e52cad4bc357', 'Table', 'Plastic'),
('a76a105b-7ec5-47cb-b615-9f5599c8b2ef', 'Table', 'Fresh'),
('571aa8ac-cd84-4c6f-895f-effd67eec9ea', 'Chicken', 'Cotton'),
('127da6f5-a0d2-4d38-8052-2901465093c0', 'Sausages', 'Fresh'),
('86b12d6e-6ee0-463c-a694-a65ae6fe3c86', 'Sausages', 'Bronze'),
('14c795a9-cdb0-40a5-b60f-ccbedc4bb20d', 'Bacon', 'Granite'),
('d7b3c8c8-f480-4e3d-b716-091cf4c38093', 'Car', 'Frozen'),
('40ea219a-caa8-428e-91b4-b7e9f30f8746', 'Hat', 'Concrete'),
('9aacf45f-5715-4c06-b2da-f53ea6cdf787', 'Cheese', 'Bronze'),
('1893adeb-7e41-416f-a43c-2a381f6c4181', 'Chicken', 'Rubber'),
('e9b7fe85-4bc2-4127-846e-15f484689ad9', 'Table', 'Fresh'),
('1638e364-5cf6-41e6-b6f9-45a227f5f355', 'Chicken', 'Steel'),
('619b989d-0f55-41dd-a5a9-5da6d623ab68', 'Salad', 'Cotton'),
('42c30159-44d1-478e-85e1-bc68a06dcd6d', 'Soap', 'Soft'),
('16be86e0-4eb4-49a4-9938-60b88ffcf6e5', 'Mouse', 'Cotton'),
('4f909f0e-01de-4db3-9c23-7d7ed46cdcb4', 'Pants', 'Soft'),
('c4794b34-a602-4b24-9cb1-2fe7a2a8c4f4', 'Pants', 'Steel'),
('b19f8d95-6787-49e8-81e0-4d4298a624dc', 'Soap', 'Rubber'),
('65a53561-abb3-4832-a970-e5d261ca1cd9', 'Gloves', 'Fresh'),
('cf700697-03e8-4513-b337-effacb27242e', 'Ball', 'Metal'),
('d71ddaea-f16e-4fa1-af16-bdad72e49aeb', 'Shoes', 'Granite'),
('6569a1c6-de81-46d0-af3b-52af27e50e70', 'Fish', 'Metal'),
('f5c39ca8-7aaf-4d9a-8aa0-0b4f06b7e201', 'Computer', 'Soft'),
('65709c47-02ad-42e7-93b5-ffba2596eb12', 'Bike', 'Steel'),
('3006395b-e511-4505-8165-9ab39f5d70c1', 'Mouse', 'Wooden'),
('36b5dbe6-6dff-4620-939e-1056c687e60f', 'Cheese', 'Cotton'),
('73521175-c041-4828-a064-88c6835c5ed4', 'Salad', 'Granite'),
('fad08c2f-9e1b-4984-bf34-d652c6e12bfc', 'Bike', 'Plastic'),
('1158db3d-c89e-4838-9fe7-eace6952f76e', 'Tuna', 'Cotton'),
('5a950d59-b852-436a-b6c2-abe93e27ed8c', 'Cheese', 'Plastic'),
('8bf9b948-0699-4704-87ac-580a903e8e06', 'Keyboard', 'Steel'),
('8cec709c-62d2-4e43-8e02-79c2f0a8ba8d', 'Shirt', 'Steel'),
('31e40adb-a178-4e3d-97c7-a733853ecef5', 'Keyboard', 'Frozen'),
('153657b5-70a4-4fb5-ae4c-e53556e715a8', 'Salad', 'Frozen'),
('731a1ce5-c088-4354-bf54-54302748d1ed', 'Ball', 'Plastic'),
('585336df-f64c-4e58-a900-7745fe54112d', 'Cheese', 'Plastic'),
('597cc410-aee8-47db-8b33-b31c6015f55a', 'Soap', 'Soft'),
('ea94ca12-c1a6-46f2-9df6-09baa8d1cf91', 'Car', 'Wooden'),
('5ac2de97-1567-4d23-b925-a3633ec04ded', 'Pants', 'Granite'),
('91e8d8e7-7261-48f2-a365-3073b27c1994', 'Shirt', 'Fresh'),
('aa268d64-6d8d-4392-a4fe-b2b9e5cdbe0c', 'Chair', 'Metal'),
('9c0c137c-5a39-4249-a891-a2ef4d255997', 'Pants', 'Plastic'),
('3bd4685c-9f84-4c8c-8a30-a5ac8f34a4bc', 'Keyboard', 'Soft'),
('bd48b92e-113c-44cf-9066-3ac03ffc107a', 'Chicken', 'Frozen'),
('be9bf5c6-66e2-4d05-9a6b-86248abf67b1', 'Computer', 'Steel'),
('8d34fb6d-ab18-4cac-bb04-809c7f57028c', 'Chips', 'Metal'),
('bca7be70-e3ad-4e60-9cb3-75fac950643e', 'Pizza', 'Rubber'),
('a521079f-60a4-4f81-9787-f68d7696250a', 'Mouse', 'Bronze'),
('cc8504b9-e043-4a13-a8fa-7211c3ffdb24', 'Car', 'Frozen'),
('a7d7215c-fe11-4b5b-a26b-cc1b0b9ebd86', 'Cheese', 'Granite'),
('dc659510-2177-461e-8ffd-4e67752ddd51', 'Tuna', 'Granite'),
('1b3dcdcc-24aa-4fdf-8a30-318c4796863a', 'Shirt', 'Granite'),
('c1900209-3110-418c-8dee-e25816ad77ab', 'Shoes', 'Rubber'),
('c68cc17a-e7d6-4a44-afbf-fd0ccd6a3cb4', 'Table', 'Granite'),
('fb671199-93b1-45b2-b42f-0aebee83abe2', 'Fish', 'Bronze'),
('0538f747-b05a-4757-8f60-ed485c670337', 'Keyboard', 'Soft'),
('adf75a4d-c803-43c7-be91-f8f1d1953be2', 'Fish', 'Granite'),
('6bb504f8-ac27-447b-8041-bd206262d9f0', 'Computer', 'Bronze'),
('d30c3919-838c-43ed-9ee5-aab3a8bebf36', 'Cheese', 'Cotton'),
('1ba62107-1c1a-488d-95f8-6297f9d24751', 'Keyboard', 'Rubber'),
('cec645b3-ffe1-42b6-be16-adcd09516fe3', 'Fish', 'Concrete'),
('f7e8b735-90e2-437c-87d4-691986416005', 'Bike', 'Plastic'),
('eb06c62e-177b-416f-a625-e6601ada9fa7', 'Chicken', 'Rubber'),
('1c3f6b47-ad9c-4e20-bbfe-82abaf00b382', 'Chair', 'Concrete'),
('e21dec99-efa2-464f-8374-d07676f998d4', 'Keyboard', 'Soft'),
('2f0f0a21-81cf-455a-b118-bb506462ad6b', 'Gloves', 'Bronze'),
('4b92e12c-6d15-4b9c-8032-8da03c3e1d4c', 'Computer', 'Granite'),
('9b6ce90e-165d-4651-bafb-06096b928826', 'Soap', 'Concrete'),
('f86f7f99-c355-4a8b-b946-69077e78b917', 'Chicken', 'Cotton'),
('0ef1b032-d566-4394-82c7-3aeacb6667d7', 'Table', 'Frozen'),
('ab2d697c-31c7-4243-b243-df5c9dd45f21', 'Gloves', 'Frozen'),
('d156851c-131a-4f5b-8648-a8fd6c8aeeba', 'Pizza', 'Frozen'),
('bc9566b1-6d73-4e36-bebf-ee5a4f6fab80', 'Car', 'Cotton'),
('2532fb43-3196-4636-addd-3adca6383ee8', 'Chicken', 'Concrete'),
('2ed5c657-3474-4c61-a492-04aee3709f5b', 'Car', 'Fresh'),
('c25ccb22-5d92-42e2-8051-b610791c6abc', 'Table', 'Cotton'),
('91dd71e8-d9b6-4cd8-aed1-09639777d5c3', 'Chicken', 'Fresh'),
('9b23d7c2-f1e6-4f11-8fae-2453098890aa', 'Keyboard', 'Bronze');

insert into vehicle_ixo values
('6b16e2e5-3ba3-423a-aaf6-5e7d098a51a2', 'JH02IRR', '10', '9fe7a6c0-802c-4f46-b51d-c90cef9cb38f'),
('feb9f820-fcfa-4a8a-adc8-120498fbf6a0', 'WS77TRF', '5', 'bd48a611-3639-494d-86f5-9be8db540274'),
('be7a5e0e-97f1-426f-8a4f-8197030e93e1', 'XP53DDE', '30', '27e72c8e-9462-48ad-9dfb-2c124c9a76ee'),
('acb1a802-1940-43ab-9f66-33141c1d5cb4', 'AV53NQG', '10', '37db7326-7ac9-4804-97fd-f76da33c01a1'),
('fa95a368-323c-41ee-bd9b-c78c6a584441', 'LO41LED', '10', 'f9eb3dc9-be2b-42c5-a0fa-62312fa9668a'),
('edf8b91f-74ca-4727-9e72-0f618fabea5d', 'WP04COJ', '30', 'f9eb3dc9-be2b-42c5-a0fa-62312fa9668a'),
('6038d700-2e1d-4f6d-b090-db016d786910', 'MU99UYO', '5', 'd9b990c8-98e7-4ed4-9620-76715f9448cc'),
('90994e88-bf3e-4577-88d1-9f2e6a9dd426', 'GI53BQF', '30', '37db7326-7ac9-4804-97fd-f76da33c01a1'),
('73cd7c41-6eee-4f7a-9b4e-6b690f761e75', 'BC26FJO', '10', 'de21664a-dc56-48cb-b24a-e89f1ab57dcd'),
('6d16a808-5d49-415a-97cc-94047abe304a', 'PJ51EXG', '5', 'b5bf55de-7675-415a-9350-f777acab0120'),
('c7f43a7a-e6b3-4929-b131-d818b34f760f', 'HX38KJO', '30', '95553969-a023-407e-b97d-d755aad5dd68'),
('6dce6089-7620-4e46-9b59-e91040407c82', 'NY19JNM', '5', '90ab7cc0-1c38-49b0-9ebd-819b2fcc75be'),
('62d61e54-22ab-4c29-8e51-515b4c69f443', 'IT18VRN', '5', 'fbcc1cab-c1c3-4e04-ba6e-f56b98407496'),
('930755a6-5dcd-4be8-b3f0-989406c612b3', 'FB55JEZ', '20', '276c4517-d5af-4eec-93f0-44933b96240c'),
('59a019ab-0067-43ab-be56-53fa6ee1e361', 'YG43THR', '10', 'f9eb3dc9-be2b-42c5-a0fa-62312fa9668a'),
('ff60f264-25b5-40ee-9163-85b93d281047', 'BT33SKI', '30', 'fbcc1cab-c1c3-4e04-ba6e-f56b98407496'),
('c3117c9f-3cd6-4d58-bea7-86a01aba647c', 'DK82QHA', '30', '27e72c8e-9462-48ad-9dfb-2c124c9a76ee'),
('1be259f2-b136-4c24-ad69-d4f477517770', 'MG81MKY', '15', '95553969-a023-407e-b97d-d755aad5dd68'),
('cf65ef1e-8c5e-4265-b8d2-712df91bf938', 'LG62WXB', '10', 'a6cda5b2-fcac-444e-8971-0bf2430d6110'),
('1a68530d-eb88-4328-b004-cef8c8e47798', 'TU84NIA', '15', '37db7326-7ac9-4804-97fd-f76da33c01a1'),
('50af69c9-8d48-4e22-86d2-7dca9d77274b', 'TO79RMU', '15', 'acee385d-5fd9-49e6-a21b-bbf1a8109163'),
('0e385362-bcc2-446d-8f41-39c1e91db8f8', 'HW20YSQ', '30', '7917d6b5-6d6c-4e73-ac62-59400054cf0a'),
('c2e2a98d-d3e3-45a6-9875-b2bca3c42655', 'BC99HHW', '10', '7917d6b5-6d6c-4e73-ac62-59400054cf0a'),
('2814e9cf-e489-4da0-9176-8623a65e6b4b', 'QU09TJG', '15', '37db7326-7ac9-4804-97fd-f76da33c01a1'),
('8be12e9a-d014-4a2a-abd9-a3d279e1340e', 'TV42TEK', '10', '1dc5f17f-8d63-458a-ae44-aafe7237d1c2'),
('022e124e-b140-4b42-a813-dfe49c2fd27c', 'FK67COD', '30', '9fe7a6c0-802c-4f46-b51d-c90cef9cb38f'),
('8d8726ad-81a2-495a-9898-a7fca1788a9b', 'XK64TWQ', '20', '7917d6b5-6d6c-4e73-ac62-59400054cf0a'),
('471ebb15-5dd0-48ab-a794-802c18bddb59', 'DZ86PSC', '15', '7917d6b5-6d6c-4e73-ac62-59400054cf0a'),
('7c127e5d-28f1-464c-b187-d38ef54d44d6', 'TR17OVE', '5', 'f883023f-496c-46a4-a179-38185d1ac2a6'),
('d0fc75ad-826a-427c-8bf7-8c6fc77214d7', 'DJ91QQE', '15', 'f9eb3dc9-be2b-42c5-a0fa-62312fa9668a'),
('45739af5-67c1-4b1f-8f91-8075c115505b', 'TJ20THO', '10', '1dc5f17f-8d63-458a-ae44-aafe7237d1c2'),
('d11a5715-f26a-47c9-bcf4-63db7d93c9c5', 'JJ14FBR', '20', '95553969-a023-407e-b97d-d755aad5dd68'),
('15880dd7-39c4-4239-a395-c711f7c54ddd', 'JB78UUC', '20', '9fe7a6c0-802c-4f46-b51d-c90cef9cb38f'),
('a9ae65d9-3353-4d12-b40b-939745db774a', 'GC11DAI', '5', '90ab7cc0-1c38-49b0-9ebd-819b2fcc75be'),
('4c272d2c-a78e-4b47-ab4a-9171a18dd578', 'ON28MAG', '20', '276c4517-d5af-4eec-93f0-44933b96240c'),
('ae2027a7-d0fd-4fe8-8f39-2ec9ce5abfec', 'LU42MAB', '10', '27e72c8e-9462-48ad-9dfb-2c124c9a76ee'),
('1d982911-17f9-456e-a8dd-323427b3ef0a', 'HH94QGL', '5', '27e72c8e-9462-48ad-9dfb-2c124c9a76ee'),
('4ab95470-8bea-429a-9a53-53392450bb19', 'NN44VPL', '20', '4b3edfd8-a1ad-4f15-928d-727ff814ffad'),
('f3f297a3-5537-469d-b7da-b7a6f30c971f', 'BR72MHI', '30', 'a6cda5b2-fcac-444e-8971-0bf2430d6110'),
('d638fe40-c748-44b9-b769-a1a16cbcf683', 'XV85XPL', '30', 'acee385d-5fd9-49e6-a21b-bbf1a8109163'),
('37ed54c3-844a-4a68-aace-b902e3f277df', 'QT97IIH', '20', '95553969-a023-407e-b97d-d755aad5dd68'),
('903a96ac-fee7-4909-8d6f-2f3a6871994f', 'LO43VEW', '20', 'd9b990c8-98e7-4ed4-9620-76715f9448cc'),
('0a16771a-1d8d-4be7-aa09-6b7c46339a77', 'LV56UJM', '30', '95553969-a023-407e-b97d-d755aad5dd68'),
('a2ac530e-2f68-4d41-baf8-5712c3f0b310', 'WM39KTT', '15', 'de21664a-dc56-48cb-b24a-e89f1ab57dcd'),
('d29e724a-9154-4065-a198-bf0d7ce7da64', 'GW59PTH', '5', 'a6cda5b2-fcac-444e-8971-0bf2430d6110'),
('5512aea5-9584-426c-bcfb-17a0bd344b30', 'MS45RGN', '5', 'f9eb3dc9-be2b-42c5-a0fa-62312fa9668a'),
('35cc278e-967f-41a6-ba9c-04003346ccf7', 'KB34CKH', '15', 'd9b990c8-98e7-4ed4-9620-76715f9448cc'),
('0ea5030c-cf87-41f2-9082-b9254a1eb7f8', 'XV25NHG', '15', '37db7326-7ac9-4804-97fd-f76da33c01a1'),
('9e30e034-21f6-48ec-98ee-6966cfbf3acb', 'KS90MQB', '5', '276c4517-d5af-4eec-93f0-44933b96240c'),
('2c0197d4-8a6c-403b-9072-1de037a38e62', 'OQ40OBZ', '10', '95553969-a023-407e-b97d-d755aad5dd68');

insert into supplier_goods_info_wcj
select goods_62l.id, supplier_xiq.id, random() * 1000, random() * 10000
from goods_62l,
     supplier_xiq
where random() < 0.3;

insert into supplier_xiq values
('836423bd-9f19-4ca0-930b-ad5d20bc2675', 'Franey, McLaughlin and Stark', '350 Sadie Forge', '929.771.3880 x02109');

