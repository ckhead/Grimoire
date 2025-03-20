library(plotrix)
library(data.table)
file.cf <-fread("file_cf.csv")
yrng <- 100*range(file.cf$PKC_USA,file.cf$TCW_USA,file.cf$L_USA)
gap.inf <- 0.15
gap.sup <- 3.4
file.cf[,gap.plot(DeriskingShock,100*PKC_USA,type="b",pch=16 ,col="black", gap.axis="y", gap = c(gap.inf, gap.sup), ylim=yrng,
                  ylab="Geoeconomic Losses (%)",xlab="% increase in CHN-->USA trade costs",
                  ytics=c(-0.05,0,0.05,0.1,3.45,3.5,3.55)) ]
file.cf[,gap.plot(DeriskingShock,100*TCW_USA,type="b",pch=16 ,col="red",lwd=2, add=TRUE , gap = c(gap.inf, gap.sup)) ]
file.cf[,gap.plot(DeriskingShock,100*L_USA,type="b",pch=1 ,col="orange",lwd=2, add=TRUE , gap = c(gap.inf, gap.sup)) ]
abline(h=0,lty=2)
legend("topright",legend=c("PKC","TCW", "L"),col=c("black","red","orange"),lwd=2,cex=0.8)