import psycopg2
from psycopg2.extras import RealDictCursor


class Car:
    def __init__(self, name, car_type):
        self.name = name
        self.car_type = car_type

    def __str__(self):
        return f'Name: {self.name}, Type: {self.car_type}\n'


class Expedition:
    def __init__(self, name, expedition_result, start_date, end_date):
        self.name = name
        self.expedition_result = expedition_result
        self.start_date = start_date
        self.end_date = end_date

    def __str__(self):
        return f'Name: {self.name}, Expedition_result: {self.expedition_result} start_date: {self.start_date} end_date: {self.end_date}\n'


class Explorer:
    def __init__(self, name, height, width, equipment_id_list):
        self.name = name
        self.height = height
        self.width = width
        self.equipment_list = self.get_equipment_list(equipment_id_list)

    def __str__(self):
        return f'Name: {self.name}, Height: {self.height} width: {self.width}\n'

    def get_equipment_list(self, equipment_id_list):
        explorer_equipment = {}
        for i in equipment_id_list:
            print(equipment_id_list, i, equipment_dict)
            if i not in explorer_equipment and i in equipment_dict:
                explorer_equipment[i] = equipment_dict[i]
        return explorer_equipment


class Equipment:
    def __init__(self, name, production_country, explorer_id):
        self.explorer_id = explorer_id
        self.name = name
        self.production_country = production_country

    def __str__(self):
        return f'Name: {self.name}, Production_country: {self.production_country} explorer_id: {self.explorer_id}\n'


conn = psycopg2.connect(dbname='second_homework', user='postgres', password='123', port='5432', host='localhost',
                        cursor_factory=RealDictCursor)

cur = conn.cursor()

cur.execute("""
select er.id as explorer_id, 
    er.name as explorer_name, 
    er.height as height, 
    er.width as width, 
    e2.explorer_id as equipment_explorer_id,
    e2.name as equipment_name,
    e2.production_country as country,
    c.id as car_id, 
    c.name as car_name, 
    c.type as car_type, 
    e.id as expedition_id,  
    e.name as expedition_name, 
    e.expedition_result, 
    e.start_date, 
    e.end_date,
    er.equipment_id_list as equipment_id_list
    from expedition e
	join car_and_expedition ce on e.id = ce.expedition_id
	join car c on c.id = ce.car_id
	join expedition_to_explorer ee on ee.expedition_id = e.id
	join explorer er on ee.explorer_id = er.id
	join equipment e2 on ee.equipment_id = e2.id;
""")
rows = cur.fetchall()
expedition_dict = {}
car_dict = {}
equipment_dict = {}
explorer_dict = {}
for row in rows:
    expedition_id = row['expedition_id']
    if expedition_id not in expedition_dict:
        expedition_dict[expedition_id] = Expedition(row['expedition_name'], row['expedition_result'], row['start_date'],
                                                    row['end_date'])

    car_id = row['car_id']
    if car_id not in car_dict:
        car_dict[car_id] = Car(row['car_name'], row['car_type'])

    equipment_id = row['equipment_explorer_id']
    if equipment_id not in equipment_dict:
        equipment_dict[equipment_id] = Equipment(row['equipment_name'], row['country'], row['explorer_id'])

for row in rows:
    explorer_id = row['explorer_id']
    if explorer_id not in explorer_dict:
        explorer_dict[explorer_id] = Explorer(row['explorer_name'], row['height'], row['width'],
                                              row['equipment_id_list'])

print(car_dict)
print(expedition_dict)
print(equipment_dict)
print(explorer_dict)
