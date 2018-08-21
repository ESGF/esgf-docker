/*******************************************************************************
  This script implements the following behaviors:

  * Every PR that targets devel or master branch, is built and tested.
    A successful build and test is required before merging (Jenkins doesn't
    perform source tagging or push docker images).

  * Every commit to devel is built and tested. If successful, the
    docker images are tagged and pushed (to the dockerhub) with "devel" and
    the result of "$(git describe --always --tags)".

  * Every commit to master is built and tested. If successful, the docker images
    are tagged and pushed with "latest" and the result of
    "$(git describe --always --tags)". Jenkins also tags the sources ("git tag")
    with the result of "git describe --always --tags" and pushes this tag to the
    remote repository.

  * Every source tag commited to the remote repository is built, tested and
    the docker images are tagged and pushed with the same label.

More information on https://esgf.github.io/esgf-docker/developer/contributing/

*******************************************************************************/

// SYSTEM SETTINGS
WAITING_TIME=240 // in seconds.

INFO_TAG='[INFO]'
ERROR_TAG='[ERROR]'
DEBUG_TAG='[DEBUG]'
WARN_TAG='[WARN]'
SUCCESS_TAG='[SUCCESS]'
FAILURE_TAG='[FAILURE]'
ABORT_TAG='[ABORT]'

ENABLE_SLACK_NOTIFICATION = true

enum Colors
{
  BLUE('#009fdb', '\u001B[34m'),
  GREEN('#60c36e', '\u001B[32m'),
  RED('#db3c00', '\u001B[31m'),
  YELLOW('#ffd700', '\u001B[33m'),
  PURPLE('#9e3b7e', '\u001B[35m');

  public String hexa_code
  public String xterm_code

  public Colors(String hexa_code, xterm_code)
  {
    this.hexa_code = hexa_code
    this.xterm_code = xterm_code
  }
}

