#!/bin/bash

run=run_2023_01_23_relative_5_1_gbM_genes_nrpe


results() {
    echo $1 $2 \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_boot_base_alpha.txt)\
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_boot_base_beta.txt ) \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_standard_errors_alpha.txt) \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_standard_errors_beta.txt )  \
        | awk '{print $1,$2,$4,$6,$8,$10}' | awk '{print "INSERT into results VALUES (\x27'"$3"'\x27, \x27"$1"\x27, "$2", "$3" ,"$4", "$5", "$6");"}' |   psql -U constantin -d db
}
export -f results

parallel results  ::: gene ::: {0..99} ::: $run
