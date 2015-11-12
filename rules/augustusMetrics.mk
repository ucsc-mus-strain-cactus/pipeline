#####
# Final Augustus metric plots.
#####
include defs.mk

# Paths
comparativeAnnotationDir = ${ANNOTATION_DIR}
consensusDir = ${comparativeAnnotationDir}/consensus
metricsDir = ${consensusDir}/metrics
consensusWorkDir = ${AUGUSTUS_WORK_DIR}/consensus

# done flag dir
metricsFlag = ${DONE_FLAG_DIR}/augustus_metrics.done

all: ${metricsFlag}

${metricsFlag}:
	@mkdir -p $(dir $@)
	${python} comparativeAnnotator/plotting/consensus_plots.py --compAnnPath ${comparativeAnnotationDir} \
	--genomes ${augustusOrgs} --gencode ${gencodeGenes} --workDir ${consensusWorkDir} --outDir ${metricsDir}
	touch $@

clean:
	rm -rf ${metricsFlag}