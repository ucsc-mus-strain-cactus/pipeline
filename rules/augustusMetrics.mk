#####
# Final Augustus metric plots.
#####
include defs.mk

# Paths
comparativeAnnotationDir = ${ANNOTATION_DIR}/${augustusGencodeSet}
consensusDir = ${comparativeAnnotationDir}/consensus_v2
metricsDir = ${consensusDir}/metrics_v2
consensusWorkDir = ${AUGUSTUS_WORK_DIR}/consensus_v2

# done flag dir
metricsFlag = ${DONE_FLAG_DIR}/${augustusGencodeSet}_augustus_metrics_v2.done

all: ${metricsFlag}

${metricsFlag}:
	@mkdir -p $(dir $@)
	cd ../comparativeAnnotator && ${python} plotting/gene_set_plots.py --compAnnPath ${comparativeAnnotationDir} \
	--genomes ${augustusOrgs} --refGenome ${srcOrg} --gencode ${augustusGencodeSet} --workDir ${consensusWorkDir} \
    --outDir ${metricsDir}
	touch $@

clean:
	rm -rf ${metricsFlag}