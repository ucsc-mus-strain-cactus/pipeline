#!/usr/bin/env python
import time
import os
from argparse import ArgumentParser
from glob import glob
from toil.job import Job
from toil.common import Toil
from sonLib.bioio import system

# There are 3 phases to the process: splitting the input, running
# repeatmasker, and concatenation of the repeat-masked pieces.

def concatenate_job(job, input_ids, lift_id):
    lift_path = job.fileStore.readGlobalFile(lift_id)
    output = os.path.join(job.fileStore.getLocalTempDir(), 'rm.out')
    input_paths = map(job.fileStore.readGlobalFile, input_ids)
    system("liftUp {output} {lift_file} error {inputs}".format(output=output, lift_file=lift_path, inputs=" ".join(input_paths)))
    return job.fileStore.writeGlobalFile(output)

def repeat_masking_job(job, input_fasta, species):
    local_fasta = os.path.join(job.fileStore.getLocalTempDir(), 'input.fa')
    job.fileStore.readGlobalFile(input_fasta, local_fasta, cache=False)
    system("RepeatMasker -species '{species}' {input}".format(species=species, input=local_fasta))
    output_path = local_fasta + '.out'
    masked_out = job.fileStore.writeGlobalFile(output_path)
    return masked_out

def split_fasta(input_fasta, split_size, work_dir):
    lift_file = os.path.join(work_dir, "lift")
    system("faSplit -lift={lift_file} size {input} {split_size} {out_root}".format(
        input=input_fasta,
        split_size=split_size,
        out_root=os.path.join(work_dir, "out"),
        lift_file=lift_file))
    return (lift_file, glob(os.path.join(work_dir, "out*")))

def split_fasta_job(job, input_fasta, opts):
    work_dir = job.fileStore.getLocalTempDir()
    local_fasta = os.path.join(work_dir, 'in.fa')
    job.fileStore.readGlobalFile(input_fasta, local_fasta)
    lift_file, split_fastas = split_fasta(local_fasta, opts.split_size, work_dir)
    lift_id = job.fileStore.writeGlobalFile(lift_file)
    split_fasta_ids = [job.fileStore.writeGlobalFile(f) for f in split_fastas]
    repeat_masked = [job.addChildJobFn(repeat_masking_job, id, opts.species).rv() for id in split_fasta_ids]
    return job.addFollowOnJobFn(concatenate_job, repeat_masked, lift_id).rv()

def parse_args():
    parser = ArgumentParser(description=__doc__)
    parser.add_argument('input_fasta')
    parser.add_argument('species')
    parser.add_argument('split_size', type=int, default=200000)
    parser.add_argument('output')
    Job.Runner.addToilOptions(parser)
    return parser.parse_args()

def main():
    opts = parse_args()
    with Toil(opts) as toil:
        input_fasta_id = toil.importFile('file://' + os.path.abspath(opts.input_fasta))
        job = Job.wrapJobFn(split_fasta_job, input_fasta_id, opts)
        result_id = toil.run(job)
        toil.exportFile(result_id, 'file://' + os.path.abspath(opts.output))

if __name__ == '__main__':
    main()
