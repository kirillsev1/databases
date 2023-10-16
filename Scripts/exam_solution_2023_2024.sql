
/*
1. Для каждого производителя вывести траспортные средства, имеющие топ-2 различные вместимости. Вывод - название производителя, номер ТС, вместимость.
2. Для каждого материала вывести топ-3 производителей, с наибольшим количеством продуктов из этого материала. Вывод - материал, название производителя, суммарное количество продуктов.
3. Для каждого материала вывести топ-3 производителей, с наименьшей суммарной стоимостью продуктов из этого материала. Вывод - материал, название производителя, суммарная стоимость продуктов.
4. Учитывая, что шаг вместимости ТС равен 5, вывести названия производителей, имеющих ТС с тремя идущими подряд вместимостями, например 5 10 15, 10 15 20 и т.д.

Для зачтения контрольной нужно решить все задачи. Решения без оконных функций не принимаются.
*/

/*1*/
with top as (
select provider_id, registration_mark, load_capacity, dense_rank() over(partition by provider_id order by load_capacity desc) as ranked 
from vehicle_L8J vh  
)
select pr.name, registration_mark, load_capacity, ranked from top vh
join provider_WLb pr on vh.provider_id = pr.id
where ranked <= 2

/*2*/
with top as (
select product_id, provider_id, quantity, dense_rank() over(partition by provider_id order by quantity desc) as ranked 
from provider_product_info_Y9h
)
select pv.material, pr.name as provider, sum(quantity) as sum_quantity from top
join provider_WLb pr on pr.id = top.provider_id
join product_VQk pv on pv.id = top.product_id
group by pv.material, pr.name

/*3*/
with materials_sums as (
select provider_id, product_id, sum(price) over(partition by provider_id) as summed
from provider_product_info_Y9h
),
top as(
select provider_id, summed, name, material, dense_rank() over(partition by material order by summed) as ranked from materials_sums ms
join product_VQk pv on pv.id = ms.product_id
)
select material, pr.name, summed, ranked from top
join provider_WLb pr on pr.id = top.provider_id
where ranked <= 3
group by material, pr.name, summed, ranked
order by material, ranked

/*4*/
with devided_by_5 as (
select *, load_capacity / 5 as nums from vehicle_L8J
),
ranked as(
select *, dense_rank() over(partition by provider_id order by nums) from devided_by_5
join provider_WLb pr on pr.id = devided_by_5.provider_id
order by nums
), 
max_dense_ranked as (
select provider_id, max(dense_rank) as max_rank from ranked group by provider_id, dense_rank 
)
select pr.name from ranked
join provider_WLb pr on pr.id = ranked.provider_id
where provider_id in (select provider_id from max_dense_ranked where max_rank = 3)
group by pr.name
order by pr.name

drop table if exists provider_WLb, product_VQk, provider_product_info_Y9h, vehicle_L8J cascade;

create table provider_WLb
(
    id      uuid primary key,
    name    text,
    address text,
    phone   text,
    email   text
);

create table product_VQk
(
    id       uuid primary key,
    name     text,
    material text
);

create table provider_product_info_Y9h
(
    product_id  uuid references product_VQk,
    provider_id uuid references provider_WLb,
    primary key (product_id, provider_id),
    price       numeric,
    quantity    integer
);

create table vehicle_L8J
(
    id                uuid primary key,
    registration_mark text,
    load_capacity     integer,
    provider_id uuid references provider_WLb
);

