
#!/bin/bash

module purge
module load NCO/5.1.3-foss-2022a

set -e

arch=$USERWORK/archive
cmp=$USERWORK/combined_arch_doubleN   # ← separate output folder from normal nitrogen

mkdir -p $cmp

# Get unique site names
sites=$(ls $arch | grep "ndep_double" | sed 's/_hist_[12]_ndep_double_mimics//' | sort -u)

for site in $sites; do

    outfile="${cmp}/${site}_doubleN_combined.nc"

    if [[ -f "$outfile" ]]; then
        echo "Skipping $outfile (already exists)"
        continue
    fi

    part1="${arch}/${site}_hist_1_ndep_double_mimics/lnd/hist/*.nc"
    part2="${arch}/${site}_hist_2_ndep_double_mimics/lnd/hist/*.nc"

    files=""
    for part in "$part1" "$part2"; do
        if ls $part 1>/dev/null 2>&1; then
            files="$files $part"
        fi
    done

    if [[ -z "$files" ]]; then
        echo "WARNING: No files found for $site, skipping"
        continue
    fi

    echo "Combining $site: $files"
    ncrcat $files "$outfile"

done

echo "Done!"


#ndep 1850-1860

#!/bin/bash

module purge
module load NCO/5.1.3-foss-2022a

set -e

arch=$USERWORK/archive
cmp=$USERWORK/combined_arch_ndep_1850_1860

mkdir -p $cmp

# Get unique site names
sites=$(ls $arch | grep "ndep_1850_1860" | sed 's/_hist_[12]_ndep_1850_1860_mimics//' | sort -u)

for site in $sites; do

    outfile="${cmp}/${site}_ndep_1850_1860_combined.nc"

    if [[ -f "$outfile" ]]; then
        echo "Skipping $outfile (already exists)"
        continue
    fi

    part1="${arch}/${site}_hist_1_ndep_1850_1860_mimics/lnd/hist/*.nc"
    part2="${arch}/${site}_hist_2_ndep_1850_1860_mimics/lnd/hist/*.nc"

    files=""
    for part in "$part1" "$part2"; do
        if ls $part 1>/dev/null 2>&1; then
            files="$files $part"
        fi
    done

    if [[ -z "$files" ]]; then
        echo "WARNING: No files found for $site, skipping"
        continue
    fi

    echo "Combining $site"
    ncrcat $files "$outfile"

done

echo "Done!"

#matvey sin versjon, alle stedene
#!/bin/bash

module purge 

module load NCO/5.1.3-foss-2022a

set -e

arch=$USERWORK/archive

if [[ ! -d "${USERWORK}/combined_arch" ]]; then
    mkdir ${USERWORK}/combined_arch
fi

cmp="${USERWORK}/combined_arch"

cd $arch

for dir in `ls ./`; do

    echo $dir
    if [[ ! -f "${cmp}/${dir}_combined.nc" ]]; then
        ncrcat $dir/lnd/hist/*nc "${cmp}/${dir}_combined.nc" 
    else
        echo "skipping ${cmp}/${dir}_combined.nc"
    fi
done



#!/bin/bash

module purge
module load NCO/5.1.3-foss-2022a

set -e

arch=$USERWORK/archive
cmp=$USERWORK/combined_arch_ndep_1850_co2_1850

mkdir -p $cmp

# Get unique site names
sites=$(ls $arch | grep "ndep_1850_1860_co2_1850" | sed 's/_hist_[12]_ndep_1850_1860_co2_1850_mimics//' | sort -u)

for site in $sites; do

    outfile="${cmp}/${site}_ndep_1850_co2_1850_combined.nc"

    if [[ -f "$outfile" ]]; then
        echo "Skipping $outfile (already exists)"
        continue
    fi

    part1="${arch}/${site}_hist_1_ndep_1850_1860_co2_1850_mimics/lnd/hist/*.nc"
    part2="${arch}/${site}_hist_2_ndep_1850_1860_co2_1850_mimics/lnd/hist/*.nc"

    files=""
    for part in "$part1" "$part2"; do
        if ls $part 1>/dev/null 2>&1; then
            files="$files $part"
        fi
    done

    if [[ -z "$files" ]]; then
        echo "WARNING: No files found for $site, skipping"
        continue
    fi

    echo "Combining $site: $files"
    ncrcat $files "$outfile"

done

echo "Done!"



#!/bin/bash

module purge
module load NCO/5.1.3-foss-2022a

set -e

arch=$USERWORK/archive
cmp=$USERWORK/combined_arch_co2_1850

mkdir -p $cmp

# Get unique site names
sites=$(ls $arch | grep "co2_1850" | sed 's/_hist_[12]_co2_1850_mimics//' | sort -u)

for site in $sites; do

    outfile="${cmp}/${site}_co2_1850_combined.nc"

    if [[ -f "$outfile" ]]; then
        echo "Skipping $outfile (already exists)"
        continue
    fi

    part1="${arch}/${site}_hist_1_co2_1850_mimics/lnd/hist/*.nc"
    part2="${arch}/${site}_hist_2_co2_1850_mimics/lnd/hist/*.nc"

    files=""
    for part in "$part1" "$part2"; do
        if ls $part 1>/dev/null 2>&1; then
            files="$files $part"
        fi
    done

    if [[ -z "$files" ]]; then
        echo "WARNING: No files found for $site, skipping"
        continue
    fi

    echo "Combining $site: $files"
    ncrcat $files "$outfile"

done

echo "Done!"
