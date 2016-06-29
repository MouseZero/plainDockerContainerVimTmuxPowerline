FROM ubuntu:16.04
MAINTAINER Russell Murray & Maxime Lasserre

RUN apt-get update && apt-get install -y openssh-server git

RUN echo "flag"

# Pair User Setup
RUN mkdir -p /home/pair && \
    echo "pair:x:1000:1000:Pair,,,:/home/pair:/bin/bash" >> /etc/passwd &&\
    echo "pair:x:1000:" >> /etc/group && \
    chown pair:pair -R /home/pair && \
    chmod 777 /etc/ssh && \
    echo 'pair:reduce' | chpasswd 
    
# Setup Paths
ENV HOME /home/pair
WORKDIR /home/pair


# Start SSH
RUN echo 'root:reduce' | chpasswd 
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g'  /etc/ssh/sshd_config

# Install My Repo
RUN git clone https://github.com/mousezero/ubuntuInstallVimTmuxPowerline.git mouseZero

RUN rm /bin/sh && ln -s /bin/bash /bin/sh


RUN cd mouseZero && \
    ./.installPrograms.sh && \
    ./.installSPF13.sh && \
    ./.installConfig.sh

# Get ready for and Switch User to "Pair"
RUN chown pair:pair -R ~/

USER pair
ENV HOME /home/pair
WORKDIR /home/pair
    
USER root
RUN locale-gen en_US.UTF-8
RUN chown pair:pair /usr/bin/

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
