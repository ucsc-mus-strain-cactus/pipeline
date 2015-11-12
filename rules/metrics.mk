#####
# Final metric plots.
#####
include defs.mk

# output location
comparativeAnnotationDir = ${ANNOTATION_DIR}
metricsDir = ${comparativeAnnotationDir}/metrics
metricsFlag = ${DONE_FLAG_DIR}/metrics.done

all: ${metricsFlag}

clean:
	rm -rf ${metricsFlag}

${metricsFlag}:
	@mkdir -p $(dir $@)
	cd ../comparativeAnnotator && ${python} plotting/transmap_analysis.py --outDir ${metricsDir} \
	--genomes ${mappedOrgs} --refGenome ${srcOrg} --gencode ${gencodeGenes} \
	--comparativeAnnotationDir ${comparativeAnnotationDir}
	touch $@
