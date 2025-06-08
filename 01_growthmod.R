# prelims ----
pdf(file = NULL) # silent suppression of plotting...
source("00_data_prep.R")
dev.off()

library(cmdstanr)

s <- list(N = nrow(xdata),
          voc_size = xdata$voc_size,
          age = xdata$agem,
          prior_only = 1 # 1 = prior sim; 0 = use empiricial data
          )

m <- cmdstanr::cmdstan_model("stanmodel.stan")
m$check_syntax(pedantic = TRUE)

# prior model ----
r <- m$sample(s, parallel_chains = 4, show_exceptions = FALSE, seed = 98617)
keypars <- c("steepness_raw", "inflection_raw", "upperlim_raw")
post <- r$draws(keypars)
bayesplot::mcmc_trace(post, "steepness_raw")
bayesplot::mcmc_trace(post, "inflection_raw")
bayesplot::mcmc_trace(post, "upperlim_raw")
r$summary(keypars)

post <- r$draws("y_rep", format = "draws_matrix")
plot(0, 0, type = "n", lwd = 2,
     xlab = "age (- 12 months)", ylab = "vocabulary size",
     xlim = c(0, 13), yaxs = "i", ylim = c(0, 1000), las = 1)
for (i in 1:20) {
  points(xdata$agem, post[sample(nrow(post), 1), ], type = "l", col = "#87CEEBFF")
}


# model proper ----
s$prior_only <- 0
r <- m$sample(s, parallel_chains = 4, show_exceptions = FALSE, refresh = 0, seed = 98617)
post <- r$draws(keypars)
bayesplot::mcmc_trace(post, "steepness_raw")
bayesplot::mcmc_trace(post, "inflection_raw")
bayesplot::mcmc_trace(post, "upperlim_raw")
r$summary(keypars)

post <- r$draws("y_rep", format = "draws_matrix")

bayesplot::ppc_dens_overlay(xdata$voc_size, post[sample(nrow(post), 20), ])


plot(xdata$agem, xdata$voc_size, type = "n", lwd = 2,
     xlab = "age (- 12 months)", ylab = "vocabulary size",
     yaxs = "i", ylim = c(0, 500), las = 1)
for (i in 1:50) {
  points(xdata$agem, post[sample(nrow(post), 1), ], type = "l", col = "#87CEEBFF")
}
points(xdata$agem, xdata$voc_size, type = "l", lwd = 2)
legend("topleft", pch = 15, col = c('black', "#87CEEBFF"),
       legend = c("observed", "post. predictions"), bty = "n")

