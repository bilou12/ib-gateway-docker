FROM ubuntu:16.04
MAINTAINER Mike Ehrenberg <mvberg@gmail.com>

RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get install -y unzip \
  && apt-get install -y xvfb \
  && apt-get install -y libxtst6 \
  && apt-get install -y libxrender1 \
  && apt-get install -y libxi6 \
	&& apt-get install -y x11vnc \
  && apt-get install -y socat \
  && apt-get install -y software-properties-common

# Setup IB TWS
RUN mkdir -p /opt/TWS
WORKDIR /opt/TWS
RUN wget -q http://one-algo.s3.amazonaws.com/ibgateway-latest-standalone-linux-x64-v960.2a.sh
RUN chmod a+x ibgateway-latest-standalone-linux-x64-v960.2a.sh

# Setup  IBController
RUN mkdir -p /opt/IBController/
WORKDIR /opt/IBController/
RUN wget -q http://one-algo.s3.amazonaws.com/IBController-QuantConnect-3.2.0.zip
RUN unzip ./IBController-QuantConnect-3.2.0.zip
RUN chmod -R u+x *.sh && chmod -R u+x Scripts/*.sh

# Install Java 8 TODO maybe just use "from:java8"
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

WORKDIR /

# Install TWS
RUN yes n | /opt/TWS/ibgateway-latest-standalone-linux-x64-v960.2a.sh

#CMD yes

# Launch a virtual screen (this seems to be broken)
#RUN Xvfb :1 -screen 0 1024x768x24 2>&1 >/dev/null &
#RUN export DISPLAY=:1

ENV DISPLAY :0

ADD runscript.sh runscript.sh
ADD ./vnc/xvfb_init /etc/init.d/xvfb
ADD ./vnc/vnc_init /etc/init.d/vnc
ADD ./vnc/xvfb-daemon-run /usr/bin/xvfb-daemon-run

RUN chmod -R u+x runscript.sh && chmod -R 777 /usr/bin/xvfb-daemon-run
RUN chmod 777 /etc/init.d/xvfb
RUN chmod 777 /etc/init.d/vnc

CMD bash runscript.sh
