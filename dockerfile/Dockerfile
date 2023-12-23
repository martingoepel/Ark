FROM debian:12-slim
ENV HOME /app

# Insert steam prompt answers
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
  && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install steamcmd
ARG DEBIAN_FRONTEND=noninteractive
COPY dependencies/sources.list /etc/apt/sources.list
RUN dpkg --add-architecture i386 \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends ca-certificates locales curl steamcmd jq \
  && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

WORKDIR /app

# Install rcon
COPY dependencies/rcon-cli_1.6.4_linux_amd64.tar.gz .
# RUN curl -L https://github.com/itzg/rcon-cli/releases/download/1.6.4/rcon-cli_1.6.4_linux_amd64.tar.gz | tar xvz \
RUN tar xfz rcon-cli_1.6.4_linux_amd64.tar.gz \
  && chown -R root:root /app/rcon-cli \
  && chmod g+rwX /app/rcon-cli

# Create required folder
RUN mkdir .steam && chown 1001:root .steam
RUN mkdir Steam && chown 1001:root Steam
RUN mkdir /opt/game-files && chown 1001:root /opt/game-files

# Install Proton
COPY dependencies/Proton-proton-8.0-4.tar.gz .
# RUN curl -L https://github.com/ValveSoftware/Proton/archive/refs/tags/proton-8.0-4.tar.gz | tar xvz \
RUN tar xfz Proton-proton-8.0-4.tar.gz \
  && mkdir Steam/compatibilitytools.d \
  && mv Proton-proton-8.0-4 Steam/compatibilitytools.d/Proton-8.0-4

# Cleanup
RUN rm *.tar.gz

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /app/steamcmd

WORKDIR /opt

COPY scripts .

EXPOSE 7777
EXPOSE 27020
USER 1001