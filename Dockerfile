FROM python:3.9.1-slim-buster

COPY neurodesk /neurodesk
WORKDIR /neurodesk

RUN pip install -r requirements.txt

WORKDIR /
RUN python -m neurodesk --cli
