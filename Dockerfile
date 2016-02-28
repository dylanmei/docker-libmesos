FROM debian:jessie

ENV MESOS_VERSION 0.27.1
RUN set -ex \
 && buildDeps=' \
   curl \
   build-essential \
 ' \
 && runDeps=' \
   zlib1g-dev \
   libcurl4-openssl-dev \
   libapr1-dev \
   libsasl2-dev \
   libsasl2-modules \
   libsvn-dev \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends $buildDeps $runDeps \
 && curl -sL --retry 3 --insecure \
     --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
     "http://download.oracle.com/otn-pub/java/jdk/8u31-b13/server-jre-8u31-linux-x64.tar.gz" \
   | gunzip \
   | tar x -C /usr/ \
 && export JAVA_HOME=/usr/jdk1.8.0_31 \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.3.1/binaries/apache-maven-3.3.1-bin.tar.gz \
   | gunzip \
   | tar x -C /usr/ \
 && export MAVEN_HOME=/usr/apache-maven-3.3.1 \
 && curl -sL http://www.apache.org/dist/mesos/$MESOS_VERSION/mesos-$MESOS_VERSION.tar.gz \
  | gunzip \
  | tar x -C /usr/src/ \
 && cd /usr/src/mesos-$MESOS_VERSION \
 && ./configure --disable-python --prefix /tmp/target \
 && MAVEN_OPTS="-Xms512m -Xmx1024m -Dmaven.javadoc.skip=true" make install -j 2 V=0 \
 && cp -r /tmp/target/lib/* /usr/lib/ \
 && rm -rf /usr/src/mesos* \
 && rm -rf $MAVEN_HOME \
 && rm -rf $JAVA_HOME \
 && rm -rf /tmp/* \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get purge -y --auto-remove $buildDeps

ENV MESOS_NATIVE_LIBRARY /usr/lib/libmesos.so
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos.so
