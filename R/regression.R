library(stringr)
library(readr)
library(dplyr)
require(utils)
library(reshape2)
library(caret)
library(rpart)
library(ggplot2)
library(tidyr)
library(scales)
library(lmerTest)
library("Hmisc")
library("PerformanceAnalytics")
library(ggfortify)
library(rstantools)
library(MuMIn)
library(robustlmm)
library(MASS)
library(effects)
library(data.table)

setwd("~/git/LibLoanRegress/data/result/")

# data loading
load_data <- function(){
   vars <- read.csv("result.csv", header = T, sep = ",")
   lib <- read.csv("3_library_info.csv")
   vars$년도 <- as.factor(vars$년도)
   vars$books_per_person <- vars$총_대출권수 / vars$인구수
   vars$density <- vars$인구수 * 1000000 / vars$면적
   vars$libraries_per_area <- vars$도서관.수 * 1000000 / vars$면적
   vars$books_per_library <- vars$총_국내도서권수 / vars$도서관.수 / 1000 # 천권
   vars$above_bachelor <- vars$학사_비율 * 100
   pca <- prcomp(vars[,c("above_bachelor", "소득액", "EQ5D")], center = TRUE,scale. = TRUE)
   summary(pca)
   vars$wellbeing_index <- -pca$x[,1] # 55% variance
   vars$deprevation_index <- pca$x[,1]   
   vars$시도 <- as.factor(vars$시도)
   vars$province <- vars$시도
   vars$인구수 <- vars$인구수 / 1000000 # 십만명 
   vars$대중교통_역_노선_면적 <- vars$대중교통_역_노선_면적 * 1000000
   vars$dprv_groups <-  ntile(vars$books_per_library, 3)   %>% # cutting based on -SD and +SD
      factor(., labels = c("하위 33%", "중간 33%", "상위 33%"))
   vars$lib_groups <- ntile(vars$libraries_per_area, 3)   %>% # cutting based on -SD and +SD
      factor(., labels = c("하위 33%", "중간 33%", "상위 33%"))
   vars
}

confint.rlmerMod <- function(object,parm,level=0.95) {
   beta <- fixef(object)
   if (missing(parm)) parm <- names(beta)
   se <- sqrt(diag(vcov(object)))
   z <- qnorm((1+level)/2)
   ctab <- cbind(beta-z*se,beta+z*se)
   colnames(ctab) <- stats:::format.perc(c((1-level)/2,(1+level)/2),
                                         digits=3)
   return(ctab[parm,])
}

vars <- load_data()
cor(vars[,c("deprevation_index","인구수","AGE","books_per_library","libraries_per_area","대중교통_역_노선_면적")])
cor(vars[vars$년도=="2015",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2016",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2017",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2018",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])

fit <- lmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars)
r.squaredGLMM(fit)
summary(fit)

fit<- lmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + deprevation_index*books_per_library + 년도 + (1|시도)", data=vars)
r.squaredGLMM(fit)
summary(fit)

summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars))
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$books_per_library >= median(vars$books_per_library),]))

hist(vars[vars$books_per_library >= median(vars$books_per_library),]$books_per_person)
hist(vars[vars$books_per_library < median(vars$books_per_library),]$books_per_person)
mean(vars[vars$books_per_library >= median(vars$books_per_library),]$books_per_person)
mean(vars[vars$books_per_library < median(vars$books_per_library),]$books_per_person)


# LMER-based regressions (not used in the paper)
fit<- lmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + deprevation_index*libraries_per_area + 년도 + (1|시도)", data=vars)
r.squaredGLMM(fit)
summary(fit)
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE +  books_per_library +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$libraries_per_area >= median(vars$libraries_per_area),]))
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE +  books_per_library +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$libraries_per_area < median(vars$libraries_per_area),]))


# library(effects)
# effects_deprv <- effects::effect(term= "deprevation_index", mod= fit)
# summary(effects_deprv)
# x_dprv <- as.data.frame(effects_deprv)
# p <- ggplot() + 
#       geom_point(data=vars, aes(deprevation_index, books_per_person, col=province)) + 
#       geom_point(data=x_dprv, aes(x=deprevation_index, y=fit), color="blue") +
#       geom_line(data=x_dprv, aes(x=deprevation_index, y=fit), color="blue") +
#       geom_ribbon(data= x_dprv, aes(x=deprevation_index, ymin=lower, ymax=upper), alpha= 0.3, fill="blue") +
#       labs(x="Deprivation Index (centered & scaled)", y="Books per Person") + theme_bw()
# p



# ROBUST Regressions (used in the paper)
#### Baseline Model 1
vars <- load_data()
fit2<- rlmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars)
summary(fit2)
confint(fit2)
vars$model <- stats::predict(fit2, newdata=vars)
err <- as.data.frame(effects::effect("deprevation_index", mod= fit2, 
                                     xlevels=list(deprevation_index=vars$deprevation_index)))
