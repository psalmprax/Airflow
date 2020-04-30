# https://github.com/docker/compose/issues/3447
sudo docker-compose down -v
sudo docker system prune -a -f
sudo docker-compose --log-level ERROR up -d
sudo docker-compose down -v
sudo docker system prune -a -f
sudo docker-compose --log-level ERROR up -d
sudo docker restart airflow_scheduler_1

