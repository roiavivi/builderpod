# Stage 1: Build stage for Kaniko
FROM gcr.io/kaniko-project/executor:v1.6.0 as kaniko-builder

# Stage 2: Build stage for SonarQube Scanner
FROM openjdk:17-jre-slim as sonar-scanner-builder

# Install wget and unzip
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

RUN wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip \
    && unzip sonar-scanner-cli.zip -d /opt \
    && rm sonar-scanner-cli.zip

# Stage 3: Final image
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    jq \
    git \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy Kaniko executor from the build stage
COPY --from=kaniko-builder /kaniko/executor /kaniko/executor

# Copy SonarQube Scanner from the build stage
COPY --from=sonar-scanner-builder /opt/sonar-scanner-4.6.2.2472-linux /opt/sonar-scanner-4.6.2.2472-linux
RUN ln -s /opt/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Install Trivy
RUN wget https://github.com/aquasecurity/trivy/releases/download/v0.20.2/trivy_0.20.2_Linux-64bit.deb \
    && dpkg -i trivy_0.20.2_Linux-64bit.deb \
    && rm trivy_0.20.2_Linux-64bit.deb

# Set environment variables for SonarQube Scanner
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner-4.6.2.2472-linux
ENV PATH=$PATH:/opt/sonar-scanner-4.6.2.2472-linux/bin

# Set the default command to sleep
CMD ["sleep", "9999999"]
