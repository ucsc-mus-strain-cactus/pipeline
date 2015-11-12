include defs.mk

all: ${mappedOrgs:%=%.transMapOrg}

clean: ${mappedOrgs:%=%.transMapOrgClean}

%.transMapOrg:
	${MAKE} -f rules/transMap.mk transMap mapTargetOrg=$*

%.transMapOrgClean:
	${MAKE} -f rules/transMap.mk transMapClean mapTargetOrg=$*


ifneq (${mapTargetOrg},)
###
# These are only defined when mapTargetOrg is defined by recursive make: 
#    mapTargetOrg - specifies the target organism
###
transMapDataDir = ${TRANS_MAP_DIR}/transMap/${mapTargetOrg}

# sequence files needed
targetFasta = ${ASM_GENOMES_DIR}/${mapTargetOrg}.fa
targetTwoBit = ${ASM_GENOMES_DIR}/${mapTargetOrg}.2bit
targetChromSizes = ${ASM_GENOMES_DIR}/${mapTargetOrg}.chrom.sizes

# chained (final results)
transMapPsl = ${transMapDataDir}/${gencodeGenes}.psl

# final transMap predicted transcript annotations
transMapGp = ${transMapDataDir}/${gencodeGenes}.gp

# chain files
mappingChains = ${CHAINING_DIR}/${srcOrg}-${mapTargetOrg}.all.chain.gz


transMap: ${transMapPsl} ${transMapGp}

transMapClean: 
	rm -rf ${transMapDataDir}/transMap*.psl ${transMapDataDir}/transMap*.gp


###
# genomic chain mapping
###

# map and update match stats, which likes target sort for speed
${transMapPsl}: ${srcGencodePsl} ${srcGencodeFa} ${mappingChains} ${targetTwoBit}
	@mkdir -p $(dir $
	pslMap -chainMapFile ${srcGencodePsl} ${mappingChains} /dev/stdout \
		| bin/postTransMapChain /dev/stdin /dev/stdout \
		| sort -k 14,14 -k 16,16n \
		| pslRecalcMatch /dev/stdin ${targetTwoBit} ${srcGencodeFa} stdout \
		| bin/pslQueryUniq > $@.${tmpExt}
	mv -f $@.${tmpExt} $@

###
# final transMap genes
###
${transMapGp}: ${transMapPsl} ${srcGencodeCds}
	@mkdir -p $(dir $@)
	mrnaToGene -keepInvalid -quiet -genePredExt -ignoreUniqSuffix -insertMergeSize=0 -cdsFile=${srcGencodeCds} $< $@.${tmpExt}
	mv -f $@.${tmpExt} $@

endif