insert into provider_WLb values
('22cbb496-cc06-4899-ad96-cb9ff0205d6b', 'Ferry - Daniel', '1778 Maude Lane', '278-407-1611', 'Dorothea_Howe@hotmail.com'),
('e4a7f7e7-c7a7-45fc-9255-5e0bcfd22112', 'Schultz - Kuhlman', '393 Lacy Meadows', '(686) 778-7335 x61614', 'Lue79@gmail.com'),
('e1b20e69-67d4-4e3b-bf92-5a7ebf52cdec', 'Weber LLC', '880 Earlene Centers', '(988) 432-2899 x3620', 'Maxwell.Grant@hotmail.com'),
('6a44f7d7-a429-46cc-ba77-7364cbbf09b3', 'Senger - Hamill', '48625 Maia Valleys', '1-756-310-9472 x128', 'Tre.Johns@yahoo.com'),
('fc4f7470-acc0-45e4-a3ca-b10bcecbbf33', 'Ratke, Cronin and Windler', '8259 Bechtelar Unions', '1-336-926-8281 x676', 'Alaina7@yahoo.com'),
('5fb40f55-8b7d-43f6-b28b-772e4f9c9736', 'Stiedemann Inc', '342 Lakin Key', '1-440-822-9686', 'Karl21@hotmail.com'),
('b477f6e0-6aa9-4ed3-a815-0fc35cc26fea', 'Greenfelder Group', '95822 Amos Inlet', '1-373-765-3377 x1379', 'Amir.Cummings74@gmail.com'),
('e5134f2c-b4c6-4c1b-9518-77e98eff826c', 'Hermiston and Sons', '848 Reilly Walks', '670-521-8710', 'Isaac0@gmail.com'),
('065df852-abd9-4723-9589-b2bcd3c086fa', 'Gutkowski - Ziemann', '504 Hansen Flats', '(808) 514-8852 x04393', 'Holden.Dach@yahoo.com'),
('b85dde61-b957-480f-a86e-57cc885cdb97', 'McClure Group', '6822 Chanelle View', '(397) 273-3000 x897', 'Dillan.Jast@yahoo.com'),
('75d123e1-004f-4243-9f5f-6c26a3e59364', 'Beier and Sons', '96491 Rodrick Motorway', '(379) 804-4550', 'Leda.Jaskolski52@gmail.com'),
('c4913e99-4408-46cb-9a9b-218714df1c54', 'Mertz - Rowe', '8867 Eva Plain', '341-327-9032', 'Audrey_Greenfelder@hotmail.com'),
('b0b38d49-dd8c-4b10-9c02-d00a80ed38be', 'Rolfson - Steuber', '6794 Halvorson Light', '(331) 475-2061 x3488', 'Pierre_Hessel53@hotmail.com'),
('c8f6bca3-e168-48d3-85be-0af2eff680ff', 'Olson - Connelly', '34400 Reichel Ville', '(883) 923-7684 x05208', 'Abigale55@gmail.com'),
('755860eb-9e37-46d4-b906-4daacfadb485', 'Berge - Homenick', '277 Michel Spring', '(433) 807-0027', 'Benny.Hermann52@yahoo.com'),
('d111d910-2939-4eb6-b67f-5d59e84ac406', 'Kohler and Sons', '511 Huels Rest', '1-245-289-9356', 'Rylee.Altenwerth18@gmail.com'),
('65fec445-0f6e-4e19-a377-32a19a3ce71b', 'Batz - Thompson', '3109 Anissa Fall', '862.677.2999 x0800', 'Arjun46@hotmail.com'),
('1189fcb6-aa8a-4f93-b07c-b2395a0db155', 'Kulas - Wisozk', '20881 McDermott Harbors', '427-378-3382 x4630', 'Jacquelyn_Langworth@yahoo.com'),
('18d1bab3-1e23-4d9b-88d4-2172c1265ecf', 'Lesch LLC', '49832 Brendan Flats', '624.226.6723', 'Glenna10@hotmail.com'),
('b68b9122-cf95-4b76-9c70-a112515be8a0', 'Kuhlman Group', '5836 Joanne Motorway', '246.929.9900 x37818', 'Clemens_Donnelly89@hotmail.com'),
('57a36eac-a5bf-4a46-a964-d89e312ca50c', 'Hyatt Group', '557 Jordyn Walk', '930-295-2696 x5048', 'Ruth.Wilderman@yahoo.com'),
('28214543-5cd7-4e94-89d2-6e38b9bd44c1', 'Wintheiser, Lemke and Volkman', '38769 Dorian Parks', '241.500.4471', 'Eudora38@gmail.com'),
('85e3138b-4d71-4e27-83fc-f427b78dee4a', 'O''Keefe and Sons', '830 Earnest Island', '901-778-7119 x9737', 'Francis.Rice@gmail.com'),
('a037508a-749f-4873-9709-f93ed326a380', 'Keeling - Lueilwitz', '23802 Mann Gateway', '1-215-717-5625 x868', 'Earline_Grant@gmail.com'),
('febac19c-273a-4440-9cc5-07cd7cdd01be', 'Hoppe Inc', '6837 Dulce Underpass', '379-612-9967', 'Jadon51@hotmail.com'),
('f2f14b5a-d751-4665-bf16-d1f3cda0668a', 'Aufderhar, Kuhic and Roberts', '386 Kessler Manors', '669.553.8999 x055', 'Amelie.Bergstrom13@yahoo.com'),
('a40dd94d-919a-4128-911d-582eef0ee24b', 'Sanford - Brakus', '96615 Sawayn Estate', '(459) 310-7369 x4647', 'Arielle35@gmail.com'),
('c21488ae-2c34-47ec-8978-1bfacf61df3d', 'Lindgren - West', '2296 Nadia Knoll', '1-836-311-0383 x1268', 'Maci28@gmail.com'),
('7e0ca268-6f86-4428-a795-b0820da7813b', 'Rempel, Balistreri and Beier', '1988 Coby Extensions', '(231) 294-0346 x93128', 'Cathrine.Gutkowski@yahoo.com'),
('70302985-464b-4dd4-a80c-e381cd1e7490', 'Heidenreich Group', '187 Beverly Forge', '(504) 419-3180 x97415', 'Ulises26@hotmail.com');

