pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        PATH = "C:\\Program Files\\sf\\bin;${env.PATH}"
        SF_DISABLE_TELEMETRY = 'true'
    }

    stages {
        stage('Validate Environment') {
            steps {
                script {
                    if (!env.HUB_ORG_DH || !env.SFDC_HOST_DH ||
                        !env.JWT_CRED_ID_DH || !env.CONNECTED_APP_CONSUMER_KEY_DH) {
                        error('Salesforce environment variables are missing!')
                    }
                }
                bat '''
                    where sf
                    call sf --version
                '''
            }
        }

        stage('Authorize Salesforce Org') {
            steps {
                withCredentials([file(credentialsId: env.JWT_CRED_ID_DH, variable: 'jwt_key_file')]) {
                    bat '''
                        call sf org login jwt ^
                          --client-id "%CONNECTED_APP_CONSUMER_KEY_DH%" ^
                          --username "%HUB_ORG_DH%" ^
                          --jwt-key-file "%jwt_key_file%" ^
                          --instance-url "%SFDC_HOST_DH%" ^
                          --alias target-org ^
                          --set-default
                    '''
                }
            }
        }

        stage('Deploy Code') {
            steps {
                bat '''
                    call sf project deploy start ^
                      --manifest manifest/package.xml ^
                      --target-org target-org ^
                      --wait 30
                '''
            }
        }
    }

    post {
        always {
            bat 'call sf org logout --target-org target-org --no-prompt || exit /b 0'
        }
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed. Check the console output.' }
    }
}
