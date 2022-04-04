FROM phusion/baseimage:master

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Running scripts during container startup
RUN mkdir -p /etc/my_init.d
COPY vncserver.sh /etc/my_init.d/vncserver.sh
RUN chmod +x /etc/my_init.d/vncserver.sh
RUN chmod 755 /etc/container_environment
RUN chmod 644 /etc/container_environment.sh /etc/container_environment.json
# Give children processes 5 minutes to timeout
ENV KILL_PROCESS_TIMEOUT=300
# Give all other processes (such as those which have been forked) 5 minutes to timeout
ENV KILL_ALL_PROCESSES_TIMEOUT=300
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Install lubuntu-desktop
#COPY sources.list /etc/apt/sources.list
RUN dpkg --remove-architecture i386 && \
    apt-get update && \
    apt-get install -yqq sudo wget curl netcat aria2 nano whois figlet p7zip p7zip-full zip unzip rar unrar && \
    add-apt-repository ppa:transmissionbt/ppa -y && \
    add-apt-repository ppa:numix/ppa -y && \
    add-apt-repository ppa:snwh/ppa -y && \
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y && \
    add-apt-repository ppa:neovim-ppa/stable -y && \
    add-apt-repository ppa:redislabs/redis -y && \
    add-apt-repository ppa:brightbox/ruby-ng -y && \
    add-apt-repository ppa:git-core/ppa -y && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash && \
    apt-get update -yqq && apt-get dist-upgrade -yqq && \
    apt-get install -yqq lubuntu-desktop && \
    apt-get install -yqq tightvncserver && \
    apt-get install -yqq git git-lfs bzr mercurial subversion gnupg gnupg2 && \
    apt-get install -yqq gnome-system-monitor tilix && \
    apt-get install -yqq net-tools telnet bash bash-completion lshw && \
    apt-get install -yqq dconf-cli dconf-editor clipit xclip caffeine breeze-cursor-theme htop xterm && \
    apt-get install -yqq numix-gtk-theme numix-icon-theme-circle && \
    apt-get autoremove -y && \
    update-alternatives --set x-terminal-emulator $(which tilix)

RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

####user section####
# ENV USER developer
# ENV HOME "/home/$USER"

RUN echo 'developer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo '%developer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo 'sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo 'www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo '%www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN useradd --create-home --home-dir /home/developer --shell /bin/bash developer && \
  	mkdir /home/developer/.vnc/

RUN usermod -aG sudo developer && \
    usermod -aG root developer && \
    usermod -aG adm developer && \
    usermod -aG www-data developer

COPY vnc.sh /home/developer/.vnc/
COPY xstartup /home/developer/.vnc/

RUN chmod 760 /home/developer/.vnc/vnc.sh /home/developer/.vnc/xstartup && \
  	chown -fR developer:developer /home/developer

# USER "$USER"
###/user section####

####Setup a VNC password####
RUN	echo vncpassw | vncpasswd -f > /home/developer/.vnc/passwd && \
  	chmod 600 /home/developer/.vnc/passwd && \
    chown -fR developer:developer /home/developer

EXPOSE 5901

HEALTHCHECK --interval=60s --timeout=15s \
            CMD netstat -lntp | grep -q '0\.0\.0\.0:5901'

####/Setup VNC####

# CMD ["/home/developer/.vnc/vnc.sh"]
