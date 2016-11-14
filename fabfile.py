from fabric.api import env, run, cd
import os

def staging():
    env.host_string = os.environ['STAGING_HOSTNAME']
    env.user = os.environ['STAGING_USERNAME']
    env.use_ssh_config = True

def deploy():
    with cd('/home/mejelly/jello'):
        run("docker pull {}:{}".format(os.environ['REPO'], os.environ['COMMIT']))
        run("docker-compose -f mejelly/docker-compose.production.yml run web rails db:migrate")
