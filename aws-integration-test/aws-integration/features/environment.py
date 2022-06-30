import os


def add_env_variables_to_userdata(context):
    for name, value in os.environ.items():
        if name.startswith("CFN_"):
            context.config.userdata[name[4:]] = value


def before_all(context):
    add_env_variables_to_userdata(context)
