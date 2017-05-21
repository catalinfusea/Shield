
import argparse
import sys
import os
import logging



class Configuration:
    def __init__(self):
        self.compose_yaml = None
        self.working_dir = None
        self.docker_base_url = None
        self.logger = None
        self.logger_level = None
        self.docker_username = None
        self.docker_password = None
        self.system_ready_sleep = 60
        #append config variables here
        self.apply_environment()
        self.setup_logging()

    def apply_environment(self):
        if not ('COMPOSE_FILE' in os.environ):
            self.compose_yaml = './docker-compose.yml'
        else:
            self.compose_yaml = os.environ['COMPOSE_FILE']

        if not ('WORKING_DIRECTORY' in os.environ):
            self.working_dir = './'
        else:
            self.working_dir = os.environ['WORKING_DIRECTORY']

        if not ('DOCKER_BASE_URL' in os.environ):
            self.docker_base_url = 'unix://var/run/docker.sock'
        else:
            self.docker_base_url = os.environ['DOCKER_BASE_URL']

        if not ('LOGGER_LEVEL' in os.environ):
            self.logger_level = 'INFO'
        else:
            self.logger_level = os.environ['LOGGER_LEVEL']

        if 'DOCKER_USERNAME' in os.environ:
            self.docker_username = os.environ['DOCKER_USERNAME']

        if 'DOCKER_PASSWORD' in os.environ:
            self.docker_password = os.environ['DOCKER_PASSWORD']

        if 'SYSTEM_READY_SLEEP' in os.environ:
            self.system_ready_sleep = int(os.environ['SYSTEM_READY_SLEEP'])



    def apply_arguments(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('-f', '--file', dest='compose_yaml', type=str, default='./docker-compose.yml', help='Compose file path')
        parser.add_argument('-wd', '--working-dir', dest='working_dir', type=str, default='./', help='Compose working directory')
        parser.add_argument('-dbu', '--docker-base-url', dest='docker_base_url', type=str, default='unix://var/run/docker.sock', help='Docker base url for working with')
        parser.add_argument('-lgl', '--logger-level', dest='logger_level', type=str, default='INFO', help='Logging level => python standard')
        parser.add_argument('-du', '--docker-username', dest='docker_username', type=str, help='Username for login to docker repo', required=False)
        parser.add_argument('-dp', '--docker-password', dest='docker_password', type=str, help='Password for login to docker repo', required=False)
        parser.add_argument('-dp', '--docker-password', dest='docker_password', type=str, help='Password for login to docker repo', required=False)
        parser.add_argument('-ss', '--system-ready-sleep', dest='system_ready_sleep', type=int, help="System ready wait seconds", default=60)

        args = parser.parse_args()
        self.compose_yaml = args.compose_yaml
        self.working_dir = args.working_dir
        self.docker_base_url = args.docker_base_url
        self.logger_level = args.logger_level
        self.docker_password = args.docker_password
        self.docker_username = args.docker_username
        self.system_ready_sleep = args.system_ready_sleep


    def setup_logging(self):
        self.logger = logging.getLogger('integrated_test')
        self.logger.setLevel(logging.getLevelName(self.logger_level))
        h = logging.StreamHandler(sys.stderr)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        h.setFormatter(formatter)
        self.logger.addHandler(h)


