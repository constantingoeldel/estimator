#!/bin/bash
# # exit when any command fails
# set -e

# # keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# # echo an error message before exiting
# trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


# R --file=run.R --no-save --no-echo --no-restore --args 0 gene > /home/constantin/estimator/alphabeta_output.txt 2> /home/constantin/estimator/parallel_output.txt 
source ~/.bashrc
run=run_2023_01_24_relative_5_1_ROS


parallel --jobs 32  --retries 5 --keep-order --line-buffer   R --file=run.R --no-save --no-echo --no-restore --args  ::: gene upstream downstream ::: {0..99} > /home/constantin/windows/alphabeta_stdout.txt 2> /home/constantin/windows/alphabeta_stderr.txt


results() {
    echo $1 $2 \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_boot_base_alpha.txt)\
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_boot_base_beta.txt ) \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_standard_errors_alpha.txt) \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_standard_errors_beta.txt )  \
        | awk '{print $1,$2,$4,$6,$8,$10}' | awk '{print "INSERT into results VALUES (\x27'"$3"'\x27, \x27"$1"\x27, "$2", "$3" ,"$4", "$5", "$6");"}' |   psql -U constantin -d db
}
export -f results

echo "##########" results "##########" >> /home/constantin/windows/alphabeta_stdout.txt

parallel results  ::: upstream gene downstream ::: {0..99} ::: $run

echo "##########" done sucessfully "##########" >> /home/constantin/windows/alphabeta_stdout.txt

