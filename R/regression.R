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

setwd("~/git/LibLoanRegress/data/result/")

# data loading
vars <- read.csv("result.csv", header = T, sep = ",")
lib <- read.csv("3_library_info.csv")

vars$년도 <- as.factor(vars$년도)
vars$books_per_person <- vars$총_대출권수 / vars$인구수
vars$density <- vars$인구수 * 1000000 / vars$면적
vars$libraries_per_area <- vars$도서관.수 * 1000000 / vars$면적
vars$books_per_library <- vars$총_국내도서권수 / vars$도서관.수
vars$above_bachelor <- vars$학사_비율 * 100

pca <- prcomp(vars[,c("above_bachelor", "소득액", "EQ5D")], center = TRUE,scale. = TRUE)
summary(pca)
vars$wellbeing_index <- -pca$x[,1] # 55% variance
vars$deprevation_index <- pca$x[,1]

cor(vars[,c("deprevation_index","인구수","AGE","books_per_library","libraries_per_area","대중교통_역_노선_면적")])
cor(vars[vars$년도=="2015",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2016",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2017",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2018",c("deprevation_index", "above_bachelor", "소득액", "EQ5D")])

vars$시도 <- as.factor(vars$시도)
vars$province <- vars$시도

fit <- lmer("books_per_person ~ deprevation_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars)
r.squaredGLMM(fit)
summary(fit)
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE +  libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$books_per_library >= median(vars$books_per_library),]))
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE +  libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$books_per_library < median(vars$books_per_library),]))
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE +  books_per_library +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$libraries_per_area >= median(vars$libraries_per_area),]))
summary(lmer("books_per_person ~ deprevation_index + 인구수 + AGE +  books_per_library +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars[vars$libraries_per_area < median(vars$libraries_per_area),]))


library(effects)
effects_deprv <- effects::effect(term= "deprevation_index", mod= fit)
summary(effects_deprv)

x_dprv <- as.data.frame(effects_deprv)
p <- ggplot() + 
      geom_point(data=vars, aes(deprevation_index, books_per_person, col=province)) + 
      geom_point(data=x_dprv, aes(x=deprevation_index, y=fit), color="blue") +
      geom_line(data=x_dprv, aes(x=deprevation_index, y=fit), color="blue") +
      geom_ribbon(data= x_dprv, aes(x=deprevation_index, ymin=lower, ymax=upper), alpha= 0.3, fill="blue") +
      labs(x="Deprivation Index (centered & scaled)", y="Books per Person") + theme_bw()


p
