FROM python:3.7

#Ajouter tout le contexte
ADD . .
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis
WORKDIR /app
COPY app/identidock.py /app

EXPOSE 5000 9191 
USER uwsgi
CMD ["uwsgi", "--http", "0.0.0.0:5000", "--wsgi-file", "/app/identidock.py", \
"--callable", "app", "--stats", "0.0.0.0:9191"]
