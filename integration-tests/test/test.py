

from compose.config import config
from compose.config.config import ConfigDetails
from compose.config.config import ConfigFile
from compose.project import Project
from compose.config.validation import validate_against_config_schema
import docker
import requests
import time

class TestFlow:

    def __init__(self, logger):
        self.logger = logger
        self.errors = []
        self.services_list = ["consul", "shield-admin", "shield-admin1",
                              "shield-browser", "proxy-server", "extproxy",
                              "icap-server", "elk", "portainer"]
        self.current_shield_proxy = {
                  'http': 'http://localhost:3128',
                  'https': 'http://localhost:3128',
                }
        self.already_up = False
        self.system_ready_sleep = 60


    def setup_test(self, app_config):
        self.app_config = app_config
        self.config_file = ConfigFile('system_compose', config.load_yaml(app_config.compose_yaml))
        self.config_details = ConfigDetails(app_config.working_dir, [self.config_file])
        self.main_config = config.load(self.config_details)
        self.client = docker.DockerClient(base_url=app_config.docker_base_url)
        self.project = Project.from_config('integration_test', self.main_config, client= self.client.api)
        self.already_up = True

    def run_test(self, logger=None, app_config=None):
        if logger is None:
            current_logger = self.logger
        else:
            current_logger = logger

        current_logger.info("Start test")
        try:
            if not self.already_up:
                self.logger.info("Start setup process")

                self.setup_test(app_config)

                self.logger.info("Setup success")

            self.logger.info('Test login')
            if not self.docker_login():
                self.logger.info('Login failed')
                return False

            if not self.check_services():
                self.logger.info('Services check is failed')
                return False

            self.run_project()
            self.test_running_system()
            return True
        except Exception as e:
            self.errors.append(e)
            return False
        finally:
            if self.project:
                try:
                    self.stop_project()
                except Exception as ex:
                    if "network integration_test_default" in str(ex):
                        self.logger.info("Can't stop system due docker compose open BUG, trust on system prune raise by Jenkins")
                    else:
                        raise ex
            current_logger.info('End test')


    def check_services(self):
        define_length = len(self.services_list)
        current_length = len(self.project.service_names)
        if define_length != current_length:
            message = "Wrong number of services. Define {0} configured {1}".format(define_length, current_length)
            self.create_error(message)
            return False

        for name in self.services_list:
            if not name in self.project.service_names:
                message = "{0} defined, but not found in project".format(name)
                self.create_error(message)
                return False
        return True

    def create_error(self, message):
        self.logger.info(message)
        self.errors.append(message)

    def docker_login(self):
        if self.app_config.docker_username and self.app_config.docker_password:
            try:
                self.client.login(username=self.app_config.docker_username, password=self.app_config.docker_password)
                self.logger.info('Login to docker repo success')
                return True
            except Exception as e:
                self.logger.error('Login to docker repo failed')
                self.logger.error(e)
                return False

    def run_project(self):
        self.project.up()
        self.project.get_service("consul").scale(3)
        self.project.get_service("shield-browser").scale(5)

    def stop_project(self):
        self.logger.info("Going stop system")
        self.project.down(False, False)


    def test_running_system(self):
        self.logger.info("Test running system")
        test_count = 1
        test_failed = False
        while test_count <= self.app_config.retry_count:
            self.logger.info("Going to sleep {0} seconds for system ready. Make proxy-server health check!!!!".format(self.app_config.system_ready_sleep))
            time.sleep(self.app_config.system_ready_sleep)
            self.logger.info("Weak up continue testing")
            self.logger.info("Going execute test number {0}".format(test_count))
            try:
                self.run_urls_test()
                test_failed = False
                break
            except Exception as e:
                self.errors.append(str(e))
                self.logger.error("Test number {0} failed with {1}".format(test_count, e))
                test_failed = True
            test_count += 1

        if test_failed:
            err = "{0} test attempts failed".format(test_count -1)
            self.logger.error(err)
            raise Exception(err)

    def find_proxy_server(self):
        pass

    def run_urls_test(self):
        if self.app_config.urls_file is None:
            self.run_single_url_test('http://ericom.com')
        else:
            with open(self.app_config.urls_file, mode='rb') as file:
                for url in file:
                    self.run_single_url_test(url)

    def run_single_url_test(self, url):
        self.logger.info("Start test {0} url".format(url))
        r = requests.get(url, proxies=self.current_shield_proxy)
        if not 'Protected by Ericom Shield' in r.text:
            raise Exception("Can't find: Protected by Ericom Shield in returned page")
        result = "Status code: {0}, return html: {1}".format(r.status_code, r.text)
        self.logger.info(result)