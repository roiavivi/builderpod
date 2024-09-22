pipeline {
  agent {
    kubernetes {
      yamlFile 'builderpod.yaml'
    }
  }

  environment {
    REPOSITORY_URI = 'docker.io/roie710' // Replace 'your-username' with your Docker Hub username
    IMAGE_NAME = 'sonar-scanner' // Replace with your desired image name
    TAG = "${BUILD_NUMBER}" // Use the build number as the tag
  }

  stages {
    stage('Build and Push Docker Image') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''#!/busybox/sh
              /kaniko/executor \
                --context `pwd` \
                --dockerfile `pwd`/Dockerfile \
                --destination ${REPOSITORY_URI}/${IMAGE_NAME}:${TAG}
            '''
          }
        }
      }
    }
  }
}
