#####
# Assembly hub construction. Uses singleMachine because of weird bug on ku with liftovers.
#####

include defs.mk

comparativeAnnotationDir = ${ANNOTATION_DIR}
assemblyHubDir = ${comparativeAnnotationDir}/assemblyHub

# jobTree
jobTreeTmpDir = $(shell pwd -P)/${jobTreeRootTmpDir}/assembly_hub
jobTreeJobOutput = ${jobTreeTmpDir}/assembly_hub.out
jobTreeJobDir = ${jobTreeTmpDir}/jobTree
jobTreeDone = ${DONE_FLAG_DIR}/assemblyHub.done


all: ${jobTreeDone}

${jobTreeDone}:
	@mkdir -p $(dir $@)
	@mkdir -p ${jobTreeTmpDir}
	bigBedDirs="$(shell /bin/ls -1d ${comparativeAnnotationDir}/bigBedfiles/* | paste -s -d ",")" ;\
	${python} hal2assemblyHub.py ${jobTreeOpts} \
	--batchSystem singleMachine --jobTree ${jobTreeJobDir} ${halFile} ${assemblyHubDir} \
	--finalBigBedDirs $$bigBedDirs --shortLabel ${VERSION} --longLabel ${VERSION} \
	--hub ${VERSION} &> ${jobTreeJobOutput}
	touch $@

clean:
	rm -rf ${jobTreeDone} ${jobTreeJobDir} ${assemblyHubDir}
