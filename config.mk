####################################################################################################
# Configuration
# Modify variables below as new releases are made.
# Tag the commit when running the pipeline.
####################################################################################################

GORILLA_VERSION = susie_3_1
srcOrg = human
srcOrgHgDb = hg38

ifeq (${GORILLA_VERSION},susie_3_1)
mappedOrgs = chimp gorilla orang squirrel_monkey gorGor3
augustusOrgs = gorilla
allOrgs = chimp gorilla human orang squirrel_monkey gorGor3
GENCODE_VERSION = V23
TRANS_MAP_VERSION = 2015-10-06
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-10-12

else ifeq (${GORILLA_VERSION},susie_3)
mappedOrgs = chimp gorilla orang squirrel_monkey
augustusOrgs = gorilla
allOrgs = chimp gorilla human orang squirrel_monkey
GENCODE_VERSION = V23
TRANS_MAP_VERSION = 2015-10-06
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-10-12

else
$(error config.mk variables not defined for GORILLA_VERSION=${GORILLA_VERSION})
endif
