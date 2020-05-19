## Plot of Language Proficiency

#Prepare Data
library("tidyverse")
library("png")

source(file.path("R/Preprocessing/psychometrics.R"))

SpT <- vpdata %>% 
  filter(SpT_Score != 0) %>%
  select(group,id,SpT_Score)
  
SpT <- SpT %>%   
  pivot_wider(names_from = group, values_from = SpT_Score)
                       
SpT_means <- vpdata %>% 
  filter(SpT_Score != 0) %>% 
  group_by(group) %>% 
  summarise(meanSpT = mean(SpT_Score))

## Plotting

filename <- file.path("figures/languageProficiency.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")

# Basic Settings
par(family = "sans") ## sans serif default - alternative "serif"
par(font=1)  ## 1 = normal style (default), 2=bold, 3=italic
par(mar=c(5,5,5,5), oma=c(1,1,1,1))
par(xpd=NA) ## allows to draw points, lines etc. and legenfs outside of the plot area


## Start Plot
plot(NULL,axes=F,xlab="",ylab="", main = "Language Proficiency", ylim=c(35,40),xlim=c(0,6))


## Add Datapoints
jit <- 2
ce <- 1.8

#lines(jitter(rep(1,nrow(SpT)),jit), jitter(SpT$TraBa,.2), type="p", cex=ce, pch=21, bg="grey",col="black", lwd=2)

lines(jitter(rep(2,nrow(SpT)),jit), jitter(SpT$TraMa,.2), type="p", cex=ce, pch=21, bg="grey",col="black", lwd=2)

lines(jitter(rep(3,nrow(SpT)),jit), jitter(SpT$TraPro,.2), type="p", cex=ce, pch=21, bg="grey",col="black", lwd=2)

lines(jitter(rep(4,nrow(SpT)),jit), jitter(SpT$MulBa,.2), type="p", cex=ce, pch=21, bg="grey",col="black", lwd=2)

lines(jitter(rep(5,nrow(SpT)),jit), jitter(SpT$MulMa,.2), type="p", cex=ce, pch=21, bg="grey",col="black", lwd=2)

lines(jitter(rep(6,nrow(SpT)),jit), jitter(SpT$MulPro,.2), type="p", cex=ce, pch=21, bg="grey",col="black", lwd=2)

# adding Means
ce <- 1.5

#lines(1, mean(SpT$TraBa,na.rm = TRUE), type="p", cex=ce, pch=22, bg="red",col="black", lwd=2)
lines(2, mean(SpT$TraMa,na.rm = TRUE), type="p", cex=ce, pch=22, bg="red",col="black", lwd=2)
lines(3, mean(SpT$TraPro,na.rm = TRUE), type="p", cex=ce, pch=22, bg="red",col="black", lwd=2)
lines(4, mean(SpT$MulBa,na.rm = TRUE), type="p", cex=ce, pch=22, bg="red",col="black", lwd=2)
lines(5, mean(SpT$MulMa,na.rm = TRUE), type="p", cex=ce, pch=22, bg="red",col="black", lwd=2)
lines(6, mean(SpT$MulPro,na.rm = TRUE), type="p", cex=ce, pch=22, bg="red",col="black", lwd=2)

## Set X axis

#axis(side=1,at=seq(1,2,1), label = c("",""),cex.axis=.7)
#axis(side=1,at=seq(3,4,1), label = c("",""),cex.axis=.7)
#axis(side=1,at=seq(5,6,1), label = c("",""),cex.axis=.7)
#axis(side=1,at=seq(7,8,1), label = c("",""),cex.axis=.7)
#axis(side=1,at=seq(9,10,1), label = c("",""),cex.axis=.7)

mtext(side=1, text=c("TraBa","TraMa","TraPro","MulBa","MulMa","MulPro"), 
      line = 1, at=seq(1,6, by =1), font = 1, cex.axis=1.2)
mtext(side=1,at = 3.5, "Group", line=3, font=1, cex=1.5)


## Set Y axis

axis(side=2,at=seq(35,40,1), labels=seq(35,40,1), font = 1, cex.axis=1.2, las=1)
mtext(side=2,"Score", line=3, font =1, cex=1.5)


## Legend
if(FALSE){
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
}
dev.off()

img <- readPNG(filename)
grid::grid.raster(img)

remove(SpT,SpT_means,ce, filename, jit)
