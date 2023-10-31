alter table explorer add column education jsonb;


update explorer set education = (
'[
    {
        "name": "СПбГУ",
        "completion_date": 2015,
        "degree": "bachelor"
    },
    {
        "name": "МГУ",
        "completion_date": 2020,
        "degree": "magister"
    }
]'
) where height >= 180;


update explorer set education = (
    '[
        {
            "name": "КФУ",
            "completion_date": 2014,
            "degree": "magister"
        },
        {
            "name": "ВШЭ",
            "completion_date": 2019,
            "degree": "phd"
        }
    ]'
) where height <= 180