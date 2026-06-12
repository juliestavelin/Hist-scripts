# Hist-scripts
#!/bin/bash

# THIS SCRIPT CREATES A HISTORICAL RUN FROM 1850-1901
# SOIL DECOMPOSITION METHOD CAN BE CHOOSEN
# CHANGE THIS BASED ON SITES#
declare -A sites
sites=(
["dovre"]="c251225"
["flekkefjord"]="c251225"
["kvinesdal_1"]="c251225"
["maalselv"]="c251225"
["nissedal"]="c251225"
["sel"]="c251225"
["sortland"]="c251225"
)

#Add more sites

restart_date="0821-01-01-00000" #Change to the latest datafile

# When running script, decide for soil decomp method by typing: ./scriptname.sh mimics

decomp=$1
ndep_option=$2
co2_option=$3
echo $decomp
if [ ! -z $decomp ]; then
if [ "${decomp}" == "mimics" ]; then
DECOMP_METHOD="MIMICSWieder2015"
elif [ "${decomp}" == "mimicsplus" ]; then
DECOMP_METHOD="MIMICSplusAas2023"
elif [ "${decomp}" == "century" ]; then
DECOMP_METHOD="CENTURYKoven2013"
else
echo "WRONG DECOMP METHOD USE mimics or century"
exit 1
fi
else
echo "need decomp method as a first argument, none provided"
exit 2
fi

if [ "${ndep_option}" == "1850_1860" ]; then
NDEPOPT="1850_1860"
ndepsuf="_ndep_${NDEPOPT}"
elif [ "${ndep_option}" == "double" ]; then
NDEPOPT="double"
ndepsuf="_ndep_${NDEPOPT}"
else
NDEPOPT=""
ndepsuf="${NDEPOPT}"
fi

if [ "${co2_option}" == "1850" ]; then
CO2OPT="co2_1850"
co2suf="_${CO2OPT}"
elif [ "${co2_option}" == "double" ]; then
CO2OPT="co2_double"
co2suf="_${CO2OPT}"
else
CO2OPT=""
co2suf="${CO2OPT}"
fi


# Project accounting
CESM_ACCOUNT=nn2806k
PROJECT=nn2806k


# CLM paths
CTSMROOT=/cluster/projects/nn2806k/stavelin/ctsm
CIMEROOT=$CTSMROOT/cime

## Model components (compset)
compset=HIST_DATM%GSWP3v1_CLM60%BGC_SICE_SOCN_SROF_SGLC_SWAV # chose model compset

for plotname in "${!sites[@]}"; do
surf_suffix="${sites[$plotname]}"
case_name="${plotname}_hist_1${ndepsuf}${co2suf}_${decomp}"

# Case folder
casedir=/cluster/projects/nn2806k/stavelin/cases/$case_name
machine=betzy
resolution=CLM_USRDAT # model resolution, (singel site, different for multiple sites)

# Create a case requires three arguments (where set above):
# 1. case name, 2. resolution, 3. model compset https://docs.cesm.ucar.edu/models/cesm2/config/compsets.html
cd $CIMEROOT/scripts
echo $CIMEROOT/scripts
#./create_newcase --case $casedir --compset $compset --res $resolution --user-mods-dirs ~/${plotname}/$decomp --machine $machine --run-unsupported --handle-preexisting-dirs r --project $CESM_ACCOUNT
./create_newcase --case $casedir --compset $compset --res $resolution --user-mods-dirs /cluster/projects/nn2806k/stavelin/sites/${plotname}/user_mods --machine $machine --run-unsupported --handle-preexisting-dirs r --project $CESM_ACCOUNT

echo "finished create case"

echo ${casedir}
cd $casedir

./xmlchange DATM_PRESAERO="hist"
./xmlchange MPILIB=openmpi # something new that was not needed before, need in other scripts aswell
./xmlchange CLM_USRDAT_DIR="/cluster/projects/nn2806k/stavelin/sites/${plotname}"


# # --- Ensure that the env_run.xml file has the correct content
./xmlchange RUN_TYPE=startup
./xmlchange RUN_STARTDATE=1850-01-01
./xmlchange STOP_OPTION=nyears
./xmlchange STOP_N=51
./xmlchange CONTINUE_RUN=FALSE
./xmlchange REST_N=51
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=0

./xmlchange DATM_YR_ALIGN=1901
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange JOB_WALLCLOCK_TIME="24:00:00"
if [[ ${CO2OPT} == "co2_1850" ]]; then
./xmlchange CLM_CO2_TYPE=constant
./xmlchange CCSM_CO2_PPMV=284.3
fi

echo \
"fsurdat='/cluster/projects/nn2806k/stavelin/sites/${plotname}/surfdata_${plotname}_hist_2000_16pfts_${surf_suffix}.nc'
finidat='/cluster/work/users/stavelin/archive/${plotname}_spinup_${decomp}/rest/${restart_date}/${plotname}_spinup_${decomp}.clm2.r.${restart_date}.nc'

hist_fincl1 = 'TOTECOSYSC', 'TOTECOSYSN', 'TOTSOMC', 'TOTSOMN', 'TOTVEGC', 'TOTVEGN', 'TLAI',
'GPP', 'CPOOL', 'NPP', 'TWS', 'LEAFC', 'NDEP_TO_SMINN', 'NEP',
'SOM_AVL_C_vr', 'SOM_CHEM_C_vr', 'SOM_PHYS_C_vr', 'SOM_AVL_N_vr', 'SOM_CHEM_N_vr', 'SOM_PHYS_N_vr',
'MIC_COP_C_vr', 'MIC_OLI_C_vr'
hist_nhtfrq=0,0
hist_mfilt=12,12
hist_avgflag_pertape = 'A'
flanduse_timeseries=''
use_init_interp = .true.
use_crop=.false.
n_dom_landunits=1
hist_fields_list_file= .true.


reset_dynbal_baselines = .false." >> user_nl_clm

echo "soil_decomp_method = '${DECOMP_METHOD}'"  >> user_nl_clm

echo "stream_fldfilename_ndep = '/cluster/projects/nn2806k/stavelin/datafiles/ndep_streams_hist_const.nc'"  >> user_nl_clm

echo "ndep_varlist = 'NDEP_month_${NDEPOPT}'"  >> user_nl_clm
echo "" >> user_nl_clm


echo "---SETUP---"
./case.setup
echo "---DONE SETUP---"

./preview_namelists



# --- If you have not already built the code, then do so now
#echo "build: " ${plotname}
#./case.build --clean-all
./case.build
#echo "DONE build: " ${plotname}

#echo "Submit part 1 " ${plotname} ":"
./case.submit
done




