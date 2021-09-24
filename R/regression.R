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


cor(vars[,c("wellbeing_index","인구수","AGE","books_per_library","libraries_per_area","대중교통_역_노선_면적")])
cor(vars[vars$년도=="2015",c("wellbeing_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2016",c("wellbeing_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2017",c("wellbeing_index", "above_bachelor", "소득액", "EQ5D")])
cor(vars[vars$년도=="2018",c("wellbeing_index", "above_bachelor", "소득액", "EQ5D")])

fit <- lmer("books_per_person ~ wellbeing_index + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars)
r.squaredGLMM(fit)
summary(lmer("books_per_person ~ above_bachelor + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars))
summary(lmer("books_per_person ~ 소득액 + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars))
summary(lmer("books_per_person ~ EQ5D + 인구수 + AGE + books_per_library + libraries_per_area +
          대중교통_역_노선_면적 + 년도 + (1|시도)", data=vars))


fit <- lmer("books_per_person ~ wellbeing_index + 인구수 + AGE + books_per_library + libraries_per_area +
          년도 + (1|시도)", data=vars)
r.squaredGLMM(fit)
summary(fit)
summary(lmer("books_per_person ~ above_bachelor + 인구수 + AGE + books_per_library + libraries_per_area +
          년도 + (1|시도)", data=vars))
summary(lmer("books_per_person ~ 소득액 + 인구수 + AGE + books_per_library + libraries_per_area +
          년도 + (1|시도)", data=vars))
summary(lmer("books_per_person ~ EQ5D + 인구수 + AGE + books_per_library + libraries_per_area +
          년도 + (1|시도)", data=vars))
