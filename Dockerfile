FROM openjdk:8-jre-alpine

LABEL Shishir Gupta <shishir.gupta@scientificgames.com>

ARG kafka_version=2.8.0
ARG scala_version=2.13

ENV PATH=${PATH}:${KAFKA_HOME}/bin \
    KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

RUN apk add --no-cache bash && \
    cd /opt && \
    wget -qO kafka_${scala_version}-${kafka_version}.tgz https://mirrors.estointernet.in/apache/kafka/${kafka_version}/kafka_${scala_version}-${kafka_version}.tgz && \
    tar -xf kafka_${scala_version}-${kafka_version}.tgz && \
    rm -rf kafka_${scala_version}-${kafka_version}.tgz && \
    ln -sf /opt/kafka_${scala_version}-${kafka_version} ${KAFKA_HOME}

WORKDIR ${KAFKA_HOME}

COPY start.sh .

CMD ["./start.sh"]
