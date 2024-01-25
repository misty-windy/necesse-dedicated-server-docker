FROM debian:bullseye-slim

# Add user 'necesse', don't run stuff as root!!
ARG user=necesse
ARG group=necesse
ARG uid=1000
ARG gid=1000

ENV WORLD_NAME default-world
ENV SLOTS 10
ENV OWNER ""
ENV MOTD "This server is create by windy!"
ENV PASSWORD "devwindy"
ENV PAUSE 0
ENV GIVE_CLIENTS_POWER 0
ENV LOGGING 1
ENV ZIP 1
ENV JVMARGS ""

RUN groupadd -g ${gid} ${group}
RUN useradd -u ${uid} -g ${group} -s /bin/bash -m ${user}

RUN dpkg --add-architecture i386
RUN apt update; apt install -y ca-certificates-java
RUN apt update; apt install -y lib32gcc-s1 curl openjdk-17-jre-headless

# Download and extract SteamCMD
RUN mkdir -p /steamapps
RUN curl -sqL -o steamcmd_linux.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz
RUN tar -zxvf steamcmd_linux.tar.gz -C /steamapps
WORKDIR /steamapps

# Create the update_necesse.txt file
RUN echo '@ShutdownOnFailedCommand 1' >> update_necesse.txt \
    && echo '@NoPromptForPassword 1' >> update_necesse.txt \
    && echo 'force_install_dir /app/' >> update_necesse.txt \
    && echo 'login anonymous' >> update_necesse.txt \
    && echo 'app_update 1169370 validate' >> update_necesse.txt \
    && echo 'quit' >> update_necesse.txt

RUN echo $(date) && ./steamcmd.sh +runscript update_necesse.txt

# Saves will be available under /root/.config/Necesse/saves
RUN chown -R 1000:1000 /app
RUN mkdir -p /home/necesse/.config/Necesse
RUN chown -R 1000:1000 /home/necesse

USER ${uid}:${gid}

# Set the working directory and create entrypoint.sh
WORKDIR /app
ENTRYPOINT [ "sh", "-c", "java -jar Server.jar -nogui -zip ${ZIP} -motd ${MOTD} -world ${WORLD_NAME} -slots ${SLOTS} -owner ${OWNER} -pause ${PAUSE} -logging ${LOGGING} -jvmargs ${JVMARGS} -password ${PASSWORD} -give_clients_power ${GIVE_CLIENTS_POWER}"]
