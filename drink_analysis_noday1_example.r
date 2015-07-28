

##########################
# Drink Study Analysis
# Kelly Hennigan
##########################
#
#
library(lme4)
library(nlme)
library(ggplot2)

##
setwd(dir = "/Users/Kelly/Dropbox/DNLab/exp_docs/DATA/")
longdata = read.csv(file = "soy_ratingslong_no2ratesubs_nod1.csv", header = TRUE) # 5 cols: subj drink day likerating wantrating 
#want_data = read.csv(file = "wantlong.csv", header = TRUE)
#like_data = read.csv(file = "likelong.csv", header = TRUE)

longdata$subj = factor(longdata$subj)
longdata$drink = factor(longdata$drink)
longdata$day = factor(longdata$day, labels=c('2','3','4','5','6','7','8','9','10'))
#longdata$Time = scale(longdata$Time, scale=F)	# time centered at 0

# Univariate Approach with aov()
cat('Random effects model with aov()')
rs = aov(likerating ~ day + subj + Error(subj), na.action = na.omit, longdata)


cat('Random effects model with aov() without + subj')
rs1a = aov(likerating ~ day + Error(subj), na.action = na.omit, longdata)

# Univariate Approach with lm()

cat('Random effects model with lme()')
rs2 = lme(likerating ~ day, random = ~ 1 | subj, na.action = na.omit, longdata)

cat('Random effects model with lmer()')
rs3 = lmer(likerating ~ day + (1 | subj), na.action = na.omit, longdata)

# Day Contrasts with lm()
options(contrasts=c("contr.sum","contr.poly"))	# makes effect weights sum to zero
contrasts(longdata$day) = contr.poly

cat('Random effects model with lme()')
rs4 = lme(likerating ~ day, random = ~ 1 | subj, na.action = na.omit, longdata)


cat('Random effects model with lmer()')
rs5 = lmer(likerating ~ day + (1 | subj), na.action = na.omit, longdata)

######### Multivariate Approach #############
# http://gribblelab.org/2009/03/09/repeated-measures-anova-using-r/

# Reorganize data into a matrix w/subj by row and 10 columns for day

shortdata = with(longdata, cbind(likerating[day=="2"], likerating[day=="3"], likerating[day=="4"], likerating[day=="5"], likerating[day=="6"], likerating[day=="7"], likerating[day=="8"], likerating[day=="9"], likerating[day=="10"]))

# Define multivariate linear model
mlm1=lm(shortdata ~ 1)

# Define repeated factor variable time
time = factor(c('d2','d3','d4','d5','d6','d7','d8','d9','dten'))

library(car)	# contains Anova() function (note the capital A in Anova())

rs6 = Anova(mlm1, idata = data.frame(time), idesign = ~time, type = "III")
# type options are either II or III:
# Type-II tests are calculated according to the principle of marginality, testing each term after all others, except ignoring the term’s higher-order 
# relatives; so-called type-III tests violate marginality, testing each term in the model after all of the others.

print(summary(rs))
print(summary(rs1a))
print(summary(rs2))
print(summary(rs3))
print(summary(rs4))
print(summary(rs5))
print(summary(rs6, multivariate = FALSE))

# con_test=contr.poly(time, scores=1:10, contrasts=TRUE, sparse=FALSE)