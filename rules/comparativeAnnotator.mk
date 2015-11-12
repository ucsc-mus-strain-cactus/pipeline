####
# Run comparativeAnnotator
####
include defs.mk

all: ${mappedOrgs:%=%.mapOrg}

clean: ${mappedOrgs:%=%.mapOrgClean}

%.maporg:
	${MAKE} -f rules/comparativeAnnotator.mk runOrg mapTargetOrg=$*

%.mapOrgClean:
	${MAKE} -f rules/comparativeAnnotator.mk cleanOrg mapTargetOrg=$*

ifneq (${mapTargetOrg},)

# comparativeAnnotator mode
mode = transMap

# done flag dir
doneFlagDir = ${DONE_FLAG_DIR}/${mapTargetOrg}

# jobTree (for transMap comparativeAnnotator)
jobTreeCompAnnTmpDir = $(shell pwd -P)/${jobTreeRootTmpDir}/comparativeAnnotator/${mapTargetOrg}
jobTreeCompAnnJobOutput = ${jobTreeCompAnnTmpDir}/comparativeAnnotator.out
jobTreeCompAnnJobDir = ${jobTreeCompAnnTmpDir}/jobTree
comparativeAnnotationDone = ${doneFlagDir}/comparativeAnnotation.done

# jobTree (for clustering classifiers)
jobTreeClusteringTmpDir = $(shell pwd -P)/${jobTreeRootTmpDir}/clustering/${mapTargetOrg}
jobTreeClusteringJobOutput = ${jobTreeClusteringTmpDir}/clustering.out
jobTreeClusteringJobDir = ${jobTreeClusteringTmpDir}/jobTree
clusteringDone = ${doneFlagDir}/classifierClustering.done

# output location
comparativeAnnotationDir = ${ANNOTATION_DIR}
metricsDir = ${comparativeAnnotationDir}/metrics

# input files
transMapDataDir = ${TRANS_MAP_DIR}/transMap/${mapTargetOrg}
psl = ${transMapDataDir}/${gencodeGenes}.psl
targetGp = ${transMapDataDir}/${gencodeGenes}.gp
refFasta = ${ASM_GENOMES_DIR}/${srcOrg}.fa
targetFasta = ${ASM_GENOMES_DIR}/${mapTargetOrg}.fa
targetSizes = ${ASM_GENOMES_DIR}/${mapTargetOrg}.chrom.sizes

runOrg: ${comparativeAnnotationDone} ${clusteringDone}

${comparativeAnnotationDone}: ${psl} ${targetGp} ${srcGencodeGp} ${refFasta} ${targetFasta} ${targetSizes}
	@mkdir -p $(dir $@)
	@mkdir -p ${comparativeAnnotationDir}
	@mkdir -p ${jobTreeCompAnnTmpDir}
	${python} comparativeAnnotator/src/annotation_pipeline.py ${mode} ${jobTreeOpts} \
	--refGenome ${srcOrg} --genome ${mapTargetOrg} --annotationGp ${srcGencodeGp} --psl ${psl} --targetGp ${targetGp} \
	--fasta ${targetFasta} --refFasta ${refFasta} --sizes ${targetSizes} --outDir ${comparativeAnnotationDir} \
	--gencodeAttributes ${srcGencodeAttrsTsv} --jobTree ${jobTreeCompAnnJobDir} --refPsl ${srcGencodePsl} \
	&> ${jobTreeCompAnnJobOutput}
	touch $@

${clusteringDone}: ${comparativeAnnotationDone}
	@mkdir -p $(dir $@)
	@mkdir -p ${jobTreeClusteringTmpDir}
	${python} comparativeAnnotator/plotting/clustering.py --mode transMap ${jobTreeOpts} \
	--genome ${mapTargetOrg} --refGenome ${srcOrg} --outDir ${metricsDir} \
	--comparativeAnnotationDir ${comparativeAnnotationDir} --gencode ${gencodeGenes} \
	--jobTree ${jobTreeClusteringJobDir} &> ${jobTreeClusteringJobOutput}
	touch $@


cleanOrg:
	rm -rf ${jobTreeCompAnnJobDir} ${comparativeAnnotationDone} ${jobTreeClusteringJobDir} ${clusteringDone}

endif