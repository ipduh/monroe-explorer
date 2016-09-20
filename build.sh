#!/bin/bash
#g0, 2016

function usage
{
cat <<EOHELP

Run $(basename $0) without arguments.
See CONFIG section for parameterization.

Aims at easing the build of docker images to be deployed in the MONROE testbed.
Fights carpal tunnel syndrome and other nasty repetitive stress injuries.

Pulls a docker image (monroe/base by default) from the docker hub
Creates the container .docker file ,
Builds the docker image
Writes helper scripts that ease local testing and pushing to a repository.

Helper Scripts:
  run.sh    : run the docker container
  start.sh  : start and get console into the container
  push.sh   : push the docker image to your docker hub repository

EOHELP
exit $1
}

#
#CONFIG
#

#Your docker image MAINTAINER
MAINTAINER='g0, George Paitaris <github@bot.ipduh.com>'

BASEIMAGE='monroe/base'

#Your docker hub repository
PUSHCONTAINERTAG='ipduh/monroexplorer'

#Applies to start.sh and run.sh
LOCALRESUTLSDIR="${HOME}/monroe/myresults"

MONROERESULTSDIR='/monroe/results'

BASEDOCKERIMAGE='monroe/base'

STARTER='start.sh'
PUSHER='push.sh'
TESTRUNNER='run.sh'

#An one space separated list of the Debian packages you want to install into your image
DEBPACKS="libnet-dns-perl libclass-xsaccessor-perl libimport-into-perl libmoo-perl libnamespace-clean-perl libsub-exporter-perl libtry-tiny-perl libzmq3-dev"

#An one space separated list of the Debian packages you want to install from Testing into your image
SIDDEBPACKS="libzmq-ffi-perl"

#Set to 'install' to install vim in your docker image
#Set to anything else to disable
VIM='install'

#Applies to run.sh
#Set to 'yes' to enable, you need to enter your root password
#Set to anything else to disable
RUN_DOCKER_TRAFFIC_COUNT='yes'


#ENTRYPOINT='["dumb-init", "--", "/usr/bin/perl", "/opt/monroe/monroe-explorer/monroe-explorer.pl"]'
ENTRYPOINT='["dumb-init", "--", "/usr/bin/perl", "/opt/monroe/test/metadata-collector.pl"]'

#
#CONFIG IS DONE
#

if [ "$VIM" = 'install' ]; then
  DEBPACKS="vim ${DEBPACKS}"
fi

DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
CONTAINER=${DIR##*/}
DOCKERFILE=${CONTAINER}.docker
ESC8='\033['
GREEN=${ESC8}"01;32m"
RED=${ESC8}"31;01m"
RESET=${ESC8}"00m"
NOW=`date`
BUILDER=`basename "${0}"`
STATUS=0

function createdotdocker
{
echo "# $DOCKERFILE was created on $NOW by $0"
cat <<STANZANOT
#FROM $BASEIMAGE:latest
FROM $BASEIMAGE
MAINTAINER ${MAINTAINER}
COPY files/opt/monroe/ /opt/monroe/
STANZANOT

if [ -n "$SIDDEBPACKS" ]; then
  echo 'COPY files/preferences /etc/apt/preferences'
fi

if [ "$VIM" = 'install' ]; then
  echo 'COPY files/vimrc /etc/vim/vimrc.local'
fi

if [ -n "$SIDDEBPACKS" ]; then
  echo 'RUN echo "deb http://httpredir.debian.org/debian testing main" >> /etc/apt/sources.list && apt-get update && apt-get install -y \'
else
  echo 'RUN apt-get update && apt-get install -y \'
fi

for PACKAGE in $DEBPACKS; do
  echo -n "  ${PACKAGE} "
  echo ' \'
done

if [ -n "$SIDDEBPACKS" ]; then

cat <<WTES
 && apt-get install -y -t testing $SIDDEBPACKS && apt-get clean
WTES

else

cat <<NTES
 && apt-get clean
NTES

fi

cat <<EOSTANZA

ENTRYPOINT $ENTRYPOINT
EOSTANZA
}

function scriptheader
{
cat <<HEADER
#!/bin/bash
#${1} was created on $NOW by $0

HEADER
}

function ack
{
#Not 100% UNIX, but hey!
if [ $? -eq '0' ]; then
  printf "${BUILDER} -> ${GREEN}%s${RESET}\n" "${1} was ${2}."
  if [ "${3}" = 'x' ]; then
    chmod 755 ${1}
    ack ${1} 'chmoded to 775'
  fi
else
  printf "${BUILDER} -> ${RED}%s${RESET}\n" "${1} was not ${2}."
  let STATUS+=1
fi
}

function createstarter
{
scriptheader ${STARTER}
echo "docker run -v ${LOCALRESUTLSDIR}:${MONROERESULTSDIR} -i -t --entrypoint bash ${CONTAINER}"
}

function createpusher
{
scriptheader ${PUSHER}
echo 'cd $(dirname ${BASH_SOURCE[0]})'

echo "docker login && docker tag ${CONTAINER} ${PUSHCONTAINERTAG} && docker push ${PUSHCONTAINERTAG}"

echo 'if [ $? -eq '0' ]; then'
cat <<EOST02
  printf "${PUSHER} -> ${GREEN}%s${RESET}\n" "${CONTAINER} was uploaded to ${PUSHCONTAINERTAG}."
fi
EOST02
}

function createtestrunner
{
scriptheader $TESTRUNNER
echo "LOCALRESUTLSDIR=${LOCALRESUTLSDIR}"


if [ "$RUN_DOCKER_TRAFFIC_COUNT"='yes' ]; then

cat <<'EOST0'
TRAFFICFLAG=1
if [ "$(id -u)" != "0" ]; then
    echo "If you like me to measure your Docker network traffic enter your"
    echo -n "Root "
fi
TOPNBCC=`su -l root -c "iptables -L DOCKER-ISOLATION -n -v -x |grep RETURN"`
if [ $? -ne "0" ]; then
  TRAFFICFLAG=0
  echo "Unable to measure network traffic."
  echo "Skipping docker network traffic measurements."
fi
TOPNBYTECOUNT=`echo "${TOPNBCC}" |awk '{print $2}'`
EOST0

fi

echo 'TOP=$(($(date +%s%N)/1000000))'
echo "docker run -v ${LOCALRESUTLSDIR}:${MONROERESULTSDIR} ${CONTAINER}"
echo 'TAIL=$(($(date +%s%N)/1000000))'

if [ "$RUN_DOCKER_TRAFFIC_COUNT"='yes' ]; then

cat <<'EOST1'
if [ "$(id -u)" != "0" ]; then
    echo -n "Root "
fi
TAILNBCC=`su -l root -c "iptables -L DOCKER-ISOLATION -n -v -x |grep RETURN"`
if [ $? -ne "0" ]; then
  TRAFFICFLAG=0
  echo "Unable to measure network traffic."
  echo "Skipping docker network traffic measurements."
fi
TAILNBYTECOUNT=`echo "${TAILNBCC}" |awk '{print $2}'`
EOST1

fi


cat <<'EOST2'

echo "Contents of ${LOCALRESUTLSDIR}"
ls -lsht ${LOCALRESUTLSDIR}
echo -n "Size of ${LOCALRESUTLSDIR} in Bytes: ~"
du -b --max-depth=0 ${LOCALRESUTLSDIR} |awk '{print $1}'
ELAPSED_TIME=$((TAIL-TOP))
echo "Elapsed container run 'real' time: $ELAPSED_TIME milliseconds."

EOST2


if [ "$RUN_DOCKER_TRAFFIC_COUNT"='yes' ]; then

cat <<'EOST3'
if [ "${TRAFFICFLAG}" -eq "1" ]; then
  NBCOUNT=$((TAILNBYTECOUNT-TOPNBYTECOUNT))
  echo "Docker Traffic Count: $NBCOUNT Bytes."
fi

EOST3

fi
}

if [[ "$1" =~ ^\-h$|\-\-help$  ]]; then
  usage 0
elif [[ "$#" > 0 ]]; then
  usage 3
fi

if [ ! -d "$LOCALRESUTLSDIR" ]; then
  mkdir -p "$LOCALRESUTLSDIR"
  ack "$LOCALRESUTLSDIR" 'created'
fi

createtestrunner > "${DIR}/${TESTRUNNER}"
ack "${DIR}/${TESTRUNNER}" 'created' 'x'

createstarter > "${DIR}/${STARTER}"
ack "${DIR}/${STARTER}" 'created' 'x'

createpusher > "${DIR}/${PUSHER}"
ack "${DIR}/${PUSHER}" 'created' 'x'

createdotdocker > "${DIR}/${DOCKERFILE}"
ack "${DIR}/${DOCKERFILE}" 'created'

docker pull $BASEDOCKERIMAGE
ack "$BASEDOCKERIMAGE" 'pulled'

docker build --rm=true -f ${DOCKERFILE} -t ${CONTAINER} .
ack "${CONTAINER}" 'build'

exit $STATUS
