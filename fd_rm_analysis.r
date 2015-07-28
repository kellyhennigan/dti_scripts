
# cd to data dir
setwd('/Users/Kelly/dti/data/CoMs')

d<-read.table("NCP_R_xcoords",sep=",")
df = data.frame(d)
colnames(df)=c("nacc","caudate","putamen")
df2 = stack(df)
subject = c(1:24)
df2[3]=rep(subject,3)
colnames(df2) = c("xcoords","fg","subject")

with(df2, tapply(xcoords, fg, mean))
