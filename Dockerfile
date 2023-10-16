FROM python:3.10.10

WORKDIR /flask_7.1

COPY app.py .
COPY requirements.txt .

RUN pip install -r requirements.txt

CMD ["python3", "-m", "flask", "--app", "app.py", "run", "--host", "0.0.0.0"]
