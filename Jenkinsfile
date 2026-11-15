
import groovy.json.JsonSlurperClassic

pipeline {
    agent any

    stages {

        stage('Validate Environment') {
            steps {
                script {
                    if (!env.HUB_ORG_DH ||
                        !env.SFDC_HOST_DH ||
                        !env.JWT_CRED_ID_DH ||
                        !env.CONNECTED_APP_CONSUMER_KEY_DH) {

                        error('Salesforce environment variables are missing!')
                    }

                    echo 'Salesforce environment variables loaded successfully'
                }

                bat '''
                    where sf
                    sf --version
                '''
            }
        }

        stage('Checkout Source') {
            steps {
                checkout scm
                echo 'Source code checked out successfully'
            }
        }

        stage('Authorize Salesforce Org') {
            steps {
                withCredentials([
                    file(
                        credentialsId: env.JWT_CRED_ID_DH,
                        variable: 'jwt_key_file'
                    )
                ]) {
                    script {
                        def rc = bat(
                            returnStatus: true,
                            script: '''
                                sf org login jwt ^
                                --client-id "%CONNECTED_APP_CONSUMER_KEY_DH%" ^
                                --username "%HUB_ORG_DH%" ^
                                --jwt-key-file "%jwt_key_file%" ^
                                --set-default-dev-hub ^
                                --instance-url "%SFDC_HOST_DH%"
                            '''
                        )

                        if (rc != 0) {
                            error('Salesforce org authorization failed!')
                        }

                        echo 'Salesforce org authorized successfully'
                    }
                }
            }
        }

        stage('Deploy Code') {
            steps {
                script {
                    def deployStatus = bat(
                        returnStatus: true,
                        script: '''
                            sf project deploy start ^
                            --manifest manifest/package.xml ^
                            --target-org "%HUB_ORG_DH%" ^
                            --wait 30
                        '''
                    )

                    if (deployStatus != 0) {
                        error('Salesforce deployment failed!')
                    }

                    echo 'Salesforce deployment completed successfully'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the console output.'
        }
    }
}
