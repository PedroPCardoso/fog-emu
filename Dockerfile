FROM ubuntu:trusty

ENV FOG_EMU_IN_DOCKER 1

RUN apt-get clean
RUN apt-get update \
    && apt-get install -y  git aptitude build-essential python-setuptools python-dev software-properties-common


# install containernet
RUN apt-get install -y curl iptables && \
    curl https://bootstrap.pypa.io/get-pip.py | python2

# install docker
RUN curl -fsSL https://get.docker.com/gpg | apt-key add -
RUN curl -fsSL https://get.docker.com/ | sh

RUN pip install -U urllib3 setuptools pyparsing docker python-iptables
WORKDIR /
RUN git clone https://github.com/containernet/containernet.git
RUN containernet/util/install.sh
WORKDIR containernet/
RUN make develop

# install fon-emu
RUN echo 'install fog-emu'
RUN apt-get install -y  python-dev python-zmq libzmq-dev libffi-dev libssl-dev
RUN pip install -U zerorpc tabulate argparse networkx six ryu oslo.config pytest Flask flask_restful requests prometheus_client pyaml
WORKDIR /
#avoid pulling not the latest git, copy the current dir, to run this from Jenkins
#RUN git clone https://github.com/PedroPCardoso/fog-emu.git
COPY . /fog-emu
WORKDIR fog-emu/
RUN python setup.py develop
WORKDIR /
RUN echo 'Done'


ENTRYPOINT ["/fog-emu/utils/docker/entrypoint.sh"]
