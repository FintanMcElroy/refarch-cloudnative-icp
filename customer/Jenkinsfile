podTemplate(
    label: 'gradlePod',
    volumes: [
      hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
      secretVolume(secretName: 'icpadmin', mountPath: '/var/run/secrets/registry-account'),
      configMapVolume(configMapName: 'icpconfig', mountPath: '/var/run/configs/registry-config')
    ],

    containers: [
        containerTemplate(name: 'gradle', image: 'ibmcase/gradle:jdk8-alpine', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'kubectl', image: 'ibmcloudacademy/k8s-icp:v1.0', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'docker' , image: 'docker:17.06.1-ce', ttyEnabled: true, command: 'cat')
    ],
) {
    node ('gradlePod') {
        checkout scm
        container('gradle') {
            stage('Build Gradle Project') {
                sh """
                #!/bin/sh
                gradle build -x test
                gradle docker
                """
            }
        }
        container('docker') {
            stage ('Build Docker Image') {
                sh """
                    #!/bin/bash
                    NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                    REGISTRY=`cat /var/run/configs/registry-config/registry`

                    cd docker
                    docker build -t \${REGISTRY}/\${NAMESPACE}/bluecompute-customer:${env.BUILD_NUMBER} .                    
                """
            }
            stage ('Push Docker Image to Registry') {
                sh """
                #!/bin/bash
                NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                REGISTRY=`cat /var/run/configs/registry-config/registry`

                set +x
                DOCKER_USER=`cat /var/run/secrets/registry-account/username`
                DOCKER_PASSWORD=`cat /var/run/secrets/registry-account/password`
                docker login -u=\${DOCKER_USER} -p=\${DOCKER_PASSWORD} \${REGISTRY}
                set -x

                docker push \${REGISTRY}/\${NAMESPACE}/bluecompute-customer:${env.BUILD_NUMBER}
                """
            }
        }
        container('kubectl') {
            stage('Deploy new Docker Image') {
                sh """
                #!/bin/bash
                set +e
                NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                REGISTRY=`cat /var/run/configs/registry-config/registry`
                DOCKER_USER=`cat /var/run/secrets/registry-account/username`
                DOCKER_PASSWORD=`cat /var/run/secrets/registry-account/password`
                wget --no-check-certificate https://10.10.1.10:8443/api/cli/icp-linux-amd64
                bx plugin install icp-linux-amd64
                bx pr login -a https://10.10.1.10:8443 --skip-ssl-validation -u \${DOCKER_USER} -p \${DOCKER_PASSWORD} -c id-cloudcluster-account
                bx pr cluster-config cloudcluster
                helm init --client-only
                helm repo add bluecompute https://raw.githubusercontent.com/ibm-cloud-academy/icp-jenkins-helm-bluecompute/master/charts
                helm install --tls -n bluecompute-customer --set image.repository=\${REGISTRY}/\${NAMESPACE}/bluecompute-customer --set image.tag=${env.BUILD_NUMBER} bluecompute/customer
                """
            }
        }
    }
}
