## Function readGGobiXML
## Returns a list of functions giving access to the variables of a  GGobi XML file
## Formal argument x can be the name of a a xml GGobi file
## or an object of class XMLDocument.
readGGobiXML <- function(x ## The name of a GGobi XML file or of a  
XMLDocument of R workspace
                         ) {

  ## Check the class of x
  if ( !identical(class(x)[1], "character") && !identical(class(x) 
[1], "XMLDocument"))
    stop(paste(deparse(substitute(x)), "is neither a character nor  
an XMLDocument."))

  ## load library XML if its not already done
  require(XML)

  ## For potential further use keep a character variable with the  name of x
  xName <- deparse(substitute(x))

  ## if x is a file name load the file
  if (identical(class(x)[1], "character"))
    x <- xmlTreeParse(x)

  ## Define function XMLDocument returning the full XMLDocument object
  XMLDocument <- function() x

  ## Define variable theGGobiDataNames
  theGGobiDataNames <- as.character(xmlSApply(x$doc$children 
[["ggobidata"]],
                                              xmlName)
                                    )

  ## Define function nbDataSets returning the number of data sets
  nbDataSets <- function()
    sum(theGGobiDataNames == "data")


  ## Define function index2set making a correspondance between an
  ## index running from 1 and the total number of data sets and
  ## the actual set index in the ggobidata tree
  matchRange <- seq(along = theGGobiDataNames)[theGGobiDataNames ==  
"data"]
  index2set <- function(i) matchRange[i]

  ## Define function dataSetNames returning the value of the name  
attribute of the data sets
  dataSetNames <- function() {
    as.character(sapply(1:nbDataSets(),
                        function(i) xmlAttrs(x$doc$children 
[["ggobidata"]][[index2set(i)]])["name"]
                        )
                 )
  }

  ## Define function setName2Index
  ## This function allows to go from a data set name to its index
  setName2Index <- function(setName) return( index2set((1:nbDataSets 
())[setName == dataSetNames()]) )

  ## Define function dataSetElements
  ## This function returns the names of the elements of a specific  
data set
  dataSetElements <- function(setIndex) {
    setIndex <- setName2Index(setIndex)
    elementSize <- xmlSize(x$doc$children[["ggobidata"]][[setIndex]])
    as.character(xmlSApply(x$doc$children[["ggobidata"]][[setIndex]],
                           xmlName
                           )
                 )
  }

  ## Define function dataSetDescription returning the content of  
the description of a given
  ## data set
  dataSetDescription <- function(dataSet = 1) {
    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    ## When a number is given convert it to a names
    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    ## Check that the data set contains a description
    if ( !("description" %in% dataSetElements(dataSet)) )
      return("Data set without description.")

    result <- cat("\n",
                  xmlValue(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["description"]]),
                  "\n"
                  )
    invisible(result)
  }

  ## Define function nbVariables returning the  number of variables  
of a given data set
  nbVariables <- function(dataSet = 1) {
    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    xmlSize(x$doc$children[["ggobidata"]][[setName2Index(dataSet)]] 
[["variables"]])
  }

  ## Define function variableNames returning the variable names of  
a given data set
  variableNames <- function(dataSet = 1) {
    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    if (nbVariables(dataSet) > 0) {
      as.character(xmlSApply(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["variables"]],
                             xmlName
                             )
                   )
      } else {
      cat("\n Data set with no variable.\n \n")
      NULL
    }
  }

  ## Define function variableAttrNames returning the value of the  
attribute name of the variables
  ## of a specific data set
  variableAttrNames <- function(dataSet = 1) {
    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    thisNbVar <- nbVariables(dataSet)
    if (thisNbVar > 0) {
      as.character(sapply(1:thisNbVar,
                          function(i) xmlAttrs(x$doc$children 
[["ggobidata"]][[setName2Index(dataSet)]][["variables"]][[i]])["name"]
                          )
                   )
      } else {
      cat("\n Data set with no variable.\n \n")
      NULL
    }
  }

  ## Define function recordAttributes returning the value of the  
record(s)
  ## of a specific data set
  recordAttributes <- function(dataSet = 1) {
    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    return(names(xmlAttrs(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["records"]][["record"]])
                 )
           )
  }

  ## Define function rangeRealVar returning the range of a real  
