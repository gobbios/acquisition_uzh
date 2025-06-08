data {
  int N;
  vector[N] age; // months starting at 0
  array[N] int voc_size;
  int prior_only;
}

parameters {
  real steepness_raw;
  real inflection_raw;
  real upperlim_raw;
}

transformed parameters {
  real<lower=0> steepness = exp(steepness_raw);
  real<lower=0> inflection = exp(inflection_raw);
  real<lower=0> upperlim = exp(upperlim_raw);
}

model {
  if (prior_only == 0) {
    vector[N] lambda = upperlim / (1 + exp(-steepness * (age - inflection)));
    voc_size ~ poisson(lambda);
  }
  steepness_raw ~ normal(0, 1);
  inflection_raw ~ normal(1, 2);
  upperlim_raw ~ normal(log(400), 3);
}

generated quantities {
  array[N] int y_rep;
  {
    vector[N] lambda = upperlim / (1 + exp(-steepness * (age - inflection)));
    y_rep = poisson_rng(lambda);
  }
}

