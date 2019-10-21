echo "Setting vars...."
SERVER_IP=127.0.0.1
SERVER_USER=root
DOCKER_MACHINE_NAME=machine02

COMPOSE_DEPLOY_FILE=docker-compose.staging.yml
STACK_NAME=stack01
DOCKER_FILE=Dockerfile.dev

REPOS[0]=repourl/repo1:nginx.dev
REPOS[1]=repourl/repo2:dev

REGISTRY_LOGIN=$(docker login)
SERVICES[0]=web
SERVICES[1]=api

SERVICE_NGINX=nginx
