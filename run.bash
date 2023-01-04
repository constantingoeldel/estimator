# # exit when any command fails
# set -e

# # keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# # echo an error message before exiting
# trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


# R --file=run.R --no-save --no-echo --no-restore --args 0 gene > /home/constantin/estimator/alphabeta_output.txt 2> /home/constantin/estimator/parallel_output.txt 


parallel --jobs 26  --retries 5 --lb  R --file=run.R --no-save --no-echo --no-restore --args ::: {0..99} ::: upstream gene downstream > /home/constantin/estimator/alphabeta_stdout.txt 2> /home/constantin/estimator/alphabeta_stderr.txt

results() {
    echo $1 $2 \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_boot_base_alpha.txt)\
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_boot_base_beta.txt ) \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_standard_errors_alpha.txt) \
        $(tail -n 2 /home/constantin/windows/$1/$2/Boutput_standard_errors_beta.txt )  \
        | awk '{print $1,$2,$4,$6,$8,$10}'   
}
export -f results

echo "##########" results "##########" >> /home/constantin/estimator/alphabeta_stdout.txt

parallel results  ::: upstream gene downstream ::: {0..99} > /home/constantin/estimator/results.txt 

echo "##########" done sucessfully "##########" >> /home/constantin/estimator/alphabeta_stdout.txt

