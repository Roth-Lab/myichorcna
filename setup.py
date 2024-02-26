from setuptools import find_packages, setup

setup(
    name='myichorcna',
    description='A python package to run ichorCNA for my experiments',
    author='matteo lepur',
    author_email='matteolepur@stat.ubc.ca',
    packages=find_packages(),
    package_data={
        "myichorcna.ichorCNA.inst.extdata": ["*.txt", "*.wig", "*.rds"],
        "myichorcna.ichorCNA.R": ["*.R"],
        "myichorcna.ichorCNA.scripts": ["*.R"]
    },
    entry_points={
        'console_scripts': ['myichorcna = myichorcna.cli:main']
    }
)