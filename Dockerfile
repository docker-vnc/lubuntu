FROM phusion/baseimage:0.11

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

# Install lubuntu-desktop
COPY sources.list /etc/apt/sources.list
RUN dpkg --remove-architecture i386 && \
    apt-get update && \
    apt-get install -yqq sudo wget curl netcat aria2 nano whois figlet p7zip p7zip-full zip unzip rar unrar && \
    add-apt-repository ppa:webupd8team/terminix -y && \
    add-apt-repository ppa:clipgrab-team/ppa -y && \
    add-apt-repository ppa:uget-team/ppa -y && \
    add-apt-repository ppa:transmissionbt/ppa -y && \
    add-apt-repository ppa:numix/ppa -y && \
    add-apt-repository ppa:numix/numix-daily -y && \
    add-apt-repository ppa:snwh/ppa -y && \
    add-apt-repository ppa:mc3man/mpv-tests -y && \
    add-apt-repository ppa:qbittorrent-team/qbittorrent-unstable -y && \
    add-apt-repository ppa:neovim-ppa/stable -y && \
    add-apt-repository ppa:webupd8team/java -y && \
    add-apt-repository ppa:certbot/certbot -y && \
    add-apt-repository ppa:chris-lea/redis-server -y && \
    add-apt-repository ppa:brightbox/ruby-ng -y && \
    echo "deb [trusted=yes] https://deb.torproject.org/torproject.org bionic main" | tee /etc/apt/sources.list.d/tor.list && \
    echo "deb-src [trusted=yes] https://deb.torproject.org/torproject.org bionic main" | tee -a /etc/apt/sources.list.d/tor.list && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb [trusted=yes] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash && \
    apt-get update -yqq && apt-get dist-upgrade -yqq && \
    apt-get install -yqq lubuntu-desktop && \
    apt-get install -yqq tightvncserver && \
    apt-get install -yqq git git-lfs bzr mercurial subversion command-not-found command-not-found-data gnupg gnupg2 tzdata gvfs-bin && \
    apt-get install -yqq gnome-system-monitor tilix && \
    apt-get install -yqq python-apt python-xlib net-tools telnet bash bash-completion lsb-base lsb-release lshw && \
    apt-get install -yqq dconf-cli dconf-editor clipit xclip flashplugin-installer caffeine python3-xlib breeze-cursor-theme htop xterm && \
    apt-get install -yqq numix-gtk-theme numix-icon-theme-circle && \
    apt-get install -yqq tor deb.torproject.org-keyring polipo && \
    apt-get autoremove -y && \
    ln -fs /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh && \
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
