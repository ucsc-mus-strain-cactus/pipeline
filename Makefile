include defs.mk
.PHONY: test

all: genomeFiles chaining transMap comparativeAnnotator metrics

augustus: genomeFiles chaining transMap comparativeAnnotator augustusComparativeAnnotator augustusMetrics

genomeFiles:
	${MAKE} -f rules/genomeFiles.mk

chaining: genomeFiles
	${MAKE} -f rules/chaining.mk

gencode: genomeFiles
	${MAKE} -f rules/gencode.mk

transMap: chaining gencode
	${MAKE} -f rules/transMap.mk

comparativeAnnotator: transMap
	${MAKE} -f rules/comparativeAnnotator.mk
	${MAKE} -f rules/referenceComparativeAnnotator.mk

augustusComparativeAnnotator: comparativeAnnotator
	${MAKE} -f rules/augustusComparativeAnnotator.mk

metrics: comparativeAnnotator
	${MAKE} -f rules/metrics.mk

augustusMetrics: augustusComparativeAnnotator
	${MAKE} -f rules/augustusMetrics.mk

test:
	python scripts/parseSDP_test.py
	python -m doctest -v scripts/*.py