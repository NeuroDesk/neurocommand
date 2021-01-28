FROM python:3.9.1-slim-buster

RUN mkdir -p /neurodesk
COPY neurodesk/requirements.txt /neurodesk/
WORKDIR /neurodesk

RUN pip install -r requirements.txt

WORKDIR /neurodesk
# RUN python -m neurodesk --cli