insert into product_VQk values
('ce27af45-eff2-4d80-8c9f-a5bfa8c3bf14', 'Mouse', 'Rubber'),
('ec37233b-d8c4-4de8-ab86-50e57c4dccf9', 'Bacon', 'Granite'),
('f92b8a8a-c866-40c4-b9bd-085fe739535b', 'Pants', 'Plastic'),
('026c7fd9-1614-4be0-b34d-3623500465d2', 'Keyboard', 'Rubber'),
('a9031d01-78c1-46e3-a496-4abe146b6fb6', 'Pizza', 'Rubber'),
('faa9d210-8cf2-4428-8804-6c0dd8a95770', 'Computer', 'Rubber'),
('71c72c99-695c-4fa9-93ac-034b37c11dee', 'Pants', 'Cotton'),
('d9ed761d-8199-45ec-a4bc-f2dc2a08f3b0', 'Keyboard', 'Wooden'),
('13a0d33a-680e-401b-a4c2-3b29f1eef819', 'Pizza', 'Soft'),
('14e09601-986c-4f30-8936-19f29d91d69b', 'Fish', 'Wooden'),
('cfc9e46f-0dc6-4ee4-8814-e8e4a2024025', 'Table', 'Cotton'),
('c5882466-0691-4fb6-8e2f-9554ef464f63', 'Fish', 'Steel'),
('8da75790-77ca-460a-a4a1-fe8f73fcac5d', 'Bike', 'Granite'),
('7967465f-37bc-4839-83be-e2fd989efbcb', 'Computer', 'Granite'),
('945caeab-a48e-46cb-9341-f9ca058f94db', 'Chicken', 'Concrete'),
('22f950c8-3650-4050-ba38-21d27936682e', 'Bike', 'Concrete'),
('997e7266-c277-463e-bf00-5e12d9e38ed8', 'Bike', 'Cotton'),
('8c680c90-f877-48cc-87a5-8a597e416fd5', 'Shoes', 'Fresh'),
('194d1cca-eacc-44d8-81d5-7a666ba0caf5', 'Towels', 'Granite'),
('48ecdb59-4e90-475e-b12d-035d6e973d55', 'Computer', 'Steel'),
('ef157c78-2bc7-4895-8894-db5c40100516', 'Towels', 'Metal'),
('9f764c01-f5e5-442c-82b1-c4f6d3c3a1a5', 'Towels', 'Fresh'),
('2d61e67d-fa70-4a13-8189-f0c53f8dcce3', 'Car', 'Frozen'),
('e5217ce0-1da7-4f94-99c6-b2feca839e09', 'Computer', 'Fresh'),
('8563d764-7149-4bc2-9eb1-6da1b668e682', 'Pizza', 'Frozen'),
('b35a008a-3ddc-4ee4-8331-1cdc01ab543c', 'Soap', 'Rubber'),
('13a4e2d0-1291-4c8a-a995-5b73501bc773', 'Tuna', 'Metal'),
('96de8db9-08ce-49d6-8899-4483efa5091c', 'Sausages', 'Fresh'),
('830c32a9-de3b-4eca-8073-005c573b0e9b', 'Sausages', 'Concrete'),
('af4fbe2c-34ba-40ab-bf5f-778ad0a2ba9e', 'Soap', 'Metal'),
('0b46f6c9-b5fa-4a24-adb8-b8f7464b2755', 'Table', 'Metal'),
('039ebfa6-243f-4b87-886d-6ed4673cfb6a', 'Keyboard', 'Concrete'),
('bbc81bef-e3db-4410-8c09-796d9c9b1906', 'Computer', 'Frozen'),
('e0beffdd-2b7e-4276-bbb9-93eb6ca2d6b6', 'Car', 'Steel'),
('7fcb366c-d299-4cbd-9ce0-fe587201f309', 'Bacon', 'Wooden'),
('6c5576fe-1319-49fc-bb5e-65320705121d', 'Pizza', 'Plastic'),
('d185883f-e7ae-4502-b5e0-c19e5b5dd42b', 'Car', 'Granite'),
('c00c1951-88c2-4de6-9c0a-4eb5fb3ba4ff', 'Sausages', 'Frozen'),
('a7e49c2a-b1d3-406d-8d65-04ec39f52cfd', 'Car', 'Frozen'),
('6cab94e6-c20b-46ea-b78f-11548170c97f', 'Chair', 'Rubber'),
('9f8e4125-6655-4d85-bf62-faa6c70cadd6', 'Keyboard', 'Granite'),
('a98bc155-2a36-4489-9685-51a51bb932a8', 'Ball', 'Cotton'),
('a1b7dbd3-2d9e-4afc-afc8-75d14d38bb2d', 'Computer', 'Plastic'),
('c37be90d-b919-464a-ad15-f61a569f38dc', 'Shirt', 'Wooden'),
('65730564-69e4-44dd-b6c8-c81b52579176', 'Cheese', 'Fresh'),
('36e9ed88-b7f3-47c6-ad36-dac6a30f0914', 'Ball', 'Concrete'),
('d23af7f7-5fd2-43b7-92c3-e7a0c650b257', 'Fish', 'Soft'),
('abd8a39a-a249-4154-9627-5909fd92ac18', 'Car', 'Rubber'),
('8d4b6e3e-424a-4677-946d-1ac9fe915deb', 'Ball', 'Cotton'),
('93da80ed-4ecc-443f-a75f-a49eac051b7d', 'Ball', 'Metal'),
('9f094317-18d6-449e-8ae9-91ed4c50b3f5', 'Shirt', 'Bronze'),
('71f84e6f-7cf6-44b2-b334-39957a64daea', 'Mouse', 'Fresh'),
('726671e0-3754-4c01-aa29-cce6f2fd9786', 'Keyboard', 'Frozen'),
('dd8f2293-be5b-4cc0-8fd5-2edf9d51ab82', 'Car', 'Cotton'),
('599fa5f1-1492-415c-bbda-b927d8cad925', 'Keyboard', 'Fresh'),
('28fc84ec-94e0-4939-b142-9cdeaf2692f0', 'Bacon', 'Rubber'),
('e31512aa-f017-428d-a7d7-366d8d51765e', 'Ball', 'Steel'),
('35131495-7f9f-4038-8bb9-b158fe378bc7', 'Cheese', 'Cotton'),
('60fd3151-61b1-4e4b-ae06-901a2cab1835', 'Shirt', 'Rubber'),
('a22c2bed-7a0a-4268-9ac4-45a9764c3d33', 'Soap', 'Frozen'),
('a60a7103-ba10-4206-b281-5a5a47f189d0', 'Soap', 'Granite'),
('3527c6e1-e4b3-477a-b0c5-5d59fbb60fce', 'Chicken', 'Plastic'),
('e36d2db8-b40a-42d1-a5dc-015cb2cbdc54', 'Towels', 'Cotton'),
('10229de7-3ed8-4044-ae48-f34a9b03ac03', 'Chicken', 'Concrete'),
('246dcb8c-7ea3-4888-bf2f-eebccef32d92', 'Pants', 'Fresh'),
('9eb01715-4c77-4ec4-b1c2-a0310434a936', 'Chips', 'Concrete'),
('293dc05a-1e91-440e-aa82-1009bbdec119', 'Cheese', 'Frozen'),
('2a6313ac-3026-455a-964a-360c92a0bed0', 'Chicken', 'Granite'),
('c4e4e29f-85d5-4e4d-8ed0-649ef371a9b5', 'Pizza', 'Rubber'),
('3e328e08-cfa7-4477-8b4e-d8f0af76336a', 'Salad', 'Fresh'),
('accc1f5e-8fb5-49c7-a531-e2d5e264ab0d', 'Hat', 'Concrete'),
('67e3e5ef-0c33-4ad6-b67c-11b7f9fa5704', 'Table', 'Cotton'),
('64a35559-35f9-44cd-9ef0-9477821cd7c2', 'Ball', 'Plastic'),
('bc8ed7a2-78fa-42b6-9348-6e904b262e2e', 'Table', 'Rubber'),
('d6453504-2580-4cb3-9f07-ae18d3793029', 'Mouse', 'Soft'),
('2c104674-a527-497e-99f2-11551025f490', 'Gloves', 'Bronze'),
('ba8d1392-805f-4fd0-ba16-26d8dff98b41', 'Soap', 'Wooden'),
('f49ab5d9-47ae-4f20-ba5e-03b1583296d5', 'Chips', 'Fresh'),
('708b5d83-b1c3-48ef-89c7-e52fa5528a37', 'Shirt', 'Rubber'),
('00e0b375-c3f4-4350-984f-f44b8e63c26e', 'Table', 'Granite'),
('a2b02a82-3780-4328-be1c-02b61093e2f3', 'Bacon', 'Cotton'),
('b156df1a-2946-475b-9347-5e7b0ac3e230', 'Sausages', 'Frozen'),
('611ec42e-1520-4de2-ad25-e455b91145cd', 'Pizza', 'Rubber'),
('8a6a96d3-58a4-48b7-8c1e-656d0931a066', 'Keyboard', 'Bronze'),
('902bd776-4c0d-4d86-b12e-cfffb74e5b99', 'Tuna', 'Granite'),
('5ea80f17-c12d-4448-a845-19b11c0c305b', 'Chair', 'Cotton'),
('bfd6d5f4-7510-4fee-8d0a-5fe76c517898', 'Chips', 'Steel'),
('d0a2804a-18c2-4edc-bd4c-3cf784ddb06d', 'Tuna', 'Metal'),
('2285eb90-61f8-49c6-9055-652e08ab48ac', 'Car', 'Cotton'),
('dfb11107-354a-4c7f-b3ca-bdfd653ab576', 'Bike', 'Soft'),
('46db65ce-89eb-4258-aa15-e7dd7cfddb5f', 'Chicken', 'Steel'),
('cc25346c-fcd5-4cf6-b795-3295297e392e', 'Bacon', 'Cotton'),
('b8ddb342-e04c-40e3-88b6-d6c10af46337', 'Tuna', 'Frozen'),
('7006cadf-9b69-4bf6-a897-26c15d9bc28f', 'Cheese', 'Plastic'),
('d6b03042-f86d-4156-a686-3c70e0cfb079', 'Shirt', 'Frozen'),
('3c1d5359-b170-42c5-b0be-4ee979310fb7', 'Chair', 'Granite'),
('975d642d-04ad-474b-83e0-bbad8df8d8c2', 'Ball', 'Concrete'),
('51e7e59b-54a9-4680-9485-6b9b904a9ab4', 'Chicken', 'Rubber'),
('4e1c41b6-1705-41fc-85f7-02cbe9d12721', 'Sausages', 'Plastic'),
('b75ca95e-e9a6-4525-aec7-9cb62c099311', 'Tuna', 'Plastic'),
('ea80a896-1f98-45f0-a4e9-67790e35804b', 'Fish', 'Bronze'),
('77ca27b7-a7c6-4170-9547-b9a308d4a265', 'Soap', 'Cotton'),
('58c1c3cc-2120-4761-a1cf-5f4478b9d98f', 'Chair', 'Frozen'),
('2f3d3d1b-0a19-4adb-a75d-d7377b588d4c', 'Gloves', 'Rubber'),
('6e614ffc-f526-4cb8-93fe-e9bd7a7487a4', 'Fish', 'Steel'),
('1dbc8a35-a004-4dc5-be9c-384ad65a1fe2', 'Computer', 'Wooden'),
('1c485d2e-9016-40d8-88ba-75bd60f5db94', 'Chicken', 'Frozen'),
('2ad2ab9b-259c-488e-8cd4-395b646720bb', 'Salad', 'Frozen'),
('9be9f0c7-0ee4-466e-a859-d79f89ca12e3', 'Hat', 'Fresh'),
('951c1497-32e7-4ab5-a316-ebd66e689e2f', 'Gloves', 'Granite'),
('48a16a1c-6391-47ad-851b-4ecca8c92bbe', 'Tuna', 'Cotton'),
('d3ca9c6e-eaa9-4028-b52f-30b28dcebfac', 'Ball', 'Rubber'),
('3ddbea24-f7ee-4fc0-989b-f1542fdfba3b', 'Cheese', 'Cotton'),
('000353a4-ef04-4904-92dc-c1ce4dbfdc47', 'Shirt', 'Fresh'),
('dd9b9b93-7cd0-4ea4-bf4a-81529e501f3d', 'Gloves', 'Plastic'),
('171562bb-3516-4b1e-980a-b9016b8de58b', 'Chair', 'Granite'),
('675c6a9f-40fd-4a7a-bd75-9bc5cc125fb9', 'Bacon', 'Wooden'),
('6f14b4c3-cba9-47be-8c32-47e64005f79b', 'Chicken', 'Frozen'),
('6a64668b-2808-4739-99ba-94147ec2b1b1', 'Chips', 'Plastic'),
('b7dafa6d-fbaf-4b36-b2bf-653e2b63620d', 'Pizza', 'Metal'),
('c560395c-c9fd-494e-ac61-19803e8d043b', 'Pizza', 'Steel'),
('fc528e92-ac31-44ed-a993-5e1881b3652c', 'Hat', 'Wooden'),
('53717e07-6131-4e40-b9da-a93277c7bbdc', 'Pizza', 'Steel'),
('4956fe9e-6a66-4af8-9d17-3327e8986d9e', 'Soap', 'Granite'),
('0eef8bf6-bb23-424c-bd84-8d6dac0c50be', 'Gloves', 'Concrete'),
('73ecdfde-06a7-40be-ba7a-33f504c228c8', 'Shoes', 'Concrete'),
('264b3de7-59c3-4def-86fc-c821bdd5874e', 'Chicken', 'Concrete'),
('bc82a394-7bfc-47b9-bf59-387687972dbe', 'Fish', 'Granite'),
('a61cc7f6-d2c8-4767-b952-c165d001cc1d', 'Pants', 'Plastic'),
('f9fba639-9fc6-47b2-8eb7-7c7a4574bd49', 'Computer', 'Wooden'),
('502fe054-72f1-4d07-86b5-5a8b5aff55b6', 'Chair', 'Granite'),
('abd6cdcc-af71-459d-8992-899106d615f3', 'Sausages', 'Steel'),
('88869f49-80ba-4054-a86b-ffadc8711494', 'Fish', 'Soft'),
('45ff92c3-09c7-4089-aa1c-23d92c6cc8d4', 'Bacon', 'Fresh'),
('508f4098-2f22-4130-84ab-96f94ab184bd', 'Computer', 'Cotton'),
('d53502f9-ad04-4142-869b-22f91c19586c', 'Soap', 'Plastic'),
('5692720e-1df7-452f-93d5-4e1692c0f8bb', 'Chair', 'Plastic'),
('6bd222c0-8a62-49c8-a234-159356e3ccb2', 'Ball', 'Rubber'),
('b842a13f-c43d-4978-999e-08f61bf7bc4f', 'Computer', 'Fresh'),
('562698bb-c799-4128-b17f-88b27ce92d9d', 'Keyboard', 'Steel'),
('5fe1d7cf-84e7-4577-95cf-b921586a0aa9', 'Cheese', 'Concrete'),
('0c44604a-61de-495a-8d9f-db650d3f1b79', 'Pizza', 'Bronze'),
('3f87f621-b6fc-46d2-a269-af1fc284eacc', 'Pizza', 'Cotton'),
('afb4dd95-6c4a-40de-9aed-72fdf04e0654', 'Pants', 'Wooden'),
('6bfd9b0d-05aa-4056-9530-01b8af257381', 'Ball', 'Soft'),
('2743031d-4276-40bf-9852-f31d81a50e1d', 'Soap', 'Metal'),
('dae26523-b75d-4c69-a1fa-88aa3e36fde1', 'Table', 'Soft'),
('b58a47af-5b11-47b5-a139-85f31de68c65', 'Keyboard', 'Steel'),
('76a8865d-4bb3-4a96-aeb1-d42d0cd34227', 'Towels', 'Frozen'),
('4c369470-411e-41f8-b4f0-1f12dae9277a', 'Chicken', 'Steel'),
('62ecec9b-2ce1-45fe-9aca-c738d8002711', 'Mouse', 'Bronze'),
('93cf7542-f950-4cfa-bf1d-86f94ffe4e90', 'Mouse', 'Fresh'),
('0d472a6b-c331-4be2-86ec-f2933d5533fa', 'Chips', 'Concrete'),
('89926e43-fb91-446a-a7e0-fe09a412e314', 'Bike', 'Cotton'),
('76314160-59c5-41bf-9037-6ad01d44ab54', 'Tuna', 'Frozen'),
('4ec2a926-4709-4ebf-9c6b-55cb03b9b620', 'Pizza', 'Plastic'),
('393e31b8-6670-4680-b604-ec949cb0a9f1', 'Pizza', 'Fresh'),
('bd15331d-4ce0-41ff-9599-c44688710e60', 'Chicken', 'Soft'),
('732be4e1-4127-49ca-8c1e-813903a6496c', 'Shirt', 'Rubber'),
('40e694b0-4899-4405-ab2c-ad0ad59eced9', 'Pizza', 'Concrete'),
('5207fb4e-eb0c-4d69-be3c-09a145688cc6', 'Computer', 'Bronze'),
('662bf950-aadb-4377-a636-c8cb7316bd44', 'Pants', 'Bronze'),
('9afd565c-72d7-4861-b18e-ad56ece0cf81', 'Computer', 'Plastic'),
('36131a12-1035-4847-857f-b12dc39086d7', 'Salad', 'Rubber'),
('66944880-a894-4435-b756-aa65e8ade9cd', 'Mouse', 'Bronze'),
('049d4b78-3efd-43a5-92d3-f80a25372598', 'Chair', 'Wooden'),
('d5430cad-1f92-44d2-907d-8ac246bf69be', 'Tuna', 'Cotton'),
('58025f98-894a-4327-afb0-9f86b21a0df2', 'Soap', 'Plastic'),
('b48955db-90e7-414f-82ea-296bb074aca7', 'Ball', 'Concrete'),
('4a6a7ca5-dee6-4650-b982-9e128613a478', 'Chips', 'Rubber'),
('7c0c6883-81dd-413d-9ac2-aae43502bcc3', 'Fish', 'Cotton'),
('12565c21-b9a0-4f7d-b533-0656c125d292', 'Pants', 'Plastic'),
('43991f1c-2b3d-4b70-be4f-0c594e8987b6', 'Mouse', 'Fresh'),
('f5ef4711-83f0-43f9-ac5b-06e5553d406d', 'Table', 'Steel'),
('83a3dbbb-de3c-4a94-a40e-855b047b1b4c', 'Pants', 'Frozen'),
('d72b6768-cc64-40d9-89c6-636b7bfc7bb8', 'Gloves', 'Granite'),
('ff185a75-943b-460f-b762-7d027b0c2e3a', 'Towels', 'Cotton'),
('30e1ea55-4798-485b-b65b-7d683f633691', 'Fish', 'Bronze'),
('fc005675-98ef-437c-b471-9508e49752d9', 'Ball', 'Bronze'),
('1b8d5c0d-c63e-4eff-93a6-b92b05fa8c56', 'Cheese', 'Granite'),
('cafd2582-dcf4-43b0-974e-09dff5ae6d36', 'Table', 'Metal'),
('4d034cfe-cde4-495d-9704-ef5290f5acfa', 'Keyboard', 'Steel'),
('aee64839-2df2-4aa6-b9cd-c9b335fe3a2d', 'Shoes', 'Rubber'),
('15c3e929-2847-42f8-a2e3-878326ceba5d', 'Pizza', 'Steel'),
('619f269f-e388-4fbd-ba80-818cea3acf6c', 'Computer', 'Metal'),
('9f5eb530-65d1-4a74-9350-baba9e80cd29', 'Gloves', 'Metal'),
('9928b26d-e53c-403a-b09d-eec75ec08e19', 'Cheese', 'Granite'),
('1e3a6c2c-5f95-4642-8c67-906396876370', 'Bike', 'Granite'),
('8572e927-9b29-492f-bd25-11f113b01eb8', 'Fish', 'Metal'),
('460ab43a-5316-4747-8615-b3b6de6eb7a6', 'Soap', 'Wooden'),
('3922105c-4545-4065-86dd-31db25b7c9a8', 'Cheese', 'Fresh'),
('bee90559-22ec-44f8-bb03-372aa8585fe9', 'Mouse', 'Bronze'),
('094126c0-fce3-41e2-9f75-57dab5c66988', 'Towels', 'Metal'),
('c6443121-74cf-43b5-a95f-b1ecd263422c', 'Shoes', 'Concrete'),
('2f32297d-3af2-46a1-aec8-f775bc652204', 'Chips', 'Wooden'),
('b2bf8141-8148-4d6d-9a1f-ee87c2958328', 'Computer', 'Steel'),
('d8fa0565-9a0a-42a4-953b-fc0af4609d8b', 'Computer', 'Soft'),
('0e411134-e467-438e-8069-0120e688c8c3', 'Bacon', 'Cotton'),
('faf96c7d-5f8c-4013-9f14-89176d70a246', 'Car', 'Wooden'),
('bb5701d1-443f-438f-adbf-2a06a10e8b78', 'Sausages', 'Concrete');