pipeline
{
  agent
  {
    node
    {
      // Execute this job only on Docker ready nodes.
      label 'esgf-docker-slave'

      // Don't let Jenkins generate the workspace name: it is too long and
      // crashes the ESGF config generation stage.
      // env.WORKSPACE is unknown at this step, so we cannot do better than
      // provide an absolute path.
      customWorkspace "/home/jenkins/slave_home/workspace/${env.JOB_NAME}"
    }
  }

  options
  {
    ansiColor('xterm') // Interprets color. Needs AnsiColor plugin.
    timeout(time: 45, unit: 'MINUTES')
    timestamps() // Add timestamp. Needs TimeStamp plugin.
  }

  environment
  {
    /*** ESGF-DOCKER **/
    ESGF_HUB='esgfhub'
    ESGF_PREFIX=''
    ESGF_DOCKER_REPO_PATH="${env.WORKSPACE}"
    ESGF_CONFIG="${env.WORKSPACE}/config"
    ESGF_DATA="${env.WORKSPACE}/data"

    /*** DOCKERHUB ***/
    DOCKERHUB_CREDENTIAL_ID='esgfci-dockerhub'

    /*** ESGF TEST SUITE ***/
    ESGF_TEST_SUITE_REPO_URL='https://github.com/ESGF/esgf-test-suite.git'
    ESGF_TEST_SUITE_REPO_PATH="${env.WORKSPACE}/esgf-test-suite"
    TEST_DIR_PATH="${ESGF_TEST_SUITE_REPO_PATH}/esgf-test-suite"
    SINGULARITY_FILENAME='esgf-test-suite_env.singularity.img'
    SINGULARITY_IMG_URL="http://distrib-coffee.ipsl.jussieu.fr/pub/esgf/dist/esgf-test-suite/${SINGULARITY_FILENAME}"
    SINGULARITY_FILE_PATH="${TEST_DIR_PATH}/${SINGULARITY_FILENAME}"
    TESTS='-a !compute,basic -a cog_root_login -a slcs_django_admin_login'
    CONFIG_FILE_PATH="${env.WORKSPACE}/../../../esgf/my_config_docker.ini"

    /*** ESGF DOCKER SECRETS ***/
    ROOT_ADMIN_SECRET_FILE_PATH="${ESGF_CONFIG}/secrets/rootadmin-password"

    /*** SLACK ***/
    SLACK_CHANNEL='#esgf-docker-ci'
    SLACK_CREDENTIAL_ID='slack_esgf_esgf-docker-ci'

    /*** GITHUB ***/
    GIT_REPO_POSTFIX='github.com/ESGF/esgf-docker.git'
    GITHUB_CREDENTIAL_ID='esgfci_github'
  }

  stages
  {
    stage('checking')
    {
      when
      {
        // Escape pull request that targets branches other than master or devel.
        anyOf
        {
          changeRequest(target: 'devel')
          changeRequest(target: 'master')
          branch 'master'
          branch 'devel'
          buildingTag()
        }
      }

      stages
      {
        stage('conf tag')
        {
          when {buildingTag()} // Run this stage when processing a source tag.
          steps
          {
            start_block('configuration')
            script
            {
              // As variables declared in the environment statement are
              // unmutable, ESGF_VERSION has to be declared this way, so as to be
              // modified later (e.g. into latest or devel).
              env.ESGF_VERSION=env.BRANCH_NAME
              env.GIT_TAG=env.ESGF_VERSION // This must not be modified.

              env.SLACK_MSG_PREFIX ="ESGF-DOCKER <${env.BUILD_URL}|tag ${env.BRANCH_NAME}#${env.BUILD_ID}>:"
              env.CONSOLE_MSG_PREFIX="tag ${env.BRANCH_NAME}"
              begin("testing tag ${env.BRANCH_NAME}")
            }
            end_block('configuration')
          }
        }

        stage('conf pr')
        {
          when {changeRequest()} // Run this stage when processing a PR.
          steps
          {
            start_block('configuration')
            script
            {
              // As variables declared in the environment statement are
              // unmutable, ESGF_VERSION has to be declared this way, so as to be
              // modified later (e.g. into latest or devel).
              env.ESGF_VERSION=sh(returnStdout: true, script: "git describe --always --tags").trim() // remove the trailling new line
              env.GIT_TAG=env.ESGF_VERSION // This must not be modified.

              env.SLACK_MSG_PREFIX ="ESGF-DOCKER <${env.BUILD_URL}|${env.BRANCH_NAME}#${env.BUILD_ID}>:"
              env.CONSOLE_MSG_PREFIX="pull request ${env.BRANCH_NAME}"
              begin("testing pull request ${env.BRANCH_NAME} (branch ${env.CHANGE_TARGET})")
            }
            end_block('configuration')
          }
        }

        stage('conf branch')
        {
          when {anyOf{branch 'master' ; branch 'devel'}}
          steps
          {
            start_block('configuration')
            script
            {
              // As variables declared in the environment statement are
              // unmutable, ESGF_VERSION has to be declared this way, so as to be
              // modified later (e.g. into latest or devel).
              env.ESGF_VERSION=sh(returnStdout: true, script: "git describe --always --tags").trim() // remove the trailling new line
              env.GIT_TAG=env.ESGF_VERSION // This must not be modified.

              env.SLACK_MSG_PREFIX ="ESGF-DOCKER <${env.BUILD_URL}|branch ${env.BRANCH_NAME}#${env.BUILD_ID}>:"
              env.CONSOLE_MSG_PREFIX="branch ${env.BRANCH_NAME}"
              begin("testing commit ${env.GIT_COMMIT} on branch ${env.BRANCH_NAME}")
            }
            end_block('configuration')
          }
        }

        stage('checkout') // the repository is supposed to be checked out before.
        {
          steps
          {
            start_block('checkout')

            dir(ESGF_TEST_SUITE_REPO_PATH)
            {
              info('checkout esgf-test-suite')
              git(url: ESGF_TEST_SUITE_REPO_URL)
            }

            dir(ESGF_TEST_SUITE_REPO_PATH)
            {
              info('looking for the singularity env file')
              script
              {
                if (fileExists(SINGULARITY_FILE_PATH))
                {
                  msg = sh(returnStdout: true, script: "date -r ${SINGULARITY_FILE_PATH}")
                  info(String.format("using singularity file: %s",msg))
                }
                else
                {
                  info('download the esgf-test-suite singularity image')
                  sh "wget -q -O \"${SINGULARITY_FILE_PATH}\" \"${SINGULARITY_IMG_URL}\""
                }
              }
            }

            end_block('checkout')
          }
        }

        stage('build')
        {
          steps
          {
            start_block('build')

            dir(ESGF_DOCKER_REPO_PATH)
            {
              info("building esgf-docker images with the tag '${env.ESGF_VERSION}' and hub '${ESGF_HUB}'")
              sh('docker-compose -f docker-compose.build.yml build --no-cache')
            }

            end_block('build')
          }
        }

        stage('config containers')
        {
          steps
          {
            start_block('config containers')

            info('delete the previous configuration files of ESGF docker')
            sh 'rm -fr "${ESGF_CONFIG}" ; mkdir -p "${ESGF_CONFIG}"; mkdir -p "${ESGF_DATA}"'
            // Write $ESGF_CONFIG/environment config file
            sh 'echo -e "ESGF_HOSTNAME=$(hostname)\nESGF_DATA=${ESGF_DATA}" > "${ESGF_CONFIG}/environment"'
            sh 'cat "${ESGF_CONFIG}/environment"'
            dir(ESGF_DOCKER_REPO_PATH)
            {
              info('generating esgf secrets')
              sh './bin/esgf-setup generate-secrets'
              info('generating certificates')
              sh './bin/esgf-setup generate-test-certificates'
              info('creating trust bundle')
              sh './bin/esgf-setup create-trust-bundle'

              // Enable containers to read the private keys.
              sh 'chmod +r "${ESGF_CONFIG}/certificates/hostcert/hostcert.key"'
              sh 'chmod +r "${ESGF_CONFIG}/certificates/slcsca/ca.key"'
            }
          }
          post
          {
            failure {shutdown()}
            aborted {shutdown()}
            cleanup {end_block('config containers')}
          }
        }

        // Nested stages don't stop overall pipeline on error...
        // In fact an error just exits the current stages statement.
        // I can't factorize the post actions.
        stage('start containers')
        {
          steps
          {
            start_block('start containers')

            dir(ESGF_DOCKER_REPO_PATH)
            {
              info("starting the containers, hub: '${ESGF_HUB}', version: '${env.ESGF_VERSION}'")

              // We must 'export' these env vars otherwise orp, slcs and auth keep restarting.
              sh(script: """
                   set +x
                   export ESGF_CONFIG=${ESGF_CONFIG}
                   ./bin/esgf-compose up -d
                   """)

              info("waiting ${WAITING_TIME} seconds for the containers")
              sleep(time:WAITING_TIME, unit: 'SECONDS')
              info('container status:')
              sh './bin/esgf-compose ps'
            }
          }
          post
          {
            failure {shutdown()}
            aborted {shutdown()}
            cleanup {end_block('start containers')}
          }
        }

        stage('run test-suite')
        {
          steps
          {
            info('running the tests')
            dir(TEST_DIR_PATH)
            {
              start_block('run containers')

              script
              {
                admin_passwd=readFile(ROOT_ADMIN_SECRET_FILE_PATH)
                slcs_secret_conf="slcs.admin_password:${admin_passwd}"
                cog_secret_conf="cog.admin_password:${admin_passwd}"
              }

              // Don't set retry statement in the options of a stage as
              // on every retry, post condition failure will be triggered and
              // the result of the job will be a failure even if the
              // instructions retried are successful.
              retry(3) // Give esgf-test-suite 3 chances to pass !
              {
                // Add set +x so as to hide the passwords
                // (default bash options are -xe)
                sh(script: """
                    set +x
                    singularity exec "${SINGULARITY_FILE_PATH}" \
                      python2 esgf-test.py ${TESTS} \
                      -v --nocapture --nologcapture \
                      --rednose --force-color --hide-skips \
                      --tc-file "${CONFIG_FILE_PATH}" \
                      --tc="${slcs_secret_conf}" \
                      --tc="${cog_secret_conf}"
                    """)
              }
            }
          }
          post
          {
            failure
            {
              info('log of the containers:')
              dir(ESGF_DOCKER_REPO_PATH) {sh './bin/esgf-compose logs'}
            }

            // Cleanup is run after all post condition statements.
            cleanup
            {
              shutdown()
              end_block('run containers')
            }
          }
        }


        // Nested stage don't stop overall pipeline on error...
        // In fact an error just exits the current stages statement.
        // But for pushing docker images, this is ok as the build and tests passed
        // at this point of the script.
        // So the stages after this stage can be executed even if this stage
        // has failed !
        stage('push & tag images')
        {
          when
          {
            beforeAgent true
            anyOf {branch 'master'; branch 'devel' ; buildingTag()}
            // Don't push docker images and make git tag when it is just a PR that
            // triggered this job.
            not {changeRequest()}
          }

          stages
          {
            stage('login dockerhub')
            {
              steps
              {
                start_block('push & tag')

                withCredentials([usernamePassword(
                  usernameVariable: 'dockerhub_username',
                  passwordVariable: 'dockerhub_passwd',
                  credentialsId: "${DOCKERHUB_CREDENTIAL_ID}")])
                {
                  info('trying to log into dockerhub')

                  // Don't set retry statement in the options of a stage as
                  // on every retry, post condition failure will be triggered and
                  // the result of the job will be a failure even if the
                  // instructions retried are successful.
                  retry(3)
                  {
                    // Username and password are not printed back.
                    sh(script: '''
                        set +x
                        echo ${dockerhub_passwd} | docker login -u ${dockerhub_username} --password-stdin
                       ''')
                  }
                }
              }
            }

            stage("push images #1")
            {
              steps
              {
                info("pushing the images tagged ${env.ESGF_VERSION} to ${ESGF_HUB}")
                dir(ESGF_DOCKER_REPO_PATH)
                {
                  // Don't set retry statement in the options of a stage as
                  // on every retry, post condition failure will be triggered and
                  // the result of the job will be a failure even if the
                  // instructions retried are successful.
                  retry(3)
                  {sh(script: 'docker-compose -f docker-compose.build.yml push')}
                }
              }
            }

            stage("retag images") // Don't retry to retag
            {
              when
              {
                beforeAgent true
                not{buildingTag()}
              }

              steps
              {
                // Compute tag for the next stage.
                script
                {
                  // As variables declared in the environment statement are
                  // unmutable, ESGF_VERSION has to be declared this way, so as to be
                  // modified later into latest or devel.
                  if(env.BRANCH_NAME=='master')
                  {
                    env.ESGF_VERSION='latest'
                  }
                  else
                  {
                    env.ESGF_VERSION='devel'
                  }
                }

                info("retagging images with ${env.ESGF_VERSION}")
                dir(ESGF_DOCKER_REPO_PATH)
                {
                 sh('docker-compose -f docker-compose.build.yml build') // Quickly retag the images
                }
              }
            }

            stage("push images #2")
            {
              when
              {
                beforeAgent true
                not{buildingTag()}
              }

              steps
              {
                info("pushing the images tagged ${env.ESGF_VERSION} to ${ESGF_HUB}")
                dir(ESGF_DOCKER_REPO_PATH)
                {
                  // Don't set retry statement in the options of a stage as
                  // on every retry, post condition failure will be triggered and
                  // the result of the job will be a failure even if the
                  // instructions retried are successful.
                  retry(3)
                  {sh(script: 'docker-compose -f docker-compose.build.yml push')}
                }
              }
            }

            stage('git tag sources') // Don't retry to create source tag.
            {
              when
              {
                beforeAgent true
                branch 'master'
              }

              steps
              {
                dir(ESGF_DOCKER_REPO_PATH)
                {
                  info("creating git tag ${env.GIT_TAG}")
                  sh("git tag ${env.GIT_TAG}")
                }
              }
            }

            stage('git push tag')
            {
              when
              {
                beforeAgent true
                branch 'master'
              }

              steps
              {
                dir(ESGF_DOCKER_REPO_PATH)
                {
                  info("pushing git tag ${env.GIT_TAG} to ${env.GIT_URL}")

                  withCredentials([usernamePassword(usernameVariable: 'github_username', passwordVariable: 'github_passwd', credentialsId: "${GITHUB_CREDENTIAL_ID}")])
                  {
                    // Don't set retry statement in the options of a stage as
                    // on every retry, post condition failure will be triggered and
                    // the result of the job will be a failure even if the
                    // instructions retried are successful.
                    retry(3)
                    {sh("git push \"https://${github_username}:${github_passwd}@${GIT_REPO_POSTFIX}\" ${env.GIT_TAG}")}
                  }
                }
              }
            }
          }
          post
          {
            always {sh('docker logout')}
            cleanup {end_block('push & tag')}
          }
        }
      }
    }
  }
  post
  {
    // At the moment, the images are periodically deleted by another Jenkins
    // job. Preserving the old images makes building esgf-docker faster.
    // always {delete_images() ; delete_container()}
    always {delete_container()} // XXX TEST

    failure
    {
      info('delete the workspace on failure')
      deleteDir() // safe precaution
      failure("${env.CONSOLE_MSG_PREFIX} on previous error(s)")
    }

    success
    {
      script
      {
        if(env.CONSOLE_MSG_PREFIX == null)
        {
          // PRs that don't target master or devel
          info("Skip PR that doesn't target master or devel")
        }
        else
        {
          success("${env.CONSOLE_MSG_PREFIX}")
        }
      }
    }

    aborted
    {
      info('delete the workspace on abortion')
      deleteDir() // safe precaution
      abort("${env.CONSOLE_MSG_PREFIX}")
    }
  }
}


