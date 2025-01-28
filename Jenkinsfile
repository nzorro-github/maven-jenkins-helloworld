pipeline {
    agent any
    environment {
      SERVER_URL = "http://10.211.55.10:8081/artifactory"
      CREDENTIALS = "artifactory"
      ARTIFACTORY_LOCAL_RELEASE_REPO = "nz-libs-release-local"
      ARTIFACTORY_LOCAL_SNAPSHOT_REPO = "nz-libs-snapshot-local"
      ARTIFACTORY_VIRTUAL_RELEASE_REPO = "nz-maven-remote"
      ARTIFACTORY_VIRTUAL_SNAPSHOT_REPO = "nz-maven-remote"
      MAVEN_TOOL = "maven"
    }

    parameters {
        choice(name: 'BRANCH', choices: ['dev','staging','prod'], description: 'Branch to build')
    }

    stages {
        stage ('Clone') {
            steps {
                git branch: '${BRANCH}', url: "https://github.com/nzorro-github/maven-jenkins-helloworld.git"
            }
        }

        stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "artifactory_server",
                    url: SERVER_URL,
                    credentialsId: CREDENTIALS
                )

                rtMavenDeployer (
                    id: "maven",
                    serverId: "artifactory_server",
                    releaseRepo: ARTIFACTORY_LOCAL_RELEASE_REPO,
                    snapshotRepo: ARTIFACTORY_LOCAL_SNAPSHOT_REPO
                )
                rtMavenResolver (
                    id: "maven",
                    serverId: "artifactory_server",
                    releaseRepo: ARTIFACTORY_VIRTUAL_RELEASE_REPO,
                    snapshotRepo: ARTIFACTORY_VIRTUAL_SNAPSHOT_REPO
                )
                
            }
        }

        stage ('Exec Maven') {
            steps {
                rtMavenRun (
                    tool: MAVEN_TOOL, // Tool name from Jenkins configuration
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: "maven",
                    resolverId: "maven"
                )
            }
        }

        stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "artifactory_server"
                )
            }
        }
        stage('Get Commit SHA') {
            steps {
                script {
                    def commitSHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim().take(7)
                    env.COMMIT_SHA = commitSHA
                    echo "Commit SHA: ${commitSHA}"
                }
            }
        }
        stage('Build Image with Ansible'){
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'Ansible-Server', transfers: [sshTransfer(cleanRemote: false, excludes: '', 
                execCommand: "cd /home/parallels/ansible; ansible-playbook ansible-build-app.yml -e env=${BRANCH} -e tag=${env.COMMIT_SHA};", 
execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '//opt//docker', remoteDirectorySDF: false, removePrefix: 'webapp/target', sourceFiles: 'webapp/target/webapp.war')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
          }
        }
stage('Deploy with Ansible'){
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'Ansible-Server', transfers: [sshTransfer(cleanRemote: false, excludes: '', 
                execCommand: "cd /home/parallels/ansible;ansible-playbook ansible-deploy-kustomize.yml -e env=${BRANCH} -e tag=${env.COMMIT_SHA};", 
                execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '//opt//docker', remoteDirectorySDF: false, removePrefix: 'webapp/target', sourceFiles: 'webapp/target/webapp.war')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
          }
        }
    }
}
