// SYSTEM SETTINGS
WAITING_TIME=240 // in seconds.

INFO_TAG='[INFO]'
ERROR_TAG='[ERROR]'
DEBUG_TAG='[DEBUG]'
WARN_TAG='[WARN]'

IS_SUCCESS = false

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
      label 'master'
      // Don't let Jenkins generate the workspace name: too long, crash the
      // ESGF config generation.
      // env.WORKSPACE is unknown at this step.
      // Jenkins appends the branch at the end of this path.
      customWorkspace "${env.JENKINS_HOME}/workspace/${env.JOB_NAME}"
    } 
  }

  options
  {
    ansiColor('xterm')
    timeout(time: 15, unit: 'MINUTES')
    disableConcurrentBuilds()
    timestamps()    
  }
  
  environment
  {
    /*** ESGF-DOCKER **/
    ESGF_HUB='esgfhub'
    ESGF_PREFIX=''
    ESGF_DOCKER_REPO_PATH="${env.WORKSPACE}"
    ESGF_HOSTNAME=sh(returnStdout: true, script: 'hostname')
    ESGF_CONFIG="${env.WORKSPACE}/config"
    ESGF_DATA="${env.WORKSPACE}/data"

    /*** ESGF TEST SUITE ***/
    ESGF_TEST_SUITE_REPO_PATH="${env.WORKSPACE}/esgf-test-suite"
    TEST_DIR_PATH="${ESGF_TEST_SUITE_REPO_PATH}/esgf-test-suite"
    SINGULARITY_FILENAME='esgf-test-suite_env.singularity.img'
    SINGULARITY_IMG_URL="http://distrib-coffee.ipsl.jussieu.fr/pub/esgf/dist/esgf-test-suite/${SINGULARITY_FILENAME}"
    SINGULARITY_FILE_PATH="${TEST_DIR_PATH}/${SINGULARITY_FILENAME}"
    TESTS='-a !compute,basic -a cog_root_login -a slcs_django_admin_login'
    CONFIG_FILE_PATH="${env.JENKINS_HOME}/esgf/my_config_docker.ini"

    /*** ESGF DOCKER SECRETS ***/
    ROOT_ADMIN_SECRET_FILE_PATH="${ESGF_CONFIG}/secrets/rootadmin-password"

    /*** SLACK ***/
    SLACK_CHANNEL='#esgf-docker-ci'
    SLACK_CREDENTIAL_ID='slack_esgf_esgf-docker-ci'
  }

  stages
  {
    stage('configuration') { steps {
      
      script
      {
        if(env.BRANCH_NAME=='master')
        {
          env.ESGF_VERSION='latest'
        }
        else
        {
          env.ESGF_VERSION='devel'
        }

        msg = String.format("ESGF-test-suite <%s|#%s>: testing commit '%s' from branch %s", env.BUILD_URL, env.BUILD_ID, env.GIT_COMMIT, env.BRANCH_NAME)

        info(msg)
        slack_send(msg, Colors.BLUE)
      }    
    }} 

    stage('checkout') { steps {

      dir(ESGF_TEST_SUITE_REPO_PATH)
      {
        info('checkout esgf-test-suite')
        git(url: 'https://github.com/ESGF/esgf-test-suite.git')
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
    }}
    
    stage('images') { steps {
      info("fetch the last docker images from ${ESGF_HUB}/*:${ESGF_VERSION}")
      dir(ESGF_DOCKER_REPO_PATH){sh 'docker-compose pull'}
      info('local images:')
      sh 'docker images'
    }}
    
    stage('config') { steps {
      info('delete the previous configuration files of ESGF docker')
      sh 'rm -fr "${ESGF_CONFIG}" ; mkdir "${ESGF_CONFIG}"; mkdir -p "${ESGF_DATA}"'
      dir(ESGF_DOCKER_REPO_PATH)
      {
        info('generating esgf secrets')
        sh 'docker-compose run -u $UID esgf-setup generate-secrets'
        info('generating certificates')
        sh 'docker-compose run -u $UID esgf-setup generate-test-certificates'
        info('creating trust bundle')
        sh 'docker-compose run -u $UID esgf-setup create-trust-bundle'
        sh 'chmod +r "${ESGF_CONFIG}/certificates/hostcert/hostcert.key"'
        sh 'chmod +r "${ESGF_CONFIG}/certificates/slcsca/ca.key"'
      }
    }}
    
    stage('start') { steps {
      dir(ESGF_DOCKER_REPO_PATH)
      {
        script
        {
          // We must export the env var otherwise orp, slcs and auth keep restarting.
          return_code = sh(returnStatus: true, script: """
            set +x
            export ESGF_CONFIG=${ESGF_CONFIG}
            export ESGF_DATA=${ESGF_DATA}
            export ESGF_HOSTNAME=${ESGF_HOSTNAME}
            docker-compose up -d
            """)

          if(return_code != 0)
          {
            error('something went wrong during the containers boot phase')
            shutdown()
            currentBuild.result = 'FAILURE'
            return
          }
          else
          {
            info("waiting ${WAITING_TIME} seconds for the containers")
            sleep(time:WAITING_TIME, unit: 'SECONDS')
            info('container status:')
            sh 'docker ps'
          }
        }
      }
    }}
    
    stage('test') { steps {
      info('running the tests')
      dir(TEST_DIR_PATH)
      {
        script
        {
          admin_passwd=readFile(ROOT_ADMIN_SECRET_FILE_PATH)
          slcs_secret_conf="slcs.admin_password:${admin_passwd}"
          cog_secret_conf="cog.admin_password:${admin_passwd}"

          // Add set +x so as to hide the passwords
          // (default bash options are -xe)
          return_code=sh(returnStatus: true, script: """
            set +x
            singularity exec "${SINGULARITY_FILE_PATH}" \
              python2 esgf-test.py ${TESTS} \
              -v --nocapture --nologcapture \
              --rednose --force-color --hide-skips \
              --tc-file "${CONFIG_FILE_PATH}" \
              --tc="${slcs_secret_conf}" \
              --tc="${cog_secret_conf}"
            """)
          if(return_code != 0)
          {
            info('one or more tests have failed, log of the containers:')
            dir(ESGF_DOCKER_REPO_PATH) {sh 'docker-compose logs'}
            currentBuild.result = 'FAILURE'
            IS_SUCCESS = false
          }
          else
          {
            IS_SUCCESS = true
          }
        }
      }
    }}

    stage('shutdown') { steps {
      shutdown()
      script
      {
        msg_prefix="ESGF-test-suite #${env.BUILD_ID}:"

        if(IS_SUCCESS)
        {
          msg = "${msg_prefix} *SUCCESS*"
          success(msg)
          slack_send(msg, Colors.GREEN)
        }
        else
        {
          msg = "${msg_prefix} *FAILURE*"
          failure(msg)
          slack_send(msg, Colors.RED)
        }
      }
    }}
  }
}

