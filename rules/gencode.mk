####
# obtain gencode data for the reference mouse
####
include defs.mk

###
# src genes
###
all: ${srcGencodeAttrsTsv} ${srcGencodeGp} ${srcGencodeBed} ${srcGencodeFa} ${srcGencodeFaidx} \
	 ${srcGencodePsl} ${srcGencodeCds} ${queryFasta} ${queryTwoBit} ${queryChromSizes}

clean:
	rm -rf ${srcGencodeAttrsTsv} ${srcGencodeGp} ${srcGencodeBed} ${srcGencodeFa} ${srcGencodeFaidx} \
	${srcGencodePsl} ${srcGencodeCds} ${queryFasta} ${queryTwoBit} ${queryChromSizes}


# NOTE: if you need to change UCSC->ensembl names, or filter out chromosomes you need to do so when making the genePred

${srcGencodeAttrsTsv}:
	@mkdir -p $(dir $@)
	${mysql} -e 'select geneId,geneName,geneType,transcriptId,transcriptType from ${srcGencodeAttrs}' ${srcOrgHgDb} > $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${srcGencodeGp}:
	@mkdir -p $(dir $@)
	${mysql} -Ne 'select * from $*' ${srcOrgHgDb} | cut -f 2- > $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${srcGencodeBed}: ${srcGencodeGp}
	@mkdir -p $(dir $@)
	genePredToBed $< $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${srcGencodeFa}: ${srcGencodeBed} ${queryFasta}
	@mkdir -p $(dir $@)
	fastaFromBed -fi ${queryFasta} -fo /dev/stdout -bed $< -name -split -s | faFilter -uniq stdin $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${srcGencodeFaidx}: ${srcGencodeFa}
	@mkdir -p $(dir $@)
	samtools faidx $<

# sillyness to make multiple productions work in make.
# touch ensures that CDS is newer than psl
${srcGencodeCds}: ${srcGencodePsl}
	touch $@
${srcGencodePsl}: ${srcGencodeGp} ${queryChromSizes}
	@mkdir -p $(dir $@)
	# genePredToFakePsl can run without mySQL, but still need a placeholder database table
	genePredToFakePsl -chromSize=${queryChromSizes} NA $< $@.${tmpExt} ${srcGencodeCds}
	mv -f $@.${tmpExt} $@

${queryFasta}:
	@mkdir -p $(dir $@)
	${HAL_BIN_DIR}/hal2fasta ${halFile} ${srcOrg} > $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${queryTwoBit}: ${queryFasta}
	@mkdir -p $(dir $@)
	faToTwoBit $< $@.${tmpExt}
	mv -f $@.${tmpExt} $@

${queryChromSizes}: ${queryTwoBit}
	@mkdir -p $(dir $@)
	twoBitInfo $< stdout | sort -k2rn > $@.${tmpExt}
	mv -f $@.${tmpExt} $@
