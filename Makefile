include defs.mk
.PHONY: test

all: genomeFiles gencode chaining transMap referenceComparativeAnnotator comparativeAnnotator metrics

augustus: all augustusDb augustusComparativeAnnotator metrics augustusMetrics

init:
	git submodule update --init --recursive
	cd comparativeAnnotator/jobTree && make
	cd comparativeAnnotator/sonLib && make
	cd comparativeAnnotator/hal && make
	cd pycbio && make

genomeFiles:
	${MAKE} -f rules/genomeFiles.mk

chaining: genomeFiles
	${MAKE} -f rules/chaining.mk

gencode: genomeFiles
	${MAKE} -f rules/gencode.mk

transMap: chaining gencode
	${MAKE} -f rules/transMap.mk

referenceComparativeAnnotator: transMap
	${MAKE} -f rules/referenceComparativeAnnotator.mk

comparativeAnnotator: referenceComparativeAnnotator
	${MAKE} -f rules/comparativeAnnotator.mk

augustusDb:
	${MAKE} -f rules/augustusHints.mk

augustusComparativeAnnotator: comparativeAnnotator
	${MAKE} -f rules/augustusComparativeAnnotator.mk

metrics: comparativeAnnotator
	${MAKE} -f rules/metrics.mk

augustusMetrics: augustusComparativeAnnotator
	${MAKE} -f rules/augustusMetrics.mk

clean:
	${MAKE} -f rules/genomeFiles.mk clean
	${MAKE} -f rules/chaining.mk clean
	${MAKE} -f rules/gencode.mk clean
	${MAKE} -f rules/transMap.mk clean
	${MAKE} -f rules/referenceComparativeAnnotator.mk clean
	${MAKE} -f rules/comparativeAnnotator.mk clean
	${MAKE} -f rules/metrics.mk clean

cleanAugustus:
	${MAKE} -f rules/augustusComparativeAnnotator.mk clean
	${MAKE} -f rules/augustusMetrics.mk clean
	${MAKE} -f rules/augustusHints.mk clean