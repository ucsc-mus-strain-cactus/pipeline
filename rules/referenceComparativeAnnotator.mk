####
# Run comparativeAnnotator on the reference
####
include defs.mk

# comparativeAnnotator mode
mode = reference

# done flag dir
doneFlagDir = ${DONE_FLAG_DIR}/${srcOrg}

# jobTree (for transMap comparativeAnnotator)
jobTreeCompAnnTmpDir = $(shell pwd -P)/${jobTreeRootTmpDir}/comparativeAnnotator/${srcOrg}
jobTreeCompAnnJobOutput = ${jobTreeCompAnnTmpDir}/comparativeAnnotator.out
jobTreeCompAnnJobDir = ${jobTreeCompAnnTmpDir}/jobTree
comparativeAnnotationDone = ${doneFlagDir}/comparativeAnnotation.done

# jobTree (for clustering classifiers)
jobTreeClusteringTmpDir = $(shell pwd -P)/${jobTreeRootTmpDir}/clustering/${srcOrg}
jobTreeClusteringJobOutput = ${jobTreeClusteringTmpDir}/clustering.out
jobTreeClusteringJobDir = ${jobTreeClusteringTmpDir}/jobTree
clusteringDone = ${doneFlagDir}/classifierClustering.done

# output location
comparativeAnnotationDir = ${ANNOTATION_DIR}
metricsDir = ${comparativeAnnotationDir}/metrics


all: ${comparativeAnnotationDone} ${clusteringDone}

${comparativeAnnotationDone}: ${srcGencodeGp} ${queryFasta} ${querySizes}
	@mkdir -p $(dir $@)
	@mkdir -p ${comparativeAnnotationDir}
	@mkdir -p ${jobTreeCompAnnTmpDir}
	cd ../comparativeAnnotator && ${python} src/annotation_pipeline.py ${mode} ${jobTreeOpts} \
	--refGenome ${srcOrg} --annotationGp ${srcGencodeGp} --queryFasta ${queryFasta} --sizes ${querySizes} \
	--gencodeAttributes ${srcGencodeAttrsTsv} --outDir ${comparativeAnnotationDir} \
	--jobTree ${jobTreeCompAnnJobDir} &> ${jobTreeCompAnnJobOutput}
	touch $@

${clusteringDone}: ${comparativeAnnotationDone}
	@mkdir -p $(dir $@)
	@mkdir -p ${jobTreeClusteringTmpDir}
	cd ../comparativeAnnotator && ${python} plotting/clustering.py ${jobTreeOpts} \
	--genome ${srcOrg} --refGenome ${srcOrg} --outDir ${metricsDir} \
	--comparativeAnnotationDir ${comparativeAnnotationDir} --gencode ${gencodeSubset} \
	--jobTree ${jobTreeClusteringJobDir} --mode reference &> ${jobTreeClusteringJobOutput}
	touch $@

clean:
	rm -rf ${jobTreeCompAnnJobDir} ${comparativeAnnotationDone} ${clusteringDone} ${jobTreeClusteringJobDir}