variable
  ## of a specific data set. The range is here obtained from the  
values
  ## of attributes min and max of the variable if they are available.
  ## The first formal argument defines the data set and the second
  ## the names (ie, value of the name attribute) of the variable
  rangeRealVar <- function(dataSet = 1, varNameAttr){

    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    thisNbVar <- nbVariables(dataSet)
    if (thisNbVar > 0) {

      ## Check the class of varNameAttr
      if ( !identical(class(varNameAttr)[1], "character") )
        stop(paste(deparse(substitute(varNameAttr)), "is not a  
character."))

      ## Check that varNameAttr is indeed a name attribute
      if ( !( varNameAttr %in% variableAttrNames(dataSet) ) )
        stop(paste(deparse(substitute(varNameAttr)),
                   " does not figure among the name attribute of  
the variables of",
                   xName,
                   ".",
                   sep = "")
             )

      ## Get the index of the chosen variable
      chosenIndex <- (1:thisNbVar)[varNameAttr == variableAttrNames 
(dataSet)]
      ## Check that the chosen variable is indeed real
      if ( variableNames(dataSet)[chosenIndex] != "realvariable" )
        stop(paste(deparse(substitute(varNameAttr)),
                   "is not a real variable.")
             )
      min <- as.numeric(xmlAttrs(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["variables"]][[chosenIndex]])["min"])
      max <- as.numeric(xmlAttrs(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["variables"]][[chosenIndex]])["max"])
      return(c(min = min, max = max))
    } else {
      cat("\n Data set with no variable.\n \n")
      NULL
    }
  }


  ## Define function nlevelsCatVar returning the number of levels a  
categorical variable
  ## from a data set specified by the first formal argument and  
whose name is specified by
  ## the second formal argument
  nlevelsCatVar <- function(dataSet = 1, varNameAttr) {

    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    thisNbVar <- nbVariables(dataSet)
    if (thisNbVar > 0) {

      ## Check the class of varNameAttr
      if ( !identical(class(varNameAttr)[1], "character") )
        stop(paste(deparse(substitute(varNameAttr)), "is not a  
character."))

      ## Check that varNameAttr is indeed a name attribute
      if ( !( varNameAttr %in% variableAttrNames(dataSet) ) )
        stop(paste(deparse(substitute(varNameAttr)),
                   " does not figure among the name attribute of  
the variables of",
                   xName,
                   ".",
                   sep = "")
             )

      ## Get the index of the chosen variable
      chosenIndex <- (1:thisNbVar)[varNameAttr == variableAttrNames 
(dataSet)]
      ## Check that the chosen variable is indeed categorical (ie,  
a factor)
      if ( variableNames(dataSet)[chosenIndex] !=  
"categoricalvariable" )
        stop(paste(deparse(substitute(varNameAttr)),
                   "is not a categorical (factor) variable.")
             )

      result <- as.numeric(xmlAttrs(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["variables"]][[chosenIndex]] 
[["levels"]])["count"])
      return(result)
    } else {
      cat("\n Data set with no variable.\n \n")
      NULL
    }

  }

  ## Define function levelsCatVar returning the levels a  
categorical variable
  ## from a data set specified by the first formal argument and  
whose name is specified by
  ## the second formal argument
  levelsCatVar <- function(dataSet = 1, varNameAttr) {

    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    thisNbVar <- nbVariables(dataSet)
    if (thisNbVar > 0) {
      ## Check the class of varNameAttr
      if ( !identical(class(varNameAttr)[1], "character") )
        stop(paste(deparse(substitute(varNameAttr)), "is not a  
character."))

      ## Check that varNameAttr is indeed a name attribute
      if ( !( varNameAttr %in% variableAttrNames(dataSet) ) )
        stop(paste(deparse(substitute(varNameAttr)),
                   " does not figure among the name attribute of  
the variables of",
                   xName,
                   ".",
                   sep = "")
             )

      ## Get the index of the chosen variable
      chosenIndex <- (1:thisNbVar)[varNameAttr == variableAttrNames 
(dataSet)]
      ## Check that the chosen variable is indeed categorical (ie,  
a factor)
      if ( variableNames(dataSet)[chosenIndex] !=  
"categoricalvariable" )
        stop(paste(deparse(substitute(varNameAttr)),
                   "is not a categorical (factor) variable.")
             )

      result <- as.character(xmlSApply(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["variables"]][[chosenIndex]][["levels"]],
                                       xmlValue
                                       )
                             )

      return(result)
    } else {
      cat("\n Data set with no variable.\n \n")
      NULL
    }
  }

  ## Define functin dataFrame
  ## This function returns an R data frame with containing the  
