# Docker, AWS CLI, Java가 포함된 Jenkins 이미지
FROM jenkins/jenkins:lts-jdk17

# root 사용자로 전환 (패키지 설치용)
USER root

# 시스템 패키지 업데이트 및 필수 도구 설치
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo \
    unzip \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Docker 설치
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 설치
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

# kubectl 설치 (Kubernetes 배포용)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Gradle 설치 (빌드 도구)
ENV GRADLE_VERSION=8.4
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt \
    && ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle \
    && rm gradle-${GRADLE_VERSION}-bin.zip

# Jenkins 사용자를 docker 그룹에 추가
RUN usermod -aG docker jenkins

# Jenkins 사용자에게 sudo 권한 부여 (필요시)
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Jenkins 플러그인 설치 (자동화) - 선택사항
# COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Jenkins 초기 설정 스크립트 복사 - 선택사항
# COPY jenkins/init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Jenkins 사용자로 다시 전환
USER jenkins

# 환경변수 설정
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Jenkins 포트 노출
EXPOSE 8080 50000

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1