// Images may not be built. Don't matter any error messages (returnStatus: true)
def delete_images()
{
  info('deleting docker images (if any, otherwise: ignore the error messages)')
  sh(returnStatus: true, script : 'docker image ls | grep "^<none>" | awk \'{print $3}\' | xargs docker image rm --force')
  sh(returnStatus: true, script : 'docker images "${ESGF_HUB}/*:*" -q | xargs docker image rm --force')
}

def delete_container()
{
  info('deleting containers (if any, otherwise: ignore the error messages)')
  sh(returnStatus: true, script : 'docker ps -aq | xargs docker rm --force')
}

def shutdown()
{
  dir(ESGF_DOCKER_REPO_PATH)
  {
    info('shutting down the containers')
    sh './bin/esgf-compose down -v'
  }
}

def start_block(block_name)
{
  debug("BEGIN BLOCK ${block_name} ------------------------------------------------------")
}

def end_block(block_name)
{
  debug("END BLOCK ${block_name} --------------------------------------------------------")
}

def begin(msg)
{
  console_output(msg, INFO_TAG, Colors.BLUE)
  slack_send(msg, Colors.BLUE)
}

def success(msg)
{
  console_output(msg, SUCCESS_TAG, Colors.GREEN)
  slack_send('*SUCCESS*', Colors.GREEN)
  currentBuild.result = 'SUCCESS'
}

