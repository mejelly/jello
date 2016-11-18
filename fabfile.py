from fabric.api import env, run, cd
from time import sleep
import os

def staging():
    env.host_string = os.environ['STAGING_HOSTNAME']
    env.user = os.environ['STAGING_USERNAME']
    env.use_ssh_config = True

def deploy():
    with cd('/home/mejelly/jello'):
        run("docker pull {}:{}".format(os.environ['REPO'], os.environ['COMMIT']))
        run("docker-compose -f docker-compose.production.yml run web rails db:migrate")
        run("docker-compose -f docker-compose.production.yml up -d web")
        sleep(3)
        run("docker-compose -f docker-compose.production.yml exec web chown -R app. /mejelly")
