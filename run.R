if (!requireNamespace("BiocManager", quietly = TRUE )) 
install.packages("BiocManager" )
#BiocManager::install(version = "3.12")
BiocManager::install("../AlphaBeta" )
#BiocManager::install("data.table")
#BiocManager::install("dplyr")
# BiocManager::install("snow")
# BiocManager::install("extendr/rextendr")

library(rextendr)
source("/home/constantin/estimator/alphabeta.R")
  i = commandArgs()[7]
  location = commandArgs()[8]

  nodeFile = "nodelist.fn"
  edgeFile = "edgelist.fn"
  print(sprintf("Calculating epimutation rate for window %s in %s", i, location))
  setwd(sprintf("/home/constantin/windows/%s/%s", location,  i))
  name = sprintf("epimutation_rate_estimation_window_%s_%s", location,  i)
  directory = sprintf("/home/constantin/windows/%s/%s", location,  i)
  delay = runif(1, 0, 100)
  print(sprintf("Delaying for %s seconds", delay)) # to avoid overloading the R socket. Weird issue. Therefore also using --retries 5 in parallel command. 
  Sys.sleep(delay)    
  run.alphabeta.new(nodelist=nodeFile,
                    edelist=edgeFile,
                    name=name,
                    input.dir=directory,
                    output.dir=directory)
  print("Finished calculating epimutation rate for window")






