from setuptools import find_packages, setup

REQUIREMENTS = []
for line in open('requirements.txt').readlines():
    REQUIREMENTS.append(line)

setup(
    name='myichorcna',
    description='A python package to run ichorCNA for my experiments',
    packages=find_packages(),
    include_package_data=True,
    package_data={"myichorcna.ichorCNA": ["*"]},
    entry_points={'console_scripts': ['myichorcna = myichorcna.cli:main']},
    install_requires=REQUIREMENTS
)