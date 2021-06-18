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
    timeout(time: 1, unit: 'HOUR')
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
      }
    }

    stage('linter') {
      agent { label 'nixos-mayastor' }
      steps {
        sh 'nix-shell --run "./scripts/js-check.sh"'
      }
    }

    stage('test') {
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
    }

    stage('build image') {
      agent { label 'nixos-mayastor' }
      when {
        beforeAgent true
        anyOf {
          branch 'master'
          branch 'release/*'
          branch 'develop'
        }
      }
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

