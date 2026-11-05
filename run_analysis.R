# Run from repository root: Rscript run_analysis.R
# Original analysis extracted from completed student QMD.
# Portfolio additions: seeded display jitter, result exports and consistency checks.
dir.create("results",showWarnings=FALSE)
set.seed(42)
options(width=110)
png("results/diagnostic-%02d.png",width=1400,height=1000,res=150)

reef <- read.csv("data/aims_coral_trout_sites_2012.csv")

reef$latitude_band <- factor(
  reef$latitude_band,
  levels = c("Northern", "Central", "Southern")
)
reef$zone <- factor(
  reef$zone,
  levels = c("Open", "No-take")
)

dim(reef)
names(reef)
str(reef)
summary(reef)


colSums(is.na(reef))


hist(reef$coral_trout,
     breaks = 15,
     xlab = "Coral trout count",
     main = "Distribution of site-level coral trout counts")


library(ggplot2)

ggplot(reef, aes(x = latitude_band, y = coral_trout, fill = zone)) +
  geom_boxplot(outlier.shape = NA,
               position = position_dodge(width = 0.8)) +
  geom_point(aes(group = zone),
             position = position_jitterdodge(jitter.width = 0.12,
                                             dodge.width = 0.8),
             size = 1.5,
             alpha = 0.6) +
  labs(x = "Latitude band",
       y = "Coral trout count",
       fill = "Zone",
       title = "Coral trout counts by latitude band and fishing zone") +
  theme_bw()+
  scale_fill_manual(values = c("Open" = "#D96C5F",
                             "No-take" = "#7183C7"))



with(reef,
     interaction.plot(latitude_band, zone, coral_trout,
                      xlab = "Latitude band",
                      ylab = "Mean coral trout count",
                      trace.label = "Zone"))


group_summary <- aggregate(
  coral_trout ~ latitude_band + zone,
  data = reef,
  FUN = function(x) c(n = length(x),
                      mean = mean(x),
                      median = median(x),
                      variance = var(x))
  )
group_summary <- cbind(group_summary[c("latitude_band", "zone")],
                       as.data.frame(group_summary$coral_trout))

names(group_summary) <- c("Latitude band", "Zone", "n", "Mean", "Median", "Variance")

group_summary <- group_summary[order(group_summary$`Latitude band`, group_summary$Zone),]

knitr::kable(group_summary, digits = 2,
             caption = "Summary of coral trout by latitude band and fishing zone")


poisson_int <- glm(coral_trout ~ latitude_band * zone,
                   family = poisson(link = "log"),
                   data = reef)

summary(poisson_int)


poisson_add <- glm(coral_trout ~ latitude_band + zone,
                   family = poisson(link = "log"),
                   data = reef)

anova(poisson_add, poisson_int, test = "Chisq")
AIC(poisson_add, poisson_int)


(pearson_X2 <- sum(residuals(poisson_int, type = "pearson")^2))
(df_resid <- df.residual(poisson_int))
(phi_hat <- pearson_X2 / df_resid)

(p_gof <- pchisq(deviance(poisson_int), df = df_resid, lower.tail = FALSE))



quasi_add <- glm(coral_trout ~ latitude_band + zone,
                 family = quasipoisson(link = "log"),
                 data = reef)

quasi_int <- glm(coral_trout ~ latitude_band * zone,
                 family = quasipoisson(link = "log"),
                 data = reef)

summary(quasi_int)

anova(quasi_add, quasi_int, test = "F")


final_mod <- quasi_add

plot(fitted(final_mod),
     rstudent(final_mod),
     xlab = "Fitted mean count",
     ylab = "Studentised residual",
     main = "Studentised residuals versus fitted values")

abline(h = 0, lty = 2)
abline(h = c(-2, 2), lty = 3)


lev <- hatvalues(final_mod)

plot(lev, ylab = "Leverage", xlab = "Observation", main = "Leverage")


cd <- cooks.distance(final_mod)

plot(cd, ylab = "Cook's distance", xlab = "Observation", main = "Cook's distance")


diag_table <- data.frame(site = reef$site,
                         fitted = fitted(final_mod),
                         studentised_residual = rstudent(final_mod),
                         leverage = lev,
                         cooks_distance = cd)

diag_table[order(-abs(diag_table$studentised_residual)), ][1:10, ]
diag_table[order(-diag_table$cooks_distance), ][1:10, ]


quasi_add_no22 <- update(quasi_add, data = reef[-22, ])

quasi_add_no_22_24 <- update(quasi_add, data = reef[-c(22, 24), ])

cbind(Full = coef(quasi_add),
      No_AIMS022 = coef(quasi_add_no22),
      No_AIMS022_024 = coef(quasi_add_no_22_24))


summary(quasi_add)
summary(quasi_add_no22)$coefficients
summary(quasi_add_no_22_24)$coefficients


newdat <- expand.grid(latitude_band = levels(reef$latitude_band),
                      zone = levels(reef$zone))

pred <- predict(quasi_add,
                newdata = newdat,
                type = "link",
                se.fit = TRUE)

