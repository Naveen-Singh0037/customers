// define the pipeline using the declarative syntax
// we use Jenkinsfile to define the pipeline
pipeline {
    
    // use jenkins node as the agent
    // this means that the pipeline can run on any available agent
    agent any

    tools {
        jdk 'jdk-21'
        maven 'maven-3.8.4'
    }

    environment {
        // define the SonarQube server URL and credentials
        SONARQUBE_SERVER = 'Sonar Cloud'                   //SonarQube servers Name - this name is set to be in jenkinn.  Manage Jenkins-> System, scroll to "SonarQube servers" set name-Sonar Cloud, url-https://sonarcloud.io then add secret text and ID anything like- sonar_id
        SONAR_PROJECT_KEY = 'jenkins_pipeline_token'       //SonarQube Cloud Token Name.   MyAccount->Security->Generate Token Name      
        SONAR_PROJECT_NAME = 'simple-spring-api-analysis'  //Display Name -SonarQube Cloud While setup project in sonarqube cloud.
        SONAR_ORGANIZATION = 'naveen-singh0037'            //Organization -SonarQube Cloud while setup project in sonarqube cloud.
        // --- Docker / Deploy ---
        APP_NAME              = 'customer-app'        //Docker images becomes- naveensingh373/spring-api-app(APP_NAME) 
        // <username>/<repo>
        DOCKER_IMAGE          = "naveensingh373/${APP_NAME}"    // naveensingh373 <-- docker hub account name
        // CONTAINER_NAME        = 'spring-api'             //It’s simply the name you give to the container when you run your image with docker run
                                                        //it’s not strictly necessary to define CONTAINER_NAME in the Jenkins environment block, but it’s very useful if you want predictable container names.
                                                         //Docker assigns a random name like tender_fermi.
                                                         //Every time you run a new container, the name changes.

        // container port your app listens on
        APP_PORT              = '9000'                          
        // ID / Jenkins credential (username+password) for registry login FROM DOCKER----------1ST Create access token IN DOCKER ACCOUNT by setting access token discription. in this we set - "jenkins-pipeline"
        //                                                                                   + THEN SET THAT New credentials in jenkins- username=dockerusername, password=that generated token key, 
        //                                                                                      Id = anything. in this case i set "docker-credentials"
        
        DOCKERHUB_CREDENTIALS = 'docker-credentials'             
        // Optional: set a host port different from container port
        HOST_PORT_MAPPING     = '9000:9000'

    }

    stages {
        // stage to checkout the code from the repository
         stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                // by default jenkins will use the master branch
                // if you want to use a different branch, specify it here
                git branch: 'main', url: 'https://github.com/Naveen-Singh0037/customers.git'
            }
        }

        // stage to build the application using maven
        stage('Build') {
            steps {
                echo 'Building with Maven...'
                sh 'mvn clean install'
            }
        }

        // stage to run tests
        // this stage will run the tests using maven
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
            // post actions for the test stage
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        // stage to perform static code analysis using SonarQube
        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv(SONARQUBE_SERVER) {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.projectName=${SONAR_PROJECT_NAME} \
                    """
                }
            }
            // post actions for the SonarQube analysis stage
            post {
                always {
                    echo 'SonarQube analysis completed.'
                }
            }
        }

        // stage('Quality Gate Check') {
        //     steps {
        //         timeout(time: 10, unit: 'MINUTES') {
        //             echo 'Waiting for SonarQube quality gate...'
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
        
        // stage to build the Docker image
        stage('Build Docker Image') {
            steps {
                script {
                    // Use a deterministic image tag per build (BUILD_NUMBER) and also tag as 'latest'
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}"
                }
                sh """
                    echo "Building Docker image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    docker build --pull -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest .
                """
            }
        }

         stage('Docker Push Image') {
            // when {
            //     branch 'main'
            // }
            steps {
                echo "Logging into registry and pushing ${DOCKER_IMAGE}:${IMAGE_TAG}"
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKERHUB_CREDENTIALS}",
                    usernameVariable: 'DOCKERHUB_USERNAME',
                    passwordVariable: 'DOCKERHUB_PASSWORD'
                )]) {
                    sh '''
                        echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout || true
                    '''
                }
            }
        }

                 
    }

    post {
        // post actions for the entire pipeline
        always {
            echo 'Pipeline succeeded with status: ${currentBuild.currentResult}'
        }
    }

}
