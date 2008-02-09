GeomAxis <- proto(Geom, {
  new <- function(., mapping=NULL, data=NULL, stat=NULL, position=NULL, ...){
    do.call("layer", list(mapping=mapping, data=data, stat=stat, geom=., position=position, ..., ignore.extra = TRUE))
  }
  
  draw <- function(., data, scales, coordinates, location = c(0.2, 0.2), size=0.9, colour = "black", ...) {
    axesVp <- axesViewport(data, location)
    axes <- axesGrob(data, gp=gpar(col = colour))
    
    gTree(
      children = gList(axes), 
      childrenvp = axesVp
    )    
  }

  objname <- "axes"
  icon <- function(.) {}
  desc <- "Projection axes"
  
  default_stat <- function(.) StatIdentity
  required_aes <- c()
  default_aes <- function(.) aes()
  
})

geom_axis <- function(...) GeomAxis$new(...)