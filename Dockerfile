# Stage 1: Build stage for Kaniko
FROM gcr.io/kaniko-project/executor:v1.6.0 as kaniko-builder

# Stage 2: Build stage for SonarQube Scanner
FROM sonarsource/sonar-scanner-cli:4.6 as sonar-scanner-builder

# Install wget, unzip, and Java using apk
RUN apk update && apk add --no-cache wget unzip openjdk17-jre

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

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
COPY --from=sonar-scanner-builder /opt/sonar-scanner /opt/sonar-scanner
RUN ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set JAVA_HOME and update PATH in the final image
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Trivy
RUN wget https://github.com/aquasecurity/trivy/releases/download/v0.20.2/trivy_0.20.2_Linux-64bit.deb \
    && dpkg -i trivy_0.20.2_Linux-64bit.deb \
    && rm trivy_0.20.2_Linux-64bit.deb

# Set environment variables for SonarQube Scanner
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner
ENV PATH=$PATH:/opt/sonar-scanner/bin

# Set the default command to sleep
CMD ["sleep", "9999999"]