insert into vehicle_L8J values
('64e7b672-094a-4ece-84c6-9b31faf704f6', 'SX85LFB', '20', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('bbed3fbf-c274-4271-9f34-ceda3461992d', 'VW06JPE', '30', '755860eb-9e37-46d4-b906-4daacfadb485'),
('28b2fa4a-194c-4b52-845b-900fd86c6d1b', 'XQ74NOK', '20', 'c8f6bca3-e168-48d3-85be-0af2eff680ff'),
('230987de-c8e7-46e7-8528-2a2f0bb5dab6', 'QA92ZRV', '5', 'c21488ae-2c34-47ec-8978-1bfacf61df3d'),
('211ae3fb-c43c-48ac-a68b-30dba96a1d36', 'WJ05HVI', '15', '18d1bab3-1e23-4d9b-88d4-2172c1265ecf'),
('f820dedd-5f17-4bdf-a35b-43e70f891ec8', 'SL43TGE', '15', '65fec445-0f6e-4e19-a377-32a19a3ce71b'),
('166e7856-634c-4fb9-8c5e-cfc9ce8fb10c', 'FS86HZO', '5', 'b0b38d49-dd8c-4b10-9c02-d00a80ed38be'),
('da454e98-75b4-48ba-9a0c-e25d74040a03', 'SU60RLC', '5', '065df852-abd9-4723-9589-b2bcd3c086fa'),
('82d72645-78fb-4241-8a97-461061dc72af', 'CN66PZC', '30', 'e1b20e69-67d4-4e3b-bf92-5a7ebf52cdec'),
('fdd38f50-5d9b-4468-9e31-9a45bb129bad', 'DN50HXN', '30', 'a037508a-749f-4873-9709-f93ed326a380'),
('5e81d563-e67b-4374-89e9-e35176ea9690', 'QC93EMO', '10', 'c8f6bca3-e168-48d3-85be-0af2eff680ff'),
('34193f4f-ab01-4807-ad23-699b5c53327d', 'SL34QPH', '30', '5fb40f55-8b7d-43f6-b28b-772e4f9c9736'),
('96767fa8-7ada-49e1-8d6e-15bb9b2d8d20', 'IJ66CFN', '10', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('53c7fc64-5386-43e4-9f6d-45198d88c1f0', 'XV10DHJ', '20', '28214543-5cd7-4e94-89d2-6e38b9bd44c1'),
('961c0861-2eff-4afd-9c34-45f7f21792a5', 'UJ10ROM', '20', 'f2f14b5a-d751-4665-bf16-d1f3cda0668a'),
('d8377797-dcc4-474c-9242-51e11c6e7b39', 'ZX90UBS', '20', 'b477f6e0-6aa9-4ed3-a815-0fc35cc26fea'),
('b57fbb5e-5d71-468a-9fcc-2df2552b72aa', 'CA32DTH', '5', '85e3138b-4d71-4e27-83fc-f427b78dee4a'),
('b433f159-8655-425c-8b62-8c451d2ffb06', 'ZJ22QIQ', '15', 'f2f14b5a-d751-4665-bf16-d1f3cda0668a'),
('53ac6049-e7de-4bd7-841f-b6858dc24aa2', 'SI71ECE', '30', 'b477f6e0-6aa9-4ed3-a815-0fc35cc26fea'),
('232d7bf0-1c1f-4509-8168-7ff22d08211b', 'HP81XQC', '15', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('f9005a42-f732-4ddc-b18f-3f145ea95506', 'CG27KTG', '15', '6a44f7d7-a429-46cc-ba77-7364cbbf09b3'),
('1f5c08ef-f4a6-4896-8acc-c1838bbf4b01', 'IF67OIG', '10', '5fb40f55-8b7d-43f6-b28b-772e4f9c9736'),
('c699dbc7-5d20-4641-b79e-c053bcf5bd78', 'XV05RQO', '15', 'a037508a-749f-4873-9709-f93ed326a380'),
('59db96c2-932e-46e5-bf19-74b17719df4d', 'XA56JND', '20', 'a037508a-749f-4873-9709-f93ed326a380'),
('f264b55d-ac63-44e5-a381-6ef06b73f6a9', 'JX55KLF', '30', 'e1b20e69-67d4-4e3b-bf92-5a7ebf52cdec'),
('20ae125c-5f0d-4c5f-9fae-193b39a31e28', 'RB35KSL', '5', '65fec445-0f6e-4e19-a377-32a19a3ce71b'),
('e1878682-996a-4488-9db7-95ecd99f1a92', 'ES99CGE', '15', 'b477f6e0-6aa9-4ed3-a815-0fc35cc26fea'),
('68b12b22-5019-47b0-b50b-c3c7c649fcc3', 'AR91PGX', '20', 'a40dd94d-919a-4128-911d-582eef0ee24b'),
('4ad5615f-6237-486d-8bcf-2f8b4eb398c2', 'DJ94XMW', '10', 'c8f6bca3-e168-48d3-85be-0af2eff680ff'),
('991c73c2-e401-4f5e-9fd2-abad9e6adb30', 'NE00SRH', '15', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('9e49c7ac-2014-43e1-8c3e-1ce947d5c9e5', 'PP84NWW', '10', '28214543-5cd7-4e94-89d2-6e38b9bd44c1'),
('d6d28125-55e9-4918-a5e6-f8538ff5ca57', 'TL51BZY', '20', '18d1bab3-1e23-4d9b-88d4-2172c1265ecf'),
('298ad39d-1633-4390-97b2-0c24d63542de', 'RA10UHP', '15', 'c4913e99-4408-46cb-9a9b-218714df1c54'),
('43eb06ac-e38b-4f4e-847e-b63478975ea5', 'LY46DSO', '5', 'e4a7f7e7-c7a7-45fc-9255-5e0bcfd22112'),
('78f26612-46f4-4c0d-9284-0245be188e5f', 'ML62LAS', '10', '65fec445-0f6e-4e19-a377-32a19a3ce71b'),
('c5399c8c-fb73-4a7a-9172-02e33f450d73', 'KM70HZS', '10', 'c21488ae-2c34-47ec-8978-1bfacf61df3d'),
('ab744ff1-6718-4e58-858f-13a544868f8c', 'RM44DVB', '15', '6a44f7d7-a429-46cc-ba77-7364cbbf09b3'),
('8ae6478b-e99f-405f-8780-cd7b7dc25972', 'RH58KKE', '15', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('6aa52c19-aed9-49d6-93e7-d4db9aebc6b3', 'FC69KNK', '5', 'febac19c-273a-4440-9cc5-07cd7cdd01be'),
('6d828cd8-a7c9-4e96-951d-3deaaea7bcd5', 'QS24JNB', '20', '75d123e1-004f-4243-9f5f-6c26a3e59364'),
('96a7a832-edd5-4047-a42c-be8c2d0325da', 'BD87SHL', '5', '6a44f7d7-a429-46cc-ba77-7364cbbf09b3'),
('4b2d8658-3256-41e9-b096-025b08cf2652', 'ZZ08PHA', '30', 'b477f6e0-6aa9-4ed3-a815-0fc35cc26fea'),
('6bb68f40-136d-45c8-ae13-5f25dc70540b', 'QH24FVA', '20', '5fb40f55-8b7d-43f6-b28b-772e4f9c9736'),
('e8d32e37-a902-4fbc-88b9-5fcb342ea5f7', 'KN18EUQ', '10', '1189fcb6-aa8a-4f93-b07c-b2395a0db155'),
('a4afc358-f469-471d-a910-1e32beb15060', 'FI81YKO', '30', 'e5134f2c-b4c6-4c1b-9518-77e98eff826c'),
('9307b0c3-ced7-465f-aaf9-72592b0f8621', 'XD98TGO', '15', 'c4913e99-4408-46cb-9a9b-218714df1c54'),
('cfd5b16e-09c4-40f4-86cd-dc9e135dbb26', 'PQ11HWO', '5', 'e4a7f7e7-c7a7-45fc-9255-5e0bcfd22112'),
('0725d583-5416-46db-bfba-43bf50e6941f', 'UX67VUM', '15', '75d123e1-004f-4243-9f5f-6c26a3e59364'),
('a757e128-7abf-41fd-928d-51656f651120', 'FA63SXK', '30', '18d1bab3-1e23-4d9b-88d4-2172c1265ecf'),
('203a4e39-9132-4f1d-a276-e82a1dcb7662', 'LA91ECI', '20', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('767de993-1682-4080-8fbc-881ce8063d43', 'SJ36UPN', '15', 'c21488ae-2c34-47ec-8978-1bfacf61df3d'),
('cf94c664-5fe4-420d-8acb-6d09124e2ea9', 'SO59VBF', '30', '7e0ca268-6f86-4428-a795-b0820da7813b'),
('59df02f9-8d3a-48ce-b991-2a328a8e65e0', 'PR59PEL', '15', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('ab582c4b-1098-4eb1-aa6c-58ae3d15498e', 'QU85DYS', '5', 'c21488ae-2c34-47ec-8978-1bfacf61df3d'),
('4d1ec28c-d885-41a5-bc7d-c29ed969162b', 'IB10UGM', '30', 'e1b20e69-67d4-4e3b-bf92-5a7ebf52cdec'),
('e198c884-c70a-4756-9d06-576c570e6e1f', 'AC27LNK', '5', 'c4913e99-4408-46cb-9a9b-218714df1c54'),
('3f8ac5ac-88e3-4151-8777-6e2a8371046f', 'JH90EID', '30', 'b68b9122-cf95-4b76-9c70-a112515be8a0'),
('0abba2c8-d837-4679-94ac-8e7488339438', 'WL27MDM', '5', '22cbb496-cc06-4899-ad96-cb9ff0205d6b'),
('04690d5b-ed79-469f-b4f8-d57e072f430d', 'II47CQF', '10', '5fb40f55-8b7d-43f6-b28b-772e4f9c9736'),
('fad907f7-44b1-4868-8e86-b6628755f807', 'YI05MYJ', '5', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('e7f19acc-c876-4801-a7b5-2f59cae6f51f', 'VG02BBQ', '20', '6a44f7d7-a429-46cc-ba77-7364cbbf09b3'),
('aca8f162-3a18-4db9-91a0-6dcac015999e', 'SV63NGF', '20', '7e0ca268-6f86-4428-a795-b0820da7813b'),
('1ff5402e-5696-4455-87ff-a6cd981c9071', 'PS68ZLZ', '30', '85e3138b-4d71-4e27-83fc-f427b78dee4a'),
('16256d94-a0ae-4b27-904a-2e117a5cad14', 'NW27SVN', '20', '75d123e1-004f-4243-9f5f-6c26a3e59364'),
('731ed6fe-487d-41c5-aea8-e6683de4ee7b', 'RG93GWI', '10', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('1a674ed7-d32c-4bd5-a8fd-d96b380511b2', 'TX91LDS', '15', '22cbb496-cc06-4899-ad96-cb9ff0205d6b'),
('ac9798b3-d733-47b3-ace1-4835cd0ad919', 'SC89NOA', '15', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('67991800-220b-4842-98ea-ce4ae2bfcc0d', 'BQ89VMC', '5', 'c8f6bca3-e168-48d3-85be-0af2eff680ff'),
('55a4f42f-1da6-4736-a42d-ee2b1a3e32f8', 'QQ89AVH', '10', '755860eb-9e37-46d4-b906-4daacfadb485'),
('295f99ef-21d3-48de-a382-1acc239721c9', 'CI55JNU', '5', 'c4913e99-4408-46cb-9a9b-218714df1c54'),
('82e4c318-2c5b-4295-beef-7920bea1ef37', 'ZC04QXO', '10', '18d1bab3-1e23-4d9b-88d4-2172c1265ecf'),
('22b2e76e-9c2d-47e4-a47a-0691b0d48b24', 'VL24XIO', '30', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('c152a056-6fb5-48a6-9f4c-5eafaeaff829', 'PU57RDP', '15', 'b68b9122-cf95-4b76-9c70-a112515be8a0'),
('96be60dc-2e73-43e6-bbf1-5f7b85d68025', 'IJ42TNN', '30', 'febac19c-273a-4440-9cc5-07cd7cdd01be'),
('a36f0413-7bc6-41fe-b080-50642bb4aa85', 'MZ75OUA', '30', '57a36eac-a5bf-4a46-a964-d89e312ca50c'),
('24bbcad4-290a-4c3b-93e7-536a560cfe7b', 'NL04IYC', '30', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('8be7dfc8-325f-4db5-8ce8-5ad8571cf293', 'XG86WQS', '15', 'c21488ae-2c34-47ec-8978-1bfacf61df3d'),
('55fbc71f-7744-4dd6-b918-7b56d54ee8e8', 'HV92AIB', '5', '5fb40f55-8b7d-43f6-b28b-772e4f9c9736'),
('d40c8e7a-9c4b-41ea-97f1-2f2c7099d66a', 'MD50IFH', '5', '6a44f7d7-a429-46cc-ba77-7364cbbf09b3'),
('8eed8330-fb78-4376-8bf9-227558adfcdd', 'VA29EGL', '20', '28214543-5cd7-4e94-89d2-6e38b9bd44c1'),
('da293ba2-1c3c-4552-9b26-c6d255be9cbf', 'KE04PUA', '5', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('f55d9890-b717-4490-b07b-5715dd0cd54b', 'AX43HNN', '5', '22cbb496-cc06-4899-ad96-cb9ff0205d6b'),
('245f8661-4f66-4adb-b002-6592035df37b', 'TD77FDK', '30', 'c21488ae-2c34-47ec-8978-1bfacf61df3d'),
('7b2a85a5-87c2-4f2f-a55d-ff1a4414bb72', 'YC56XAG', '20', '065df852-abd9-4723-9589-b2bcd3c086fa'),
('0ab5a584-da07-4902-8ab7-9aba461e662b', 'DL20OAG', '15', '1189fcb6-aa8a-4f93-b07c-b2395a0db155'),
('d7727282-8039-4e93-ab9a-5951cb4c9699', 'FY52ZVL', '20', 'f2f14b5a-d751-4665-bf16-d1f3cda0668a'),
('f29eeba9-b63e-4889-acc1-078d32c07fa2', 'XZ97EAQ', '30', 'b477f6e0-6aa9-4ed3-a815-0fc35cc26fea'),
('87c72b05-0067-47e7-9ef3-7cf2593612c7', 'OH03MBD', '5', '065df852-abd9-4723-9589-b2bcd3c086fa'),
('d8620970-358d-4470-bff8-a6524d23e20a', 'LM85EJK', '15', 'b0b38d49-dd8c-4b10-9c02-d00a80ed38be'),
('a7f8868b-2574-43bd-9f61-2ccf435621d0', 'PG72KBG', '5', 'febac19c-273a-4440-9cc5-07cd7cdd01be'),
('303366c4-3d51-4d52-84ff-18a5d051cb66', 'UL18GBR', '15', 'd111d910-2939-4eb6-b67f-5d59e84ac406'),
('5bc3e99d-9550-44b4-b62f-8f2681a2631c', 'QG70ASL', '20', 'c8f6bca3-e168-48d3-85be-0af2eff680ff'),
('f969fe0a-e49e-468c-9a16-1d1ea2d414ea', 'HX32ILS', '5', '065df852-abd9-4723-9589-b2bcd3c086fa'),
('0535775b-046b-49a5-bec1-82a5a46aa530', 'ZX48ORI', '20', '6a44f7d7-a429-46cc-ba77-7364cbbf09b3'),
('21bf7dfb-9678-4930-899a-b2bc704b5b04', 'OQ46PJE', '5', '70302985-464b-4dd4-a80c-e381cd1e7490'),
('a28c6506-081a-43c4-b35a-dc00e55700d9', 'OM98RRO', '20', 'b85dde61-b957-480f-a86e-57cc885cdb97'),
('bc734914-1c11-40c7-bf93-44c07c654fbe', 'AQ33CHN', '5', 'e4a7f7e7-c7a7-45fc-9255-5e0bcfd22112'),
('686a392d-ce1e-4662-98d0-b86987a17f0b', 'YE79XRV', '5', 'fc4f7470-acc0-45e4-a3ca-b10bcecbbf33'),
('307602a3-1d22-487a-a8ac-c6112cb8f096', 'GH76LXO', '20', '7e0ca268-6f86-4428-a795-b0820da7813b'),
('f5ba0f8a-68cd-46b7-a24f-56c611a4046a', 'NS85JDU', '10', 'e4a7f7e7-c7a7-45fc-9255-5e0bcfd22112');

insert into provider_product_info_Y9h
select product_VQk.id, provider_WLb.id, random() * 1000, random() * 10000
from product_VQk,
     provider_WLb
where random() < 0.3;

insert into provider_WLb values
('d5da3ed2-05e4-4982-94af-24331ed6adb1', 'Yundt - Carter', '776 Cassin Rapids', '(435) 656-2655 x840', 'Rhianna_Hermann@yahoo.com');

