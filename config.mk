####################################################################################################
# Configuration
# Modify variables below as new releases are made.
# Tag the commit when running the pipeline.
# NOTE: The order in which you write the organsims will determine the order of plots.
####################################################################################################

# general config options
VERSION = susie_3_1
srcOrg = human
srcOrgHgDb = hg38
mappedOrgs = gorilla gorGor3 orang chimp squirrel_monkey
augustusOrgs = gorilla
gencodeVersion = V23
gencodeGeneSet = GencodeBasic

# HAL file
halFile = ${DATA_DIR}/comparative/${VERSION}/cactus/${VERSION}.hal

# base project directory that all files will be made in
PROJ_DIR = /hive/groups/recon/projs/gorilla_eichler

# SQL command
mysql = mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A

###
# parasol
###
parasolHost = ku

# jobTree configuration
batchSystem = parasol
maxThreads = 20
defaultMemory = 8589934592
maxJobDuration = 28800
jobTreeOpts = --defaultMemory ${defaultMemory} --batchSystem ${batchSystem} --parasolCommand $(shell pwd -P)/bin/remparasol \
              --maxJobDuration ${maxJobDuration} --maxThreads ${maxThreads} --stats


# binary locations
PYTHON_BIN_DIR = /hive/groups/recon/local/bin
AUGUSTUS_BIN_DIR = /hive/users/ifiddes/augustus/trunks/bin

# TODO: get Mark's pycbio library as a package in either comparativeAnnotator or pipeline repo
PYCBIO_DIR = ${PROJ_DIR}/src/pycbio
python = ${PYTHON_BIN_DIR}/python

KENT_DIR = ${HOME}/kent
KENT_HG_LIB_DIR = ${KENT_DIR}/src/hg/lib