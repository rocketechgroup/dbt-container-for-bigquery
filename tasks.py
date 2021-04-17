import os

from invoke import task

required_envs = ['PROJECT_ID', 'LOCATION', 'DEFAULT_DATASET']


def get_env(env_name):
    env_value = os.environ.get(env_name)
    if not env_value:
        raise ValueError(f'Environment variable {env_name} is not defined')


def validate():
    try:
        [get_env(name) for name in required_envs]
    except ValueError as e:
        print(e)
        exit(1)


@task
def build(c):
    validate()
    c.run("docker-compose build")


@task
def exec(c, cmd, image='dbt-dev'):
    validate()
    print(f'Will execute: {cmd}')
    c.run(f"docker-compose run --rm {image} /bin/bash -c \"pipenv run {cmd}\"")


@task
def debug(c, cmd, image='dbt-dev'):
    validate()
    c.run(f"docker-compose run --rm {image} /bin/bash -c \"{cmd}\"")
