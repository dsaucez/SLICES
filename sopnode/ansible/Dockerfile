FROM ubuntu:22.04
RUN apt update && apt install -y python3-pip git rsync
RUN python3 -m pip install --user ansible-core==2.17
RUN echo "export PATH=$PATH:~/.local/bin" >> ~/.bashrc
RUN mkdir /reqs/
COPY collections/requirements.yml /reqs/ansible-galaxy.yml
COPY requirements.txt /reqs/python3.txt
RUN ~/.local/bin/ansible-galaxy install -r /reqs/ansible-galaxy.yml
RUN pip3 install -r /reqs/python3.txt
WORKDIR /blueprint
