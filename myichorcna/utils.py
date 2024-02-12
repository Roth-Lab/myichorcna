import os
from yaml import load, FullLoader


def make_output_dirs(output_directory: str) -> None:
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)


def load_config_file(configuration_file: str) -> dict:
    with open(configuration_file, 'r') as cf:
        config = load(cf, Loader=FullLoader)
    return config