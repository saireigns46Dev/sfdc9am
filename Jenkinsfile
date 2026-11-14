#!groovy
import groovy.json.JsonSlurperClassic

node {

    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"

    def HUB_ORG = env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH

    // Validate environment variables
    if (!HUB_ORG ||
        !SFDC_HOST ||
        !JWT_KEY_CRED_ID ||
        !CONNECTED_APP_CONSUMER_KEY) {

        error 'Missing Salesforce environment variables'
    }

    println 'Salesforce environment variables loaded successfully'

    def toolbelt = tool 'toolbelt'

    stage('checkout source') {
        checkout scm
    }

    withCredentials([
        file(
            credentialsId: JWT_KEY_CRED_ID,
            variable: 'jwt_key_file'
        )
    ]) {

        stage('Deploy Code') {

            def rc

            if (isUnix()) {

                rc = sh returnStatus: true,
                    script: "${toolbelt} org login jwt --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --set-default-dev-hub --instance-url ${SFDC_HOST}"

            } else {

                rc = bat returnStatus: true,
                    script: "${toolbelt} org login jwt --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --set-default-dev-hub --instance-url ${SFDC_HOST}"
            }

            if (rc != 0) {
                error 'Hub org authorization failed'
            }

            println 'Salesforce authentication successful'

            def rmsg

            if (isUnix()) {

                rmsg = sh returnStdout: true,
                    script: "${toolbelt} project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG}"

            } else {

                rmsg = bat returnStdout: true,
                    script: "${toolbelt} project deploy start --manifest manifest/package.xml --target-org ${HUB_ORG}"
            }

            println rmsg
        }
    }
}
