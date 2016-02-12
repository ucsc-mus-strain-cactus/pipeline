#!/usr/bin/env python
import sys
import os
import luigi
import ete3
import argparse
# need to set environ also in order for it to be passed on to jobTree
# TODO: this should be in some sort of sourceme.bash file.
os.environ['PYTHONPATH'] = './:./submodules:./submodules/pycbio'
sys.path.extend(['./', './submodules', './submodules/pycbio'])
from pipeline import GenomeFiles, AnnotationFiles, ChainFiles, TransMap, RunComparativeAnnotator
from config import Configuration
from lib.parsing import HashableNamespace, NamespaceAction, FileArgumentParser
from jobTree.scriptTree.stack import Stack


class RunPipeline(luigi.WrapperTask):
    """
    Pipeline starts here.
    """
    params = luigi.Parameter()

    def requires(self):
        cfgs = []
        for gene_set in self.params.geneSets:
            # in cases where the user specifies a subset of target genomes, re-add the source genome to the set.
            target_genomes = set(self.params.targetGenomes)
            target_genomes.add(gene_set.sourceGenome)
            for target_genome in target_genomes:
                cfg = Configuration(self.params, gene_set.sourceGenome, target_genome, gene_set)
                cfgs.append(cfg)
                yield GenomeFiles(cfg)
                yield AnnotationFiles(cfg)
                yield ChainFiles(cfg)
                yield TransMap(cfg)
                yield RunComparativeAnnotator(cfg)

##### TODO: need to error check that all geneSets variables are correct

def parse_args():
    """
    Build argparse object, parse arguments. See the parsing library for a lot of the features used here.
    """
    parser = FileArgumentParser(description=__doc__)
    parser.add_argument('--geneSets', action=NamespaceAction, required=True, metavar='KEY=VALUE',
                        help='Input gene sets. Expects groups of four key-value pairs in the format --geneSets '
                             'geneSet=Ensembl sourceGenome=C_elegans genePred=testdata/c_elegans.transcripts.gp '
                             'attributesTsv=testdata/ce11.ensembl.attributes.tsv')
    parser.add_argument('--targetGenomes', default=None, nargs='+',
                        help='Space-separated list of genomes you wish to annotate. '
                             'If not set, all non-reference genomes will be annotated.')
    parser.add_argument_with_mkdir_p('--workDir', default='work', metavar='DIR',
                                     help='Work directory. Will contain intermediate files that may be useful.')
    parser.add_argument_with_mkdir_p('--outputDir', default='output', metavar='DIR', help='Output directory.')
    parser.add_argument_with_check('--hal', required=True, metavar='FILE',
                                   help='HAL alignment file produced by progressiveCactus')
    parser.add_argument_with_check('--cactusConfig', required=True, metavar='FILE',
                                   help='progressiveCactus configuration file used to generate the HAL alignment file.')
    parser.add_argument('--localCores', default=12, metavar='INT',
                        help='Number of local cores to use. (default: %(default)d)')
    jobtree = parser.add_argument_group('jobTree options. Read the jobTree documentation for other options not shown')
    jobtree.add_argument('--batchSystem', default='parasol', help='jobTree batch system.')
    jobtree.add_argument('--parasolCommand', default='./bin/remparasol',
                         help='Parasol command used by jobTree. Used to remap to host node.')
    jobtree.add_argument('--maxThreads',
                         help='maxThreads for jobTree. If not using a cluster, this should be --localCores/# genomes')
    jobtree_parser = argparse.ArgumentParser(add_help=False)
    Stack.addJobTreeOptions(jobtree_parser)
    args = parser.parse_args(namespace=HashableNamespace())
    args.jobTreeOptions = jobtree_parser.parse_known_args(namespace=HashableNamespace())[0]
    # modify args to have newick string and list of all genomes
    newick_str, genomes = extract_newick_genomes_cactus(args.cactusConfig)
    args.genomes = genomes
    if args.targetGenomes is None:
        args.targetGenomes = genomes
    args.tree = newick_str
    # make hashable
    args.geneSets = tuple(args.geneSets)
    # add genome order to each source gene set
    for gene_set in args.geneSets:
        gene_set.orderedTargetGenomes = build_genome_order(newick_str, gene_set.sourceGenome)
    # set directory that jobTrees will be made in
    args.jobTreeDir = os.path.join(args.workDir, 'jobTrees')
    # if batchSystem/parasolCommand are not supplied on the command line, they will be the jobTree defaults. Fix this.
    args.jobTreeOptions.batchSystem = args.batchSystem
    args.jobTreeOptions.parasolCommand = args.parasolCommand
    # make the default jobTree dir None so that it crashes if I am stupid
    args.jobTreeOptions.jobTree = None
    # manually check that all geneSet files exist because my fancy FileArgumentParser can't do this
    for geneSet in args.geneSets:
        assert os.path.exists(geneSet.genePred), 'Error: genePred file {} missing.'.format(args.geneSet.genePred)
        assert os.path.exists(geneSet.attributesTsv), 'Error: attributes file {} missing.'.format(args.geneSet.attributesTsv)
    return args


def build_genome_order(newick_str, ref_genome):
    """
    Takes a newick format string and a single genome and reports the genetic distance of each genome in the tree
    from the reference genome. Used to order plots from closest to furthest from the source genome.
    """
    t = ete3.Tree(newick_str)
    distances = [[t.get_distance(ref_genome, x), x.name] for x in t if x.name != ref_genome]
    ordered = sorted(distances, key=lambda (dist, name): dist)
    distances, ordered_names = zip(*ordered)
    return ordered_names


def extract_newick_genomes_cactus(cactus_config):
    """
    Parse the cactus config file, extracting just the newick tree
    """
    f_h = open(cactus_config)
    newick = f_h.next().rstrip()
    genomes = tuple(x.split()[0] for x in f_h)
    return newick, genomes


if __name__ == '__main__':
    args = parse_args()
    luigi.build([RunPipeline(args)], local_scheduler=True, workers=args.localCores)
