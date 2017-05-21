FROM python:3.6.1-alpine

COPY ./ /application/

WORKDIR /application

RUN pip install -r ./requirements.txt


CMD ["python", "main.py"]