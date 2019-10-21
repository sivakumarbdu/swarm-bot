echo "Setting vars...."
SERVER_IP=127.0.0.1
SERVER_USER=root
DOCKER_MACHINE_NAME=machine03
COMPOSE_DEPLOY_FILE=docker-compose.staging.yml
STACK_NAME=stack01
DOCKER_FILE=Dockerfile.prod

REPOS[0]=repourl/repo1:nginx.prod
REPOS[1]=repourl/repo2:dev.prod

REGISTRY_LOGIN=$(docker login)

SERVICES[0]=web
SERVICES[1]=api

SERVICE_NGINX=nginx
