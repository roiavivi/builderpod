# Stage 1: Build stage for Kaniko
FROM gcr.io/kaniko-project/executor:debug as kaniko-builder

# Stage 2: Final image
FROM ubuntu:20.04

# Set environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    jq \
    git \
    wget \
    unzip \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Install SonarQube Scanner
RUN wget -O sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip \
    && unzip sonar-scanner-cli.zip -d /opt \
    && rm sonar-scanner-cli.zip \
    && ln -s /opt/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Copy Kaniko executor from the build stage
COPY --from=kaniko-builder /kaniko/executor /kaniko/executor

# Install Trivy
RUN wget https://github.com/aquasecurity/trivy/releases/download/v0.20.2/trivy_0.20.2_Linux-64bit.deb \
    && dpkg -i trivy_0.20.2_Linux-64bit.deb \
    && rm trivy_0.20.2_Linux-64bit.deb

# Set environment variables for SonarQube Scanner
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner-4.6.2.2472-linux
ENV PATH=$PATH:/opt/sonar-scanner-4.6.2.2472-linux/bin

# Set the default command to sleep
CMD ["sleep", "9999999"]
