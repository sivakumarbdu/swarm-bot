## Manage Docker Swarm deployment 

swarm-bot will help to to provision new swarm cluster with docker-machine.  Simple you can manage deploy with this bash script.

### Requirement
Before get started with swarm-bot, make sure you have installed docker, docker-machine and you have access to docker without sudo command.

Check docker post installation steps https://docs.docker.com/install/linux/linux-postinstall/

### Environments

swarm-bot allow to manage multiple environments. Right now its support to manage dev, staging and production environment.  Each environment will have dedicated config file under deploy folder.

* deploy/dev.sh
* deploy/staging.sh
* deploy/production.sh 

All server related configuration will be maintained here.


### Configure Production Swarm cluster

To manage production environment, edit deploy/production.sh file and update proper credentials.

* SERVER_IP -> IP address of server
* SERVER_USER -> User name 
* DOCKER_MACHINE_NAME -> Name of docker machine
* COMPOSE_DEPLOY_FILE -> Docker compose file to use for deployment
* STACK_NAME -> Name of the stack to be created on Master node.
* REPOS[0], REPOS[1] -> Add registry url for images to be puled. All images mentioned in docker-compose file should be give here to take updated.  If you don't want update then skip this.
* REGISTRY_LOGIN -> Add command to loging to your registry.  E.g ``` docker login ```

 ### Create Swarm Cluster and adding  new node (Production Environment)
 
 To provision new server with docker
 
 ``` ./swarm-bot create production ```
 
 This will provision new server with Docker.  Then init Swarm mode on the server
 
 ``` ./swarm-bot init production ```
 
 This will enable swarm mode and gives you manager and worker token.
 
 ### Deploy swarm cluster
 
 Deploy to swarm cluster
 
 ``` ./swarm-bot deploy production
 
 
