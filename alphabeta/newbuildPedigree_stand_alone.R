#' Building Pedigree
#'
#' calculate divergence times of the pedigree
#'
#' @param nodelist input file containing information on generation times and pedigree lineages
#' "extdata" called "nodelist.fn"
#' @param edgelist input file containing edges
#' @param cytosine Type of cytosine (CHH/CHG/CG)
#' @param posteriorMaxFilter Filter value, based on posteriorMax
#' @import dplyr
#' @importFrom  data.table fread
#' @importFrom  data.table fwrite
#' @importFrom  data.table as.data.table
#' @importFrom  stringr str_replace_all
#' @importFrom  gtools mixedorder
#' @importFrom  utils combn
#' @importFrom  igraph graph_from_data_frame
#' @importFrom  igraph layout_as_tree
#' @importFrom  igraph all_shortest_paths
#' @importFrom  igraph V
#' @importFrom  igraph V<-
#' @return generating divergence matrices file.
#' @export
#' @examples
#'# Get some toy data
#' file <- system.file("extdata/dm/","nodelist.fn", package="AlphaBeta")
#' df<-read.csv(file)
#' df$filename <- gsub("^", paste0(dirname(dirname(file)),"/"), df$filename )
#' write.csv(df, file = paste0(dirname(file),"/", "tmp_nodelist.fn"), row.names=FALSE, quote=FALSE)
#' file <- system.file("extdata/dm/","tmp_nodelist.fn", package="AlphaBeta")
#' file2 <- system.file("extdata/dm/","edgelist.fn", package="AlphaBeta")
#' buildPedigree(nodelist = file, edgelist=file2, cytosine="CG", posteriorMaxFilter=0.99)


newbuildPedigree <- function(nodelist, edgelist , cytosine="CG", posteriorMaxFilter=0.99) {
  library("AlphaBeta");library(igraph);library(data.table);library(stringr);library(gtools);library(utils);library(dplyr)
  source("/home/constantin/estimator/alphabeta/time.R")
  #source("/home/zhilin/documents/software/new_AlphaBeta_2022-03/AlphaBeta/R/D-matrices.R")
  source("/home/constantin/estimator/alphabeta/convertDMATRIX.R")
  #source("/home/zhilin/documents/software/new_AlphaBeta_2022-03/AlphaBeta/R/BOOTmodel.R")
  #source("/home/zhilin/documents/software/new_AlphaBeta_2022-03/AlphaBeta/R/checkFun.R")
  
  mt <- startTime("constracting pedigree ...\n")
  # constracting D-Matrices from sample file
  dmatrix <- dMatrix(nodelist, cytosine, posteriorMaxFilter)
  
  # constracting Rc.Meth.lvl from sample file
  message("generating Rc.Meth.lvl from sample file....\n")
  
  #old-version  
  # rclvl <- rc.meth.lvl(nodelist, cytosine, posteriorMaxFilter)
  # props <- rclvl[which(as.character(rclvl[, 2]) == cytosine), ]
  # outliers <- "none"
  # props <- rclvl[which(!is.element(rclvl[, 1], outliers) == TRUE), ]
  # tmpP0uu<- 1 - mean(as.numeric(as.character(props[, 3])))
  
  #new-version
  files<-fread(nodelist)
  
  # files<-files[files$meth=="Y"]
  collect_U_proportion_row<-NULL
  for (j in 1:nrow(files)){
    if (files$filename[j] == "-") next
    print(files$filename[j])
    file<-fread(files$filename[j])
    file_filter<-file[file$context==cytosine & file$posteriorMax>=posteriorMaxFilter]
    U_proportion<-dim(file_filter[file_filter$status=="U"])[1]/dim(file_filter)[1]
    U_proportion_row<-data.frame(files$node[j],cytosine,U_proportion)
    collect_U_proportion_row<-rbind(collect_U_proportion_row,U_proportion_row)
  }
  colnames(collect_U_proportion_row)<-c("Sample_name","context","U_proportion")
  rclvl <- rc.meth.lvl(nodelist, cytosine, posteriorMaxFilter)
  props <- rclvl[which(as.character(rclvl[, 2]) == cytosine), ]
  props<-merge(rclvl,collect_U_proportion_row,by=c("Sample_name","context"))
  outliers <- "none"
  props<- props[which(!is.element(props[, 1], outliers) == TRUE), ]
  tmpP0uu <- mean(as.numeric(as.character(props[, 4])))
  
  message("finilizing pedegree data...")
  # converting D-matrix into pedegree
  
  # reading matrix
  edges   <- fread(edgelist, header=TRUE, skip=0)
  samples <- fread(nodelist, header=TRUE, skip=0, select = c(2,3,4))
  # check file 'sample' if there is column 'Branchpoint_date' then it's tree
  if (!is.null(samples$Branchpoint_date)){
    #rename column to 'gen' to run normal covertMatrix fun.
    colnames(samples)[2]<-"gen"
  }
  
  tmpPedegree <- convertDMATRIX(samples, edges, dmatrix)
  
  cat(stopTime(mt))
  return(list(Pdata=tmpPedegree,tmpp0=tmpP0uu))
}
