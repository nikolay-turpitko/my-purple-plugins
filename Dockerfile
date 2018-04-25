FROM debian:stretch
RUN echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ stretch/updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ stretch/updates main" >> /etc/apt/sources.list
RUN echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/force-unsafe-io
RUN echo 'Acquire::EnableSrvRecords "false";' > /etc/apt/apt.conf.d/90srvrecords
RUN apt-get update && apt-get dist-upgrade --yes
RUN apt-get install --yes --no-install-recommends build-essential devscripts ca-certificates git mercurial make cmake gcc checkinstall libpurple-dev libjson-glib-dev libglib2.0-dev libprotobuf-c-dev protobuf-c-compiler libgcrypt20-dev libwebp-dev gettext
# --- Installed tools ---
RUN mkdir -p /work /debs
ARG REL=0
# --- Clone all sources ---
RUN git -C /work clone git://github.com/EionRobb/skype4pidgin.git
RUN hg clone --cwd /work https://bitbucket.org/EionRobb/purple-hangouts/
RUN git -C /work clone --recursive https://github.com/majn/telegram-purple
# --- Building skypeweb ---
RUN mkdir -p /work/skype4pidgin/skypeweb/build
RUN cd /work/skype4pidgin/skypeweb/build && cmake .. && cpack
RUN cp /work/skype4pidgin/skypeweb/build/*.deb /debs
# --- Building hangouts ---
RUN cd /work/purple-hangouts && rm *.spec && make && checkinstall -D -y --pkgname purple-hangouts --pkgversion 0.0.0 --pkgrelease ${REL} --nodoc --pakdir /debs
# --- Building telegram ---
RUN cd /work/telegram-purple && ./configure && make && checkinstall -D -y --pkgname purple-telegram --pkgversion 0.0.0 --pkgrelease ${REL} --nodoc --pakdir /debs
CMD echo "Finished build purple plugins."


