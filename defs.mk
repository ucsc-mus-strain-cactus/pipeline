include ../pipeline/config.mk

# base directory definitions
DATA_DIR = ${PROJ_DIR}/pipeline_data
ASSMEBLIES_DIR = ${DATA_DIR}/assemblies/${VERSION}
TRANS_MAP_DIR = ${DATA_DIR}/comparative/${VERSION}/transMap
SRC_GENCODE_DATA_DIR = ${TRANS_MAP_DIR}/data
ASM_GENOMES_DIR = ${DATA_DIR}/assemblies/${VERSION}
CHAIN_DIR = ${DATA_DIR}/comparative/${VERSION}/chains
ANNOTATION_DIR = ${DATA_DIR}/comparative/${VERSION}/comparativeAnnotation
DONE_FLAG_DIR = ${DATA_DIR}/comparative/${VERSION}/pipeline_completion_flags

# root directory for jobtree jobs
jobTreeRootTmpDir = jobTree.tmp/${VERSION}

# all organisms
allOrgs = ${srcOrg} ${mappedOrgs}

# UCSC mySQL tables to be pulled from
gencodeGenes = ${gencodeGeneSet}${gencodeVersion}
gencodeAttrs = GencodeAttrs${gencodeVersion}
srcGencodeGenes = wgEncode${gencodeGenes}
srcGencodeAttrs = wgEncode${gencodeAttrs}

# src GENCODE files
srcGencodeAttrsTsv = ${SRC_GENCODE_DATA_DIR}/${srcGencodeAttrs}.tsv
srcGencodeGp = ${SRC_GENCODE_DATA_DIR}/${srcGencodeGenes}.gp
srcGencodeFa = ${SRC_GENCODE_DATA_DIR}/${srcGencodeGenes}.fa
srcGencodeFaidx = ${SRC_GENCODE_DATA_DIR}/${srcGencodeGenes}.fa.fai
srcGencodePsl = ${SRC_GENCODE_DATA_DIR}/${srcGencodeGenes}.psl
srcGencodeCds = ${SRC_GENCODE_DATA_DIR}/${srcGencodeGenes}.cds
srcGencodeBed = ${SRC_GENCODE_DATA_DIR}/${srcGencodeGenes}.bed

# transMap files
transMapGencodeGenes = transMap${gencodeGenes}

##
# Sequence files
##

# call function to obtain a assembly file given an organism and extension
asmFileFunc = ${ASM_GENOMES_DIR}/${1}.${2}

# call functions to get particular assembly files given an organism
asmFastaFunc = $(call asmFileFunc ${1},fa)
asmTwoBitFunc = $(call asmFileFunc ${1},2bit)
asmChromSizesFunc = $(call asmFileFunc ${1},chrom.sizes)

# list of sequence files
targetFastaFiles = ${mappedOrgs:%=$(call asmFastaFunc,%)}
targetTwoBitFiles = ${mappedOrgs:%=$(call asmTwoBitFunc,%)}
targetChromSizes = ${mappedOrgs:%=$(call asmChromSizesFunc,%)}
queryFasta = $(call asmFastaFunc,${srcOrg})
queryTwoBit = $(call asmTwoBitFunc,${srcOrg})
queryChromSizes = $(call asmChromSizesFunc,${srcOrg})

##
# AugustusTMR
##
AUGUSTUS_DIR = ${DATA_DIR}/comparative/${VERSION}/augustus
AUGUSTUS_TMR_DIR = ${AUGUSTUS_DIR}/tmr
AUGUSTUS_WORK_DIR = ${AUGUSTUS_DIR}/work
hintsDb = ${AUGUSTUS_DIR}/hints.db

# comparative anotations types produced
compAnnTypes = allClassifiers allAugustusClassifiers potentiallyInterestingBiology assemblyErrors alignmentErrors AugustusTMR

###
# chaining
###
CHAINING_DIR = ${DATA_DIR}/comparative/${VERSION}/chaining

# call function to  to obtain path to chain/net files, given type,srcOrg,targetOrg.
chainFunc = ${CHAINING_DIR}/${2}-${3}.${1}.chain.gz
netFunc = ${CHAINING_DIR}/${2}-${3}.${1}.net.gz

# call functions to obtain path to chain/net files, given srcOrg,targetOrg.
chainFunc = $(call chainFunc,all,${1},${2})
netFunc = $(call netFunc,all,${1},${2})
chainSynFunc = $(call chainFunc,syn,${1},${2})
netSynFunc = $(call netFunc,syn,${1},${2})


###
# makefile stuff
###
host=$(shell hostname)
ppid=$(shell echo $$PPID)
tmpExt = ${host}.${ppid}.tmp


.SECONDARY:  # keep intermediates
SHELL = /bin/bash -beEu
export SHELLOPTS := pipefail
export PATH := ${PYTHON_BIN_DIR}:${PYCBIO_DIR}/bin:./bin:${HAL_BIN_DIR}:${AUGUSTUS_BIN_DIR}:${PATH}
export PYTHONPATH := ./:${PYTHONPATH}


ifeq (${TMPDIR},)
     $(error TMPDIR environment variable not set)
endif