vars <- cbind(vars, err[,2:5])
ggplot(vars[vars$년도=="2018",], aes(x = deprevation_index, y = books_per_person)) +
   theme_bw() +
   geom_point(size = 2, alpha = .8, aes(color = 시도, shape=시도)) +
   geom_smooth(data=vars, stat="smooth",
               method = "loess", 
               span=1.5, color="black", linetype="dashed",
               aes(x = deprevation_index, y=model, ymin=lower, ymax=upper), size=0.5, 
               alpha=0.3, show.legend = F) +
   labs(x = "박탈지수(SED)",
        y = "평균 대출 책수") +
   theme(legend.key.size=unit(1,"cm"), axis.text.x = element_text(size = 15),
         axis.text.y = element_text(size = 15), legend.text=element_text(size=15),
         legend.title = element_text(size=18), axis.title = element_text(size=18)) + xlim(-4,3) + 
   scale_x_continuous(n.breaks = 7) + scale_y_continuous(n.breaks = 12)


# Interaction between books per library and deprivation
vars <- load_data()
fit2<- rlmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + deprevation_index*books_per_library + 년도 + (1|시도)", 
            data=vars)
summary(fit2)
confint(fit2)

vars$model <- stats::predict(fit2, newdata=vars)
err <- as.data.frame(effects::effect("deprevation_index", mod= fit2, 
                                     xlevels=list(deprevation_index=vars$deprevation_index)))
vars <- cbind(vars, err[,2:5])
cor(vars[,c("deprevation_index","model","fit")])

ggplot(vars[vars$년도=="2018",], aes(x = deprevation_index, y = books_per_person,
                                   color = dprv_groups, shape=dprv_groups)) +
   theme_bw() +
   geom_point(size = 2, alpha = .8) +
   geom_smooth(data=vars, stat="smooth",
               method = "loess", 
               span=1.5,
               aes(x = deprevation_index, y=model, ymin=lower, ymax=upper,
                   fill=dprv_groups, linetype=dprv_groups), size=0.5, 
               alpha=0.3, show.legend = T) +
   # geom_ribbon(data= err, aes(x=deprevation_index, y=fit, ymin=lower, ymax=upper), alpha= 0.3, fill=dprv_groups) +
   labs(x = "박탈지수(SED)",
        y = "평균 대출 책수",
        color = "도서관 소장도서 수",
        shape = "도서관 소장도서 수",
        linetype = "도서관 소장도서 수",
        fill = "도서관 소장도서 수") +
   theme(legend.key.size=unit(1,"cm"), axis.text.x = element_text(size = 15),
         axis.text.y = element_text(size = 15), legend.text=element_text(size=15),
         legend.title = element_text(size=18), axis.title = element_text(size=18)) + xlim(-4,3) + 
   scale_x_continuous(n.breaks = 7) + scale_y_continuous(n.breaks = 12)
   
# Upper 33%
fit2<- rlmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + deprevation_index*books_per_library + 년도 + (1|시도)", 
             data=vars[vars$dprv_groups=="상위 33%",])
summary(fit2)
confint(fit2)

fit2<- rlmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + deprevation_index*libraries_per_area + 년도 + (1|시도)", 
             data=vars[vars$lib_groups=="상위 33%",])
summary(fit2)
confint(fit2)

# library(visreg)
# visreg(fit2, "deprevation_index", by="dprv_groups", overlay=T, vars)

# coefs <- data.frame(coef(summary(fit1)))
# coefs.robust <- coef(summary(fit2))
# p.values <- 2*pt(abs(coefs.robust[,3]), coefs$df, lower=FALSE)
# p.values

### Interaction between Deprivation and libraries per area
vars <- load_data()
fit2<- rlmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + deprevation_index*libraries_per_area + 년도 + (1|시도)", 
             data=vars)
summary(fit2)
confint(fit2)
vars$model <- stats::predict(fit2, newdata=vars)
err <- as.data.frame(effects::effect("deprevation_index", mod= fit2, 
                                     xlevels=list(deprevation_index=vars$deprevation_index)))
vars <- cbind(vars, err[,2:5])
ggplot(vars[vars$년도=="2018",], aes(x = deprevation_index, y = books_per_person,
                                   color = lib_groups, shape=lib_groups)) +
   theme_bw() +
   geom_point(size = 2, alpha = .8) +
   geom_smooth(data=vars, stat="smooth",
               method = "loess", 
               span=1.5,
               aes(x = deprevation_index, y=model, ymin=lower, ymax=upper,
                   fill=lib_groups, linetype=lib_groups), size=0.5, 
               alpha=0.3, show.legend = T) +
   labs(x = "박탈지수(SED)",
        y = "평균 대출 책수",
        color = "단위면적 당 도서관 수",
        shape = "단위면적 당 도서관 수",
        linetype = "단위면적 당 도서관 수",
        fill = "단위면적 당 도서관 수") +
   theme(legend.key.size=unit(1,"cm"), axis.text.x = element_text(size = 15),
         axis.text.y = element_text(size = 15), legend.text=element_text(size=15),
         legend.title = element_text(size=18), axis.title = element_text(size=18)) + xlim(-4,3) + 
   scale_x_continuous(n.breaks = 7) + scale_y_continuous(n.breaks = 12)

# fit1<- lmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
#           대중교통_역_노선_면적 + 년도 + (1|시도)", 
#             data=vars)
# fit2<- rlmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
#           대중교통_역_노선_면적 + 년도 + (1|시도)", 
#              data=vars)
# summary(fit2)
# coefs <- data.frame(coef(summary(fit1)))
# coefs.robust <- coef(summary(fit2))
# p.values <- 2*pt(abs(coefs.robust[,3]), coefs$df, lower=FALSE)
# p.values
# 