def shutdown()
{
  dir(ESGF_DOCKER_REPO_PATH)
  {
    info('shutting down the containers')
    sh 'docker-compose down -v'
  }
}

def success(msg)
{
  notify(msg, INFO_TAG, Colors.GREEN)
}

def failure(msg)
{
  notify(msg, ERROR_TAG, Colors.RED)
}

def info(msg)
{
  notify(msg, INFO_TAG, Colors.BLUE)
}

def error(msg)
{
  notify(msg, ERROR_TAG, Colors.RED)
}

def warn(msg)
{
  notify(msg, WARN_TAG, Colors.YELLOW)
}

def debug(msg)
{
  notify(msg, DEBUG_TAG, Colors.PURPLE)
}

def notify(msg, tag, color)
{
  console_output(msg, tag, color)
}

def slack_send(msg, color)
{
  withCredentials([usernamePassword(usernameVariable: 'slack_url', passwordVariable: 'slack_token', credentialsId: "${SLACK_CREDENTIAL_ID}")])
  {
    slackSend(message: msg, color: color.hexa_code, baseUrl: slack_url, channel: SLACK_CHANNEL, token: slack_token, botUser: true)
  }
}

def console_output(msg, tag, color)
{
  echo(String.format("%s%s %s%s", color.xterm_code, tag, msg, '\u001B[0m'))
}