newdat$fit <- exp(pred$fit)
newdat$lower <- exp(pred$fit - 2 * pred$se.fit)
newdat$upper <- exp(pred$fit + 2 * pred$se.fit)

newdat


b_zone <- coef(quasi_add)["zoneNo-take"]
se_zone <- sqrt(vcov(quasi_add)["zoneNo-take", "zoneNo-take"])

(ci_link <- c(estimate = b_zone,
              lower = b_zone - 2 * se_zone,
              upper = b_zone + 2 * se_zone))

(ci_ratio <- exp(ci_link))


pred_table <- transform(newdat,
                        fit = round(fit, 2),
                        lower= round(lower, 2),
                        upper = round(upper, 2))

knitr::kable(
  pred_table,
  col.names = c("Latitude band", "Zone", "Fitted mean",
                "Lower 95% CI", "Upper 95% CI"),
  caption = "Fitted site-level mean counts and approximate 95% CIs."
)

dev.off()
# Export fitted quantities without changing the model or deleting sites in the primary analysis.
write.csv(group_summary,"results/group-summary.csv",row.names=FALSE)
write.csv(newdat,"results/fitted-counts.csv",row.names=FALSE)
write.csv(diag_table,"results/site-diagnostics.csv",row.names=FALSE)
ct <- summary(quasi_add)$coefficients
write.csv(data.frame(term=rownames(ct),ct,check.names=FALSE),"results/final-coefficients.csv",row.names=FALSE)
sens <- cbind(Full=coef(quasi_add),Without_AIMS022=coef(quasi_add_no22),Without_AIMS022_024=coef(quasi_add_no_22_24))
write.csv(data.frame(term=rownames(sens),sens),"results/sensitivity.csv",row.names=FALSE)
comparison <- anova(quasi_add,quasi_int,test="F")
poisson_comparison <- anova(poisson_add,poisson_int,test="Chisq")
write.csv(data.frame(model=rownames(comparison),comparison,check.names=FALSE),"results/quasi-model-comparison.csv",row.names=FALSE)
ratio <- unname(exp(b_zone));lower <- unname(exp(b_zone-2*se_zone));upper <- unname(exp(b_zone+2*se_zone))
stopifnot(nrow(reef)==120L,!anyNA(reef),length(unique(reef$site))==120L,
 all(reef$coral_trout>=0 & reef$coral_trout==floor(reef$coral_trout)),
 abs(phi_hat-5.3775)<.01,all(is.finite(newdat$fit)),all(newdat$fit>0),
 max(abs(fitted(poisson_int)-fitted(quasi_int)))<1e-7,
 abs(coef(quasi_add)['zoneNo-take']-.5652323)<1e-6,
 all(exp(sens['zoneNo-take',])>1),
 all(reef$site[c(22,24)]==c('AIMS022','AIMS024')))
writeLines(c(paste("R version:",getRversion()),
 paste("ggplot2:",packageVersion("ggplot2")),paste("knitr:",packageVersion("knitr")),
 paste("Sites:",nrow(reef)),paste("Poisson interaction dispersion:",phi_hat),
 paste("Quasi interaction F-test p:",comparison[2,'Pr(>F)']),
 paste("No-take/Open expected-count ratio:",ratio),
 paste("Approximate 95% CI (plus/minus 2 SE):",lower,upper),
 "Input completeness/count integrity: PASS",
 "Poisson and quasi interaction fitted means agree: PASS",
 "Published zone coefficient reproduced: PASS",
 "Sensitivity direction preserved: PASS"),"results/validation.txt")
writeLines(capture.output(sessionInfo()),"results/session-info.txt")
cat("\nPORTFOLIO SUMMARY\nDispersion:",phi_hat,"\nQuasi interaction p:",comparison[2,'Pr(>F)'],
 "\nNo-take/Open ratio:",ratio,"CI:",lower,upper,"\n")

# Portfolio result figure: uncertainty for expected site counts (not individual-site prediction intervals).
png("results/fitted-counts.png",width=1500,height=1000,res=160)
plot_dat <- newdat
plot_dat$x <- as.numeric(plot_dat$latitude_band) + ifelse(plot_dat$zone=="Open",-.12,.12)
cols <- ifelse(plot_dat$zone=="Open","#B84C3D","#5268AC")
par(mar=c(5,5,4,2))
plot(plot_dat$x,plot_dat$fit,pch=19,col=cols,cex=1.3,
 xlim=c(.6,3.4),ylim=c(0,21),xaxt="n",xlab="Latitude band",ylab="Expected coral trout count per site",
 main="Fitted mean counts with approximate 95% confidence intervals")
axis(1,at=1:3,labels=levels(reef$latitude_band))
arrows(plot_dat$x,plot_dat$lower,plot_dat$x,plot_dat$upper,angle=90,code=3,length=.055,col=cols,lwd=2)
legend("topleft",legend=c("Open","No-take"),col=c("#B84C3D","#5268AC"),pch=19,bty="n")
mtext("Additive quasi-Poisson model; 2012 teaching extract; intervals use +/- 2 SE on the log scale",side=3,line=.2,cex=.8)
dev.off()