variables
  ## of a data set specified by the first formal argument and whose  
name
  ## is specified by the second formal argument.
  ## By default every variable in the data sata set of the GGobi  
XML file is returned.
  ## The third boolean variable, label, if set to TRUE and if the  
record(s) of the
  ## considered data set have a label attribute will generate a  
naming of the rows
  ## of the returned data frame according to the label(s) values
  dataFrame <- function(dataSet = 1, selectedVariables = NULL,  
label = TRUE) {

    if (!identical(class(dataSet)[1], "character") &&
        !identical(class(dataSet)[1], "integer") &&
        !identical(class(dataSet)[1], "numeric")
        )
      stop("Formal argument should be an integer a numeric or a  
character.")

    if (!identical(class(dataSet)[1], "character")) dataSet <-  
dataSetNames()[dataSet]

    thisNbVar <- nbVariables(dataSet)
    if (thisNbVar > 0) {
      ## Put all variable values into a matrix with as many columns  
as variables
      ## This is done in 2 stages:
      ## First we get the variable values as a vector of  
characters, each element contains the values of a single case,
      ## that is, a row of the final matrix
      myValues <- xmlSApply(x$doc$children[["ggobidata"]] 
[[setName2Index(dataSet)]][["records"]],
                            xmlValue
                            )
      ## Second the rows which are for now single character strings  
are "chopped" and converted into numeric
      ## We must here watch out the number of variables
      ## We must also watch out for the number of blanks between  
values
      if (thisNbVar > 1) {
        myValues <- t(sapply(seq(along = myValues),
                             function(i) as.numeric(strsplit 
(myValues[i]," ")[[1]])[!is.na(as.numeric(strsplit(myValues[i]," ") 
[[1]]))]
                             )
                      )
      } else {
        myValues <- sapply(seq(along = myValues),
                           function(i) as.numeric(strsplit(myValues 
[i]," ")[[1]])[!is.na(as.numeric(strsplit(myValues[i]," ")[[1]]))]
                           )

        dim(myValues) <- c(length(myValues),1)
      }

      ## Column names are set to the corresponding variable names
      colnames(myValues) <- variableAttrNames(dataSet)

      ## If label is set to TRUE and if the records of the data set  
have a label attribute
      ## we set the row names to the values of the labels
      if ( label && ("label" %in% recordAttributes(dataSet)) ) {
        theSize <- dim(myValues)[1]
        theLabels <- sapply(1:theSize,
                            function(i) as.character(xmlAttrs(x$doc 
$children[["ggobidata"]][[setName2Index(dataSet)]][["records"]] 
[[i]])["label"])
                            )
        rownames(myValues) <- theLabels
      } ## End of conditional on label && ("label" %in%  
recordAttributes(dataSet))

      ## Check if formal argument variableNames is NULL
      ## If yes all variables will be included in the data frame
      ## Otherwise a check is made of the names passed and the  
corresponding
      ## variables are included in the returned frame.
      if (is.null(selectedVariables))
        selectedVariables <- variableAttrNames(dataSet)

      ## Make sure that the selected variables are indeed variables  
of the original
      ## GGobi XML file.
      selectedVariables <- selectedVariables[selectedVariables %in%  
variableAttrNames(dataSet)]

      if (length(selectedVariables) == 0)
        stop("None of the variables names attribute correspond to  
your selected variable.")

      selectedIndexes <- (1:thisNbVar)[variableAttrNames(dataSet) % 
in% selectedVariables]
      myValues <- myValues[,selectedIndexes, drop = FALSE]
      result <- data.frame(myValues)
      ## remove myValues from memory
      rm(myValues)

      ## Check if some selected variables are factors and if yes  
convert them accordingly
      ## in the returned data frame
      factorIndexes <- selectedIndexes[variableNames(dataSet) 
[selectedIndexes] == "categoricalvariable"]
      if (length(factorIndexes) > 0) {
        ## There are factors among the selected variables
        for (runner in factorIndexes) {
          theVariable <- variableAttrNames(dataSet)[runner]
          result[, theVariable] <- factor(result[, theVariable],
                                          labels = levelsCatVar 
(dataSet, theVariable)
                                          )
        } ## End of for loop on runner
      } ## End of conditional on length(factorIndexes) > 0

      return(result)
    } else {
      cat("\n Data set with no variable.\n \n")
      NULL
    }

  }

  return(list(XMLDocument = XMLDocument,
              nbDataSets = nbDataSets,
              dataSetNames = dataSetNames,
              dataSetDescription = dataSetDescription,
              nbVariables = nbVariables,
              variableNames = variableNames,
              variableAttrNames = variableAttrNames,
              recordAttributes = recordAttributes,
              rangeRealVar = rangeRealVar,
              nlevelsCatVar = nlevelsCatVar,
              levelsCatVar = levelsCatVar,
              dataFrame = dataFrame
              )
         )

}


