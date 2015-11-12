####################################################################################################
# Configuration
# Modify variables below as new releases are made.
# Tag the commit when running the pipeline.
# NOTE: The order in which you write the organsims will determine the order of plots.
####################################################################################################

# general config options

# genome assembly version
VERSION = susie_3_1
# src organism, as named in the HAL
srcOrg = human
# src organism UCSC database for mySQL queries
srcOrgHgDb = hg38
# organisms aligned, as named in the HAL
mappedOrgs = gorilla gorGor3 orang chimp squirrel_monkey
# organisms you wish to run AugustusTMR on
augustusOrgs = gorilla
# the UCSC database you wish to use, will be joined together as ${gencodeGeneSet}${gencodeVersion}
gencodeVersion = V23
gencodeGeneSet = GencodeBasic

# HAL file
halFile = /hive/groups/recon/projs/gorilla_eichler/pipeline_data/comparative/${VERSION}/cactus/${VERSION}.hal

# base project directory that all files will be made in
PROJ_DIR = /hive/groups/recon/projs/gorilla_eichler

# Location of Augustus BAMfiles in the directory format <organism>/<whatever>.bam
# For each organism, every file that ends in .bam will be included, but flags can be used to exclude files.
# See augustusHints.mk for more.
rnaSeqDataDir = /hive/groups/recon/projs/gorilla_eichler/data/rnaseq

# Base mySQL command
mysql = mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A

# jobTree configuration
batchSystem = parasol
defaultMemory = 8589934592
maxJobDuration = 28800
jobTreeOpts = --defaultMemory ${defaultMemory} --batchSystem ${batchSystem} --maxJobDuration ${maxJobDuration} --stats

# binary locations
PYTHON_BIN_DIR = /hive/groups/recon/local/bin
AUGUSTUS_BIN_DIR = /hive/users/ifiddes/augustus/trunks/bin

python = ${PYTHON_BIN_DIR}/python

KENT_DIR = ${HOME}/kent
KENT_HG_LIB_DIR = ${KENT_DIR}/src/hg/lib