def failure(msg)
{
  console_output(msg, FAILURE_TAG, Colors.RED)
  slack_send('*FAILURE*', Colors.RED)
  currentBuild.result = 'FAILURE'
}

def abort(msg)
{
  console_output(msg, ABORT_TAG, Colors.RED)
  slack_send('*Aborted*', Colors.RED)
  currentBuild.result = 'ABORTED'
}

def info(msg)
{
  console_output(msg, INFO_TAG, Colors.BLUE)
}

def error(msg)
{
  console_output(msg, ERROR_TAG, Colors.RED)
}

def warn(msg)
{
  console_output(msg, WARN_TAG, Colors.YELLOW)
}

def debug(msg)
{
  console_output(msg, DEBUG_TAG, Colors.PURPLE)
}

def slack_send(msg, color)
{
  msg = "${env.SLACK_MSG_PREFIX} ${msg}"

  if(ENABLE_SLACK_NOTIFICATION)
  {
    withCredentials([usernamePassword(usernameVariable: 'slack_url', passwordVariable: 'slack_token', credentialsId: "${SLACK_CREDENTIAL_ID}")])
    {
      slackSend(message: msg, color: color.hexa_code, baseUrl: slack_url, channel: SLACK_CHANNEL, token: slack_token, botUser: true)
    }
  }
  else
  {
    echo("slack notifications are disable. Message was ${msg}")
  }
}

def console_output(msg, tag, color)
{
  echo(String.format("%s%s %s%s", color.xterm_code, tag, msg, '\u001B[0m'))
}