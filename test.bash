# # exit when any command fails
# set -e

# # keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# # echo an error message before exiting
# trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


# R --file=run.R --no-save --no-echo --no-restore --args 0 gene > /home/constantin/estimator/alphabeta_output.txt 2> /home/constantin/estimator/parallel_output.txt 


parallel --jobs 26 --retries 5 --lb  R --file=run.R --no-save --no-echo --no-restore --args  ::: gene upstream downstream  ::: {0..1} > /home/constantin/estimator/alphabeta_test_stdout.txt 2> /home/constantin/estimator/alphabeta_test_stderr.txt 

echo "##########" done sucessfully "##########" >> /home/constantin/estimator/alphabeta_test_stdout.txt