## Function likeGGobi
## Displays a scatterplot looking like the one obtained
## by pausing a GGobi 2D tour.
## Formal arguments:
##  x: A data frame or a matrix
##  grouping: A factor specifying the class for each observation.
##            Coerced to factor if necessary. Default Null.
##  projectionMatrix: A matrix projection matrix (given by the axes  
or the "GGobi circle")
##                    Should have as many rows as there are  
variables in x and
##                    2 or 3 columns containing the numbers given  
by the "2D tour proj vals".
##                    If the first 2 values only are given the  
third one will be computed from
##                    the data like GGobi does it. If rows are  
missing the matrix is extended with
##                    zeros. If NULL (default) the "projection" on  
the first 2 variables is displayed.
##                    Checks are made for (closeness to)  
orthonormality.
##  selection: The levels of grouping to display. By default all  
levels are shown. Defualt NULL.
##  colPch: A list whose 2 components have as many elements as  
levels in grouping and 2 columns. Each element
##          corresponds to a level, the first component gives the  
color, the second the glyph.
##  showLegend: A logical. Should a legend be displayed? Default  
FALSE.
##  xLegend: A numeric the x position of the legend box.
##  yLegend: A numeric the y position of the legend box.
##  ncolLegend: A numeric, the number of columns in the legend box.
##  verbose: A logical. Controls output to R command window.  
Default FALSE. If true, the actual position
##           of the legend box will be printed. If axes are shown  
in the GGobi fashion, the postion of the
##           center will also be printed. Useful to adjust the  
positions of these 2 elements.
##  showAxes: A logical. Default FALSE. Should axes be displayed?
##  axesPAra: a named list whose components are: axesRadius, axesX,  
axesY, axesL. axesRadius controls the
##            radius of the circle in units of the side of the plot  
(default 0.125), axesX and axesY control
##            the position of the center of the circle with respect  
to the bottom left corner. Same units as
##            axesRadius. axesL is a cutoff to print axes names on  
the plot. Only axes whose (unitary vectors)
##            projections are larger than axesL are printed.
likeGGobi <- function(x,
                      grouping = NULL,
                      projectionMatrix = NULL,
                      selection = NULL,
                      colPch = NULL,
                      showLegend = FALSE,
                      xLegend = NULL,
                      yLegend = NULL,
                      ncolLegend = 2,
                      verbose = FALSE,
                      showAxes = FALSE,
                      axesPara = NULL,
                      ...) {

  ## check that x is a matrix or a data.frame object
  if ( !(identical(class(x)[1], "matrix") || identical(class(x)[1],  
"data.frame")) )
    stop(paste(deparse(substitute(x)), "is neither a matrix nor a  
data frame object."))

  ## if a grouping is specified make sure it makes sense
  if (!is.null(grouping)) {
    ## check that grouping is a factor
    if ( !identical(class(grouping)[1], "factor") ) {
      warning(paste(deparse(substitute(grouping)), "is not a factor  
object.\n Converting it to factor.\n"))
      grouping <- as.factor(grouping)
    } ## End of conditional on !identical(class(grouping)[1],  
"factor")

    ## check that the number of events in x is identical to the  
length of grouping
    if ( !identical(dim(x)[1], length(grouping)) )
      stop(paste(deparse(substitute(x)),
                 "and",
                 deparse(substitute(grouping)),
                 "do not have the same number of events."
                 )
           )
  } else {
    ## if no grouping is specified make a uniform one
    grouping <- factor(1 + numeric(dim(x)[1]), levels = 1, labels =  
"1")
  } ## End of conditional on !is.null(grouping)

  if (is.null(selection)) selection <- levels(grouping)

  if (!is.null(projectionMatrix)) {
    ## check that projectionMatrix is a matrix
    if ( !identical(class(projectionMatrix)[1], "matrix") )
      stop(paste(deparse(substitute(projectionMatrix)), "is not a  
matrix object."))

    ## check that projection matrix is reasonably close to an
    ## orthonormal matrix
    if (any(abs(1-apply(projectionMatrix[,1:2]^2,2,sum)) > 0.001))
      stop(paste("The norms of the vectors making the columns of ",
                 deparse(substitute(projectionMatrix)),
                 " are: ",
                 paste(apply(projectionMatrix[,1:2]^2,2,sum),  
collpase = ","),
                 ", that to far away from 1.",
                 sep = ""
                 )
           )

    if (projectionMatrix[,1] %*% projectionMatrix[,2] > 0.001)
      stop(paste("The dot product of the vectors making the columns  
of ",
                 deparse(substitute(projectionMatrix)),
                 " is: ",
                 projectionMatrix[,1] %*% projectionMatrix[,2],
                 ", that to far away from 0.",
                 sep = ""
                 )
           )

    ## check that the number of variables is consistent
    ## if not mae it so
    if ( !identical(dim(x)[2], dim(projectionMatrix)[1]) ) {
      warning(paste(deparse(substitute(x)),
                    "and",
                    deparse(substitute(projectionMatrix)),
                    "have inconsistent column and row numbers.\n",
                    "Consistency will be imposed.\n \n"
                    )
              )

      if (dim(projectionMatrix)[1] > dim(x)[2]) projectionMatrix <-  
projectionMatrix[1:dim(x)[2],]
      if (dim(projectionMatrix)[1] < dim(x)[2]) {
        theDiff <- dim(x)[2] - dim(projectionMatrix)[1]
        if (dim(projectionMatrix)[2] == 2) projectionMatrix <- rbind 
(projectionMatrix,matrix(0, ncol = 2, nrow = theDiff))
        if (dim(projectionMatrix)[2] == 3) projectionMatrix <- rbind 
(projectionMatrix,
                                   matrix(c(0,0,1), ncol = 3, nrow  
= theDiff, byrow = TRUE)
                                   )
      } ## End of conditional on dim(projectionMatrix)[1] < dim(x)[2]
    } ## End of conditional on !identical(dim(x)[2], dim 
(projectionMatrix)[1])

    ## if projectionMatrix has 3 columns use the third column
    ## to normalize the others
    if ( dim(projectionMatrix)[2] == 3 ) {
      x <- x %*% (projectionMatrix[,1:2] / cbind(projectionMatrix[, 
3],projectionMatrix[,3]))
      projectionMatrix <- projectionMatrix[,1:2]
    } else {
      scalingFactor <- apply(x[grouping %in% selection, ], 2,  
function(i) diff(range(i)))
      x <- as.matrix(x  / (rep(1, dim(x)[1]) %o% scalingFactor)) %* 
% projectionMatrix
    }
  } else {
    ## no projection matrix was given the first 2 variables will be  
used
    projectionMatrix <- matrix(0, ncol = 2, nrow = dim(x)[2])
    projectionMatrix[1,1] <- 1
    projectionMatrix[2,2] <- 1
    x <- x[,1:2]
  } ## End of conditional on !is.null(projectionMatrix)

  if (is.null(colPch)) {
    colPch <- list(rep(palette(), length.out = nlevels(grouping)),
                   rep(1:25, each = length(palette()))[1:nlevels 
(grouping)]
                   )
  }

  if (length(unique(colPch[[1]])) == 1) {
    presentPalette <- palette()
    palette(c(unique(colPch[[1]]),presentPalette[!(presentPalette % 
in% unique(colPch[[1]]))]))
  } else {
    palette(unique(colPch[[1]]))
  }
  Grouping <- as.numeric(grouping) - min(as.numeric(grouping)) + 1
  colVector <- as.vector(sapply(Grouping, function(i) colPch[[1]][i]))
  pchVector <- as.vector(sapply(Grouping, function(i) colPch[[2]][i]))

  plot(x[grouping %in% selection,1], x[grouping %in% selection,2],
       type = "n",
       xlab = "", ylab = "",
       axes = FALSE,
       ...)

  points(x[grouping %in% selection,1],
         x[grouping %in% selection,2],
         col = colVector[grouping %in% selection],
         pch = pchVector[grouping %in% selection])

  if (is.null(xLegend)) xLegend <- max(x[grouping %in% selection, 
1]) - 0.3
  if (is.null(yLegend)) yLegend <- max(x[grouping %in% selection,2])

  if (showLegend)
    legend(x = xLegend,
           y = yLegend,
           legend = levels(grouping),
           col = colPch[[1]],
           pch = colPch[[2]],
           horiz = FALSE,
           ncol = ncolLegend
           )

  if (verbose)
    cat(paste("The legend coordinates are: \n  ",
              "X = ", xLegend, ", ",
              "Y = ", yLegend,
              "\n", sep = "")
        )

  if (showAxes) {

    if (is.null(axesPara))
      axesPara <- list(axesRadius = 0.125,
                       axesX = 0.125,
                       axesY = 0.125,
                       axesL = 0.1)

    axesRadius <- axesPara$axesRadius * diff(range(x[grouping %in%  
selection,1]))
    axesX <- axesPara$axesX + min(x[grouping %in% selection,1])
    axesY <- axesPara$axesY + min(x[grouping %in% selection,2])
    axesL <- axesPara$axesL

    theta <- seq(from = 0, to = 2*pi, by = pi/500)
    xCircle <- cos(theta) * axesRadius + axesX
    yCircle <- sin(theta) * axesRadius + axesY
    lines(xCircle, yCircle)

    projLength <- sqrt(apply(projectionMatrix^2,1,sum))
    projLengthM <- max(projLength)
    inProj <- projLength > axesL
    x0 <- rep(axesX, dim(projectionMatrix)[1])
    x1 <- x0 + projectionMatrix[,1] * axesRadius * 0.91 / projLengthM
    x1b <- x0 + projectionMatrix[,1] * axesRadius * 1.1 / ifelse 
(inProj[],projLength[],1)
    y0 <- rep(axesY, dim(projectionMatrix)[1])
    y1 <- y0 + projectionMatrix[,2] * axesRadius * 0.91 / projLengthM
    y1b <- y0 + projectionMatrix[,2] * axesRadius * 1.1 / ifelse 
(inProj[],projLength[],1)
    segments(x0, y0, x1, y1, lwd = 2)

    if (is.null(rownames(projectionMatrix))) theLabels <- paste 
(1:dim(projectionMatrix)[1])
    else theLabels <- substr(rownames(projectionMatrix),1,2)

    sapply((1:dim(projectionMatrix)[1])[inProj],
           function(i) text(x1b[i],
                            y1b[i],
                            labels = theLabels[i])
           )

    if (verbose)
      cat(paste("\nThe axes coordinates ranges are: \n  ",
                paste(range(x[grouping %in% selection,]), collapse  
= ", "),
                "\n", sep = "")
        )
  } ## End of conditional on showAxes

  palette("default")

}


## Function writeGGobiXML
## adapted from f.writeXML of file writeXML.R of Di Cook
## http://www.public.iastate.edu/~dicook/ggobi-book/ggobi.html
writeGGobiXML <- function(x,
                          filename,
                          data.name = "data",
                          default.color = "0",
                          default.glyph = "plus 1",
                          catvars1 = NULL,
                          x.colors = NULL,
                          x.glyphs = NULL,
                          x.id = NULL,
                          x.description = "An object exported from R",
                          x.name = "data"
                          ) {

  ## check that x is a matrix or a data.frame object
  if ( !(identical(class(x)[1], "matrix") || identical(class(x)[1],  
"data.frame")) )
    stop(paste(deparse(substitute(x)), "is neither a matrix nor a  
data frame object."))

  M <- as.data.frame(x)

  ## Write the header information
  cat(sep="",
      "<?xml version=\"1.0\"?>\n<!DOCTYPE ggobidata SYSTEM  
\"ggobi.dtd\">\n",
      file = filename)
  cat(sep="",
      "<ggobidata count=\"",
      1,
      "\">\n",
      file = filename,
      append = TRUE)
  cat(sep="",
      "<data name=\"",
      x.name,
      "\">\n",
      file = filename,
      append = TRUE)
  cat(sep="",
      "<description>\n",
      file = filename,
      append = TRUE)
  cat(sep="",
      x.description,
      "\n",
      file = filename,
      append = TRUE)
  cat(sep="",
      "</description>\n",
      file = filename,
      append = TRUE)

  p1 <- ncol(M)
  n1 <- nrow(M)
  cat( "The number of variables is: ", p1, ", the sample size is:  
", n1,".\n")

  var.name1<-colnames(M)
  if (is.null(var.name1))
    for (i in 1:p1)
      var.name1<-c(var.name1, paste("Var ",i))

  cat(sep="",
      "<variables count=\"",
      p1,
      "\">\n",
      file = filename,
      append = TRUE)

  for (i in 1:p1) {

    if (is.factor(M[,i])) {
      l1<-length(levels(M[,i]))
      cat(sep="",
          "  <categoricalvariable name=\"",
          var.name1[i],
          "\" >\n",
          file = filename,
          append = TRUE)
      cat("    <levels count=\"",
          l1,
          "\" >\n",
          sep="",
          file = filename,
          append = TRUE)

      for (j in 1:l1) {
        cat("    <level value=\"",
            j,
            "\" >",
            levels(M[,i])[j],
            "</level>\n",
            sep="",
            file = filename,
            append = TRUE)
      } ## End of for loop on j

      cat("    </levels>\n",
          file = filename,
          append = TRUE)
      cat("  </categoricalvariable>\n",
          file = filename,
          append = TRUE)
    } else if (i %in% catvars1) {
      cat(sep="",
          "  <categoricalvariable name=\"",
          var.name1[i],
          "\" levels=\"auto\"/>\n",
          file = filename,
          append = TRUE)
    } else {
      cat(sep="",
          "  <realvariable name=\"",
          var.name1[i],
          "\"/>\n",
          file = filename,
          append = TRUE)
    }
  } ## End of conditional on is.factor(M[,i])

  cat(sep="",
      "</variables>\n",
      file = filename,
      append = TRUE)
  cat(sep="",
      "<records count=\"",
      n1,
      "\" glyph=\"",
      default.glyph,
      "\" color=\"",
      default.color,
      "\" >\n",
      file = filename,
      append = TRUE)

  row.name1 <- rownames(M)

  if (is.null(row.name1))
    row.name1 <- c(1:n1)

  if (is.null(x.id))
    x.id <- c(1:n1)

  if (length(x.colors) != n1) {
    if (!is.null(x.colors))
      cat("Length of data 1 colors vector is not the same as the  
number of rows.\n")
    x.colors <- rep(default.color,n1)
  } ## End of conditional on length(x.colors) != n1
  if (length(x.glyphs) != n1) {
    if (!is.null(x.glyphs))
      cat("Length of data 1 glyphs vector is not the same as the  
number of rows.\n")
    x.glyphs <- rep(default.glyph,n1)
  } ## End of conditional on length(x.glyphs) != n1

  for(i in 1:n1) {

    cat(sep="",
        "<record id=\"",
        x.id[i],
        "\" label=\"",
        row.name1[i],
        "\" ",
        file = filename,
        append = TRUE)

    cat(sep="",
        "color=\"",
        x.colors[i],
        "\" ",
        file = filename,
        append = TRUE)

    cat(sep="",
        "glyph=\"",
        x.glyphs[i],
        "\"",
        file = filename,
        append = TRUE)

    cat(sep="",
        ">\n",
        file = filename,
        append = TRUE)

    for (j in 1:p1)
      cat(M[i,j],
          " ",
          file = filename,
          append = TRUE)

    cat(sep="",
        "\n</record>\n",
        file = filename,
        append = TRUE)

  } ## End of for loop on i

  cat(sep="",
      "</records>\n</data>\n",
      file = filename,
      append = TRUE)

  ## wrap-up file
  cat(sep="",
      "</ggobidata>",
      file = filename,
      append = TRUE)

}
