# Draw dd plot
# Draw a complete describe display.
# 
# If you want to layout multiple dd plots on the same page, you can
# use \code{\link[grid]{grid.layout}}.  If you need even more control,
# set \code{draw = FALSE} and then \code{\link[grid]{grid.draw}} the 
# resulting grob yourself.
# 
# This function reads a number of options directly out of the 
# descripedisplay datastructure.  See the examples for ways to use
# these.
# 
# @arguments dd object to plot
# @arguments (unused)
# @arguments draw plot, or just return grob
# @arguments location of axes (as x and y position in npc coordinates, ie. between 0 and 1)
# @arguments size of plot as a proportion of the total display area (set to 1 for printed out)
# @value frame grob containing all panels, note that this does not contain the title or border
#X plot(dd_example("dot"))
#X plot(dd_example("xyplot"))
#X plot(dd_example("edges"))
#X plot(dd_example("tour1d"))
#X plot(dd_example("tour2d"))
#X
#X ash <- dd_example("ash")
#X plot(ash)
#X ash$plots[[1]]$drawlines <- TRUE
#X plot(ash)
#X ash$plots[[1]]$showPoints <- FALSE
#X plot(ash)
#X
#X texture <- dd_example("1d-texture")
#X plot(texture)
#X texture$plots[[1]]$yscale <- expand_range(texture$plots[[1]]$yscale, 0.5)
#X plot(texture)
# @keyword internal 
plot.dd <- function(x, ..., draw = TRUE, axislocation = c(0.1, 0.1), size=0.9, axisgp=gpar(col="black"), background.color="grey90") {
  d <- x$dim
  layout <- grid.layout(nrow = d[1], ncol = d[2])
  panels <- frameGrob(layout = layout)
  
  for(i in 1:x$nplot) {
    panels <- placeGrob(panels, 
      ddpanelGrob(x$plots[[i]], axislocation=axislocation, axis.gp=axisgp, background.color=background.color), 
      col = (i - 1) %/% d[1] + 1, row = (i - 1) %% d[1] + 1
    )
  }

  if (!is.null(x$title) && nchar(x$title) != 0) {
    pg <- frameGrob(grid.layout(nrow=2, ncol=1))
    pg <- packGrob(pg, textGrob(x$title, gp=gpar(cex=1.3)), row=1, height=unit(2,"lines"))
    pg <- packGrob(pg, panels, row=2)
  } else {
    pg <- panels
  }

  if (draw) {
    grid.newpage()
    pushViewport(viewport(w = size, h = size))
    grid.draw(pg)
  }
  
  invisible(panels)
}

# Plot a dd plot
# Convenient method to draw a single panel.
# 
# This is mainly used for bug testing so that you can pull out a single 
# panel quickly and easily.
# 
# @arguments object to plot
# @arguments axis location, x and y position
# @keyword hplot
#X scatmat <- dd_example("scattermat")
#X plot(scatmat)
#X plot(scatmat$plots[[1]])
#X plot(scatmat$plots[[3]])
#X plot(scatmat$plots[[4]])
plot.ddplot <- function(x, ..., axislocation = c(0.1, 0.1), axis.gp=gpar(col="black"), background.color = "grey90") {
  grid.newpage()
  grob <- ddpanelGrob(x, axislocation = axislocation, axis.gp = axis.gp,
    background.color = background.color)
  grid.draw(grob)  
}


# Panel grob
# Construct grob for single panel.
# 
# @arguments describe display object
# @arguments plot 
# @arguments axis location, x and y position
# @keyword internal 
ddpanelGrob <- function(panel, axislocation = c(0.1, 0.1), axis.gp = gpar(col="black"), background.color="grey90") {
  points <- panel$points
  edges <- panel$edges
  
  axes <- dd_tour_axes(panel)
  axesVp <- axesViewport(axes, axislocation)
  grobs <- list(
    rectGrob(gp=gpar(col="grey", fill=background.color))
  )

  if (!is.null(edges))  
    grobs <- append(grobs, list(segmentsGrob(edges$src.x, edges$src.y, edges$dest.x, edges$dest.y, default.units="native", gp=gpar(lwd=edges$lwd, col=as.character(edges$col)))))
  
  if (is.null(panel$showPoints) || panel$showPoints) {
    grobs <- append(grobs, list(pointsGrob(points$x, points$y, pch=points$pch, gp=gpar(col=as.character(points$col)), size=unit(points$cex, "char"))))
  }
  
  if (!is.null(panel$labels)) {
    labels <- panel$labels
    grobs <- append(grobs, list(
      textGrob(as.character(labels$label), labels$x, labels$y, default.units="native",hjust=labels$left, vjust=labels$top)
    ))
  }
  
  grobs <- append(grobs,  list(
    textGrob(nulldefault(panel$params$xlab, ""), 0.99, 0.01, just = c("right","bottom")),
    textGrob(nulldefault(panel$params$ylab, ""), 0.01, 0.99, just = c("left", "top")),
    axesGrob(axes, gp=axis.gp)
  ))

  if (length(panel$params$label) == 1)
    grobs <- append(grobs, list(textGrob(nulldefault(panel$params$label, ""), 0.5, 0.01, just = c("centre", "bottom"))))

  if (!is.null(panel$drawlines) && panel$drawlines) {
    grobs <- append(grobs, list(segmentsGrob(points$x, panel$baseline, points$x, points$y, default.units="native",  gp=gpar(col=as.character(points$col)))))
  }

  
  gTree(
    children = do.call(gList, grobs), 
    vp = dataViewport(
      xscale = panel$xscale,
      yscale = panel$yscale,
      clip = "on"),
    childrenvp = axesVp
  )
}