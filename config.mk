####################################################################################################
# Configuration
# Modify variables below as new releases are made.
# Tag the commit when running the pipeline.
# NOTE: The order in which you write the organsims will determine the order of plots.
####################################################################################################

VERSION = susie_3_1
srcOrg = human
srcOrgHgDb = hg38

ifeq (${VERSION},susie_3_1)
mappedOrgs = gorilla gorGor3 orang chimp squirrel_monkey
augustusOrgs = gorilla
allOrgs = human gorilla gorGor3 orang chimp squirrel_monkey
GENCODE_VERSION = V23
TRANS_MAP_VERSION = 2015-10-06
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-10-12

else ifeq (${VERSION},susie_3)
mappedOrgs = gorilla orang chimp squirrel_monkey
augustusOrgs = gorilla
allOrgs = human gorilla orang chimp squirrel_monkey
GENCODE_VERSION = V23
TRANS_MAP_VERSION = 2015-10-06
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-10-12

else
$(error config.mk variables not defined for VERSION=${VERSION})
endif
