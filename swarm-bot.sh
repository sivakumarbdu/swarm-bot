
#/bin/bash
#Author:  Sivakumar
#Email:   sivakumar.bdu@gmail.com

command=$1
service=$2
APP_ENV=dev

push_image_to_loca_registry() {
	docker-compose push
}

colors(){
	normal=$'\e[0m'                           # (works better sometimes)                     # make colors bold/bright
	red="$bold$(tput setaf 1)"                # bright red text
	green=$(tput setaf 2)                     # dim green text
	fawn=$(tput setaf 3); beige="$fawn"       # dark yellow text
	yellow="$bold$fawn"                       # bright yellow text
	darkblue=$(tput setaf 4)                  # dim blue text
	purple=$(tput setaf 5); magenta="$purple" # magenta text
# https://stackoverflow.com/questions/16843382/colored-shell-script-output-library
}

create_secret(){
	echo $value | docker secret create $key -
}

list_secrets(){
	docker secret ls
}

connect_remote(){
	eval $(docker-machine env $DOCKER_MACHINE_NAME)
	echo "${yellow}Remote connected.${yellow}"
}

disconnect_remote() {
	eval $(docker-machine env -u )
	echo "${yellow}Remote disconnected${yellow}."
}

registry_auth() {
	echo "${yellow}Loging to Registry..${yellow}"
	$LOGIN_REGISTRY
	echo "${green}Done.${yellow}"
}

check_deploy(){
	deploy_lock=deploy.lock
	if [ -e $deploy_lock ]; then
		echo "Another deployment in progress. Exiting..."
		exit 0
	fi
}

remove_deploy_lock(){
	rm deploy.lock
}

create_deploy_lock() {
	touch deploy.lock
}

create(){
	docker-machine create \
	--driver generic \
	--generic-ssh-user $SERVER_USER \
	--generic-ip-address=$SERVER_IP \
	$DOCKER_MACHINE_NAME
}

pull_repository(){
	for repo in "${REPOS[@]}"; do
		docker pull $repo
	done
}

update_service_nginx(){
	docker service update ${STACK_NAME}_${SERVICE_NGINX}
}


clean_unlinked_images(){
	echo "This might  take some time...."
	docker-machine ssh $DOCKER_MACHINE_NAME "docker system prun -f "
	echo "Cleanup done"
}

build_image(){
	echo "${yellow}Building image with name $DOCKER_IMAGE:$1 ...${yellow}"
	docker build -f $DOCKER_FILE --cache-from $DOCKER_IMAGE:latest -t $DOCKER_IMAGE:$1 .
	docker tag $DOCKER_IMAGE:$1 $DOCKER_USERNAME/$DOCKER_IMAGE:$1
}

push_image() {
	echo "${yellow}Pushing image $DOCKER_IMAGE:$1 ...${yellow}"
	docker push $DOCKER_USERNAME/$DOCKER_IMAGE:$1
}

colors

case $service in
	staging)
		source deploy/staging.sh
		export APP_ENV="staging"
	;;
	production)
		source deploy/production.sh
		export APP_ENV="production"
	;;
	*)
		source deploy/dev.sh
		export APP_ENV="dev"
esac


case $command in
	create)
		create
	;;
	init)
		connect_remote
		echo $SERVER_IP
		docker swarm init --advertise-addr $SERVER_IP
		disconnect_remote
	;;
	update_service)
		connect_remote
		echo ${STACK_NAME}_${service}
		echo "${yellow}Updateing service : $2${yellow}"
		docker-machine ssh $DOCKER_MACHINE_NAME "docker service update ${STACK_NAME}_${service}"
		disconnect_remote
	;;
	create_stack)
		connect_remote
		docker stack deploy --compose-file $COMPOSE_DEPLOY_FILE $STACK_NAME
		disconnect_remote
	;;
	deploy)
		check_deploy
		create_deploy_lock
		connect_remote
		registry_auth
		echo "${yellow}Pulling images${yellow}"
		pull_repository
		echo "${green}Done. ${yellow} Deploying..${yellow}"
		docker stack deploy --compose-file $COMPOSE_DEPLOY_FILE $STACK_NAME --with-registry-auth
		disconnect_remote
		echo "${green}Deployment Done${normal}"
		remove_deploy_lock
	;;

	create_secret)
		connect_remote
		key=$3
		value=$4
		create_secret
		disconnect_remote
	;;
	list_secret)
		connect_remote
		list_secrets
		disconnect_remote
	;;
	log)
		container=$3
		echo  ${STACK_NAME}_${container}
		docker-machine ssh $DOCKER_MACHINE_NAME "docker service logs ${STACK_NAME}_${container} -f"
	;;
	clean)
		clean_unlinked_images
	;;
	build)
		if [ -z != $3 ]; then
			TAG=$3
		else
			TAG=latest
		fi

		build_image $TAG
		registry_auth
		push_image $TAG
	;;
	*)
		echo "${red}commands not available${normal}"
esac


