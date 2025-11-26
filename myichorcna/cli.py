import click
from myichorcna.call_ichorcna import run_ichorCNA, run_hmmsegment

@click.command()
@click.option(
    '-o',
    '--output-dir',
    type=click.STRING,
    required=True,
    help="Path to directory to output results from ichorCNA."
)
@click.option(
    '-c',
    '--ctdna-wig-file',
    type=click.STRING,
    required=True,
    help="Path to read counts of ctDNA data outputted by readCounter (.wig)"
)
@click.option(
    "-d",
    '--sample-id',
    default='DummySampleID',
    type=click.STRING,
    required=False,
    help="cfDNA sample ID"
)
@click.option(
    '-s',
    '--ichorcna-params',
    type=click.STRING,
    required=True,
    help="Path to config file for settings of ichorCNA (.yaml)."
)
def run(**kwargs):
    run_ichorCNA(**kwargs)
    
    
@click.command()
@click.option(
    '-o',
    '--output-dir',
    type=click.STRING,
    required=True,
    help="Path to directory to output results from ichorCNA."
)
@click.option(
    '-c',
    '--ctdna-tsv-file',
    type=click.STRING,
    required=True,
    help="Path to read counts of ctDNA data outputted by readCounter (.wig)"
)
@click.option(
    "-d",
    '--sample-id',
    default='DummySampleID',
    type=click.STRING,
    required=False,
    help="cfDNA sample ID"
)
@click.option(
    '-s',
    '--ichorcna-params',
    type=click.STRING,
    required=True,
    help="Path to config file for settings of ichorCNA (.yaml)."
)
def run_hmm(**kwargs):
    run_hmmsegment(**kwargs)


@click.group(name='myichorcna')
def main():
    pass


main.add_command(run)
main.add_command(run_hmm)


if __name__ == "__main__":
    main()
