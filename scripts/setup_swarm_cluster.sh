#!/bin/bash

source common

################################# SETTINGS #####################################

readonly DEFAULT_NB_NODES=2
readonly NODE_NAME_PREFIX='node'
readonly DEFAULT_VM_DRIVER='virtualbox'
readonly DEFAULT_SWARM_PORT=2377

################################ FUNCTIONS #####################################

function usage
{
  echo -e "usage:\n\
  \n$(basename "$0")\
  \n-d | --driver NAME the virtual infrastructure driver name\
  \n-n | --num-node INT the number of nodes (>0)\
  \n-h | --help : print usage"
}

############################ CONTROL VARIABLES #################################

nb_nodes=${DEFAULT_NB_NODES}
vm_driver="${DEFAULT_VM_DRIVER}"

################################## MAIN ########################################

params="$(getopt -o n:d:h -l driver:,num-node:,help --name "$(basename "$0")" -- "$@")"

if [ ${?} -ne 0 ]
then
    usage
    exit ${SETTINGS_ERROR}
fi

eval set -- "$params"
unset params

while true; do
  case $1 in
    -d|--driver)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  vm_driver="${2}" ; shift 2 ;;
      esac ;;
    -n|--num-node)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  nb_nodes="${2}" ; shift 2 ;;
      esac ;;
    -h|--help)
      usage
      exit ${SUCCESS_CODE}
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      echo "#### abort ####"
      exit ${SETTINGS_ERROR}
      ;;
  esac
done

if [[ -z "${vm_driver}" ]]; then
  echo "## you must give an driver name ! ##"
  usage
  echo "#### abort ####"
  exit ${SETTINGS_ERROR}
fi

if [ ${nb_nodes} -lt 1 ]; then
  echo "#### the number of nodes must be > 0 ####"
  exit ${SETTINGS_ERROR}
fi

readonly node_max_index=$(( ${nb_nodes}-1 ))

systemctl --no-pager status docker > /dev/null

if [ $? -ne 0 ]; then
  echo "> starting docker"
  service docker start
fi

echo "> create up to ${nb_nodes} nodes"

for node_index in `seq 0 ${node_max_index}`;
do
  node_names[${node_index}]="${NODE_NAME_PREFIX}${node_index}"
  echo "  > creating '${node_names[${node_index}]}'"
  docker-machine create --driver "${vm_driver}" "${node_names[${node_index}]}" > /dev/null
done

# Initialize the swarm master node, always the first node.
master_node_name="${node_names[0]}"
master_node_ip="$(docker-machine ip ${master_node_name})"
echo "> intializing the swarm cluster on ${master_node_name} (${master_node_ip})"
docker-machine ssh "${master_node_name}" "docker swarm init" --advertise-addr ${master_node_ip} > /dev/null
swarm_token="$(docker-machine ssh ${master_node_name} "docker swarm join-token -q worker")"
echo "> swarm token is: '${swarm_token}'"

if [ ${nb_nodes} -gt 1 ]; then
  echo "> join the other nodes to the swarm cluster"
  for node_index in `seq 1 ${node_max_index}`;
  do
    current_node_name="${node_names[${node_index}]}"
    current_node_ip="$(docker-machine ip ${current_node_name})"
    echo "  > joining ${current_node_name}"
    docker-machine ssh "${current_node_name}" "docker swarm join --token ${swarm_token} ${master_node_ip}:${DEFAULT_SWARM_PORT}" --advertise-addr "${current_node_ip}"
  done
fi

echo "> display the list of nodes"
docker-machine ssh "${master_node_name}" "docker node ls"

echo "**** ${SCRIPT_NAME} has successfully completed ****"

exit ${SUCCESS_CODE}