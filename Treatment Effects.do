**# Treatment Effects

* ATU (ATET with subpopulation if treatmentvariable==0)
// Regression command here
estat teffects, atet subpop(if exercise==0)

*Comparison with ATE and ATET
estat teffects
estat teffects, atet