#!/usr/bin/env groovy

// Do not publish images to dockerhub for unimportant branches
def skip_publish_opt = (
  env.BRANCH_NAME != 'develop' &&
  env.BRANCH_NAME != 'master' &&
  !env.BRANCH_NAME.startsWith('release/')
) ? '--skip-publish' : ''

pipeline {
  agent none
  options {
    timeout(time: 1, unit: 'HOURS')
  }

  stages {
    stage('init') {
      agent { label 'nixos-mayastor' }
      steps {
        step([
          $class: 'GitHubSetCommitStatusBuilder',
          contextSource: [
            $class: 'ManuallyEnteredCommitContextSource',
            context: 'continuous-integration/jenkins/branch'
          ],
          statusMessage: [ content: 'Pipeline started' ]
        ])
        withCredentials([
          usernamePassword(credentialsId: 'github-checkout', usernameVariable: 'ghuser', passwordVariable: 'ghpw')
        ]) {
          sh "git clone https://${ghuser}:${ghpw}@github.com/mayadata-io/mayastor-e2e.git"
          sh 'cd mayastor-e2e && git checkout develop'
        }
      }
    }

    stage('linter') {
      agent { label 'nixos-mayastor' }
      steps {
        sh 'nix-shell --run "./scripts/js-check.sh"'
      }
    }

    stage('unit tests') {
      agent { label 'nixos-mayastor' }
      steps {
        sh 'printenv'
        sh 'nix-shell --run "./scripts/citest.sh"'
      }
      post {
        always {
          junit 'moac-xunit-report.xml'
        }
      }
    }

    stage('build image') {
      agent { label 'nixos-mayastor' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
        }
        sh "./scripts/release.sh ${skip_publish_opt}"
      }
      post {
        always {
          sh 'docker logout'
          sh 'docker image prune --all --force'
        }
      }
    }
  }
}

