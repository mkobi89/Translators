## Plot of Control QUestions

#Prepare Data
library("tidyverse")

source(file.path("R/Preprocessing/behavioral_data.R"))

CQRes <- controlQuestions %>% 
  group_by(id, group, condition) %>% 
  summarise(percCQRes = sum(correct)/5) %>% 
  ungroup() %>% 
  group_by(group, condition) %>% 
  summarise(meanCQRes = mean(percCQRes))

## Plotting


filename<-file.path("figures/contQuest.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")

# Basic Settings
par(family = "sans") ## sans serif default - alternative "serif"
par(font=1)  ## 1 = normal style (default), 2=bold, 3=italic
par(mar=c(5,5,5,5), oma=c(1,1,1,1))
par(xpd=NA) ## allows to draw points, lines etc. and legenfs outside of the plot area
colors()


## Start Plot
plot(NULL,axes=F,xlab="",ylab="", main = "Control Questions", ylim=c(0,1),xlim=c(0,10))


## Add Datapoints
lines(seq(1,9, by=2), c(CQRes$meanCQRes[1],CQRes$meanCQRes[3],CQRes$meanCQRes[5],CQRes$meanCQRes[7],CQRes$meanCQRes[9]), type="p", cex=2, pch=21, bg="black",col="black", lwd=2)

lines(seq(2,10, by=2),c(CQRes$meanCQRes[2],CQRes$meanCQRes[4],CQRes$meanCQRes[6],CQRes$meanCQRes[8],CQRes$meanCQRes[10]), type="p", cex=2, pch=22, bg="white",col="black", lwd=2)


## Set X axis

axis(side=1,at=seq(1,2,1), label = c("",""),cex.axis=.7)
axis(side=1,at=seq(3,4,1), label = c("",""),cex.axis=.7)
axis(side=1,at=seq(5,6,1), label = c("",""),cex.axis=.7)
axis(side=1,at=seq(7,8,1), label = c("",""),cex.axis=.7)
axis(side=1,at=seq(9,10,1), label = c("",""),cex.axis=.7)

mtext(side=1, text=c("MulBa","MulMa","MulPro","TraMa","TraPro"), 
      line = 1, at=seq(1.5,9.5, by =2),font = 1, cex.axis=0.7)
mtext(side=1,"Group", line=3, font=1, cex=1.2)


## Set Y axis

axis(side=2,at=seq(0,1,.1), labels=seq(0,1,.1),cex.axis=.7, las=1)
mtext(side=2,"Mean Percentage Correct", line=3, font =1, cex=1.2)


## Legend

legend(x=8,y=1.25, ## coordinates of the legend - can be outside of plot of par(xpd=NA)
       legend=c("ELF","EdE"),
       ## with ncol=2 the labels will be placed side by side
       ncol=1, bty="n",
       title=expression(bold("Condition")),
       ## define symbols, lines and symbol background color
       pch=c(21,22),lty=NA,pt.bg=c("black","white"),
       ## adjust symbol size
       pt.cex=2, lwd=2,
       ## adjust the width of the line segments
#       seg.len = 3,
       ## adjust the width of the text segments
       text.width =.5,
       ## if labels are aligned horizontally then you can adjust the space between segments
       x.intersp = 1,
       ## if labels are aligned vertically (ncol=1) then you can adjust line spacing 
       y.intersp = 1.1
)

dev.off()

img <- readPNG(filename)
grid::grid.raster(img)

remove(filename)
