from pathlib import Path
import yaml
from myichorcna.call_ichorcna import call_ichorCNA

def run_ichorCNA(
    output_dir: str, 
    ctdna_wig_file: str,
    ichorcna_params: str, 
    sample_id: str = 'DummySampleID'
) -> None:
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True, parents=True)
    settings = yaml.safe_load(open(ichorcna_params, 'r'))
    settings['WIG'] = ctdna_wig_file
    settings['id'] = sample_id
    settings['outDir'] = output_dir
    call_ichorCNA(ichorParams=settings)

