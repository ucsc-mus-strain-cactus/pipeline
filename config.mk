####################################################################################################
# Configuration
# Modify variables below as new releases are made.
# Tag the commit when running the pipeline.
# NOTE: The order in which you write the organsims will determine the order of plots.
####################################################################################################


VERSION = 1509

# source organism information (reference mouse)
srcOrg = C57B6J
srcOrgHgDb = mm10

# this lists all assembly version we wish to keep live in the browser
# the last one is the default
LIVE_VERSIONS = 1509

ifeq (${VERSION},1509)
mappedOrgs = C57BL_6NJ NZO_HlLtJ 129S1_SvImJ FVB_NJ NOD_ShiLtJ LP_J A_J AKR_J BALB_cJ DBA_2J C3H_HeJ CBA_J WSB_EiJ CAST_EiJ PWK_PhJ SPRET_EiJ CAROLI_EiJ Pahari_EiJ
augustusOrgs = C57BL_6NJ NZO_HlLtJ 129S1_SvImJ FVB_NJ NOD_ShiLtJ LP_J A_J AKR_J BALB_cJ DBA_2J C3H_HeJ CBA_J WSB_EiJ CAST_EiJ PWK_PhJ SPRET_EiJ CAROLI_EiJ Pahari_EiJ
allOrgs = C57B6J C57BL_6NJ NZO_HlLtJ 129S1_SvImJ FVB_NJ NOD_ShiLtJ LP_J A_J AKR_J BALB_cJ DBA_2J C3H_HeJ CBA_J WSB_EiJ CAST_EiJ PWK_PhJ SPRET_EiJ CAROLI_EiJ Pahari_EiJ Rattus
GENCODE_VERSION = VM8
TRANS_MAP_VERSION = 2015-10-06
COMPARATIVE_ANNOTATOR_VERSION = 2015-12-17
haveRnaSeq = yes
rnaSeqStrains = 129S1_SvImJ A_J AKR_J BALB_cJ C3H_HeJ C57BL_6NJ CAST_EiJ CBA_J DBA_2J LP_J NOD_ShiLtJ NZO_HlLtJ PWK_PhJ SPRET_EiJ WSB_EiJ CAROLI_EiJ Pahari_EiJ FVB_NJ
hintsDb = /hive/groups/recon/projs/mus_strain_cactus/pipeline_data/comparative/1509_v2/augustus/hints/1509.aug.hints.db
filterTissues = lung
rnaSeqDataDir = /hive/groups/recon/projs/mus_strain_cactus/pipeline_data/rnaseq/munged_STAR_data/REL-1509-chromosomes
# no SVs on pahari/caroli
svGenomes = NOD_ShiLtJ BALB_cJ LP_J NZO_HlLtJ AKR_J PWK_PhJ WSB_EiJ CAST_EiJ CBA_J DBA_2J C3H_HeJ SPRET_EiJ 129S1_SvImJ FVB_NJ A_J C57BL_6NJ

else ifeq (${VERSION},1504)
mappedOrgs = C57B6NJ NZOHlLtJ 129S1 FVBNJ NODShiLtJ LPJ AJ AKRJ BALBcJ DBA2J C3HHeJ CBAJ WSBEiJ CASTEiJ PWKPhJ SPRETEiJ CAROLIEiJ PAHARIEiJ
augustusOrgs = C57B6NJ NZOHlLtJ 129S1 FVBNJ NODShiLtJ LPJ AJ AKRJ BALBcJ DBA2J C3HHeJ CBAJ WSBEiJ CASTEiJ PWKPhJ SPRETEiJ CAROLIEiJ PAHARIEiJ
allOrgs = C57B6J C57B6NJ NZOHlLtJ 129S1 FVBNJ NODShiLtJ LPJ AJ AKRJ BALBcJ DBA2J C3HHeJ CBAJ WSBEiJ CASTEiJ PWKPhJ SPRETEiJ CAROLIEiJ PAHARIEiJ Rattus
GENCODE_VERSION = VM4
TRANS_MAP_VERSION = 2015-05-28
CHAINING_VERSION = 2015-08-19
COMPARATIVE_ANNOTATOR_VERSION = 2015-09-01
haveRnaSeq = yes
rnaSeqStrains = 129S1 AJ AKRJ BALBcJ C3HHeJ C57B6NJ CASTEiJ CBAJ DBA2J LPJ NODShiLtJ NZOHlLtJ PWKPhJ SPRETEiJ WSBEiJ CAROLIEiJ PAHARIEiJ

else ifeq (${VERSION},1411)
mappedOrgs = C57B6NJ NZOHlLtJ 129S1 FVBNJ NODShiLtJ LPJ AJ AKRJ BALBcJ DBA2J C3HHeJ CBAJ WSBEiJ CASTEiJ PWKPhJ SPRETEiJ
augustusOrgs = C57B6NJ NZOHlLtJ 129S1 FVBNJ NODShiLtJ LPJ AJ AKRJ BALBcJ DBA2J C3HHeJ CBAJ WSBEiJ CASTEiJ PWKPhJ SPRETEiJ
allOrgs = C57B6J C57B6NJ NZOHlLtJ 129S1 FVBNJ NODShiLtJ LPJ AJ AKRJ BALBcJ DBA2J C3HHeJ CBAJ WSBEiJ CASTEiJ PWKPhJ SPRETEiJ  Rattus
GENCODE_VERSION = VM4
TRANS_MAP_VERSION = 2015-05-28
COMPARATIVE_ANNOTATOR_VERSION = 2015-09-01
haveRnaSeq = no

else
$(error config.mk variables not defined for VERSION=${VERSION})
endif
