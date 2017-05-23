
import os
from common.environment import Configuration
from test.test import TestFlow
import logging



def main():
    app_config = Configuration()
    test = TestFlow(app_config.logger)
    if test.run_test(app_config=app_config):
        app_config.logger.info("Test success")
    else:
        app_config.logger.error("\n" + "\n".join([str(e) for e in test.errors]))
        app_config.logger.info("Test failed")
        exit(1)



if __name__ == "__main__":
    main()