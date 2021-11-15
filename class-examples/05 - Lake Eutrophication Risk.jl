### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 2f2edce8-1872-11ec-32b3-671bc66f8d3b
begin
	import Pkg  # import the Julia package manager
	Pkg.add("JuMP") # install the JuMP package
	Pkg.add("Ipopt") # install the Ipopt interface
	Pkg.add("PlutoUI")
	Pkg.update()
end

# ╔═╡ df80e20b-afaf-44aa-b39f-2bdceabdff62
# install Distributions.jl and also load a plotting function
begin
	Pkg.add("Distributions")
	using Plots, Distributions
end

# ╔═╡ d64ab580-fbb7-4809-b4e2-5b886f2c558e
using JuMP, Ipopt # load required packages

# ╔═╡ 4530eb97-aa41-4253-a1be-c34567fb3b26
begin
	using PlutoUI
	TableOfContents()
end

# ╔═╡ 7640589c-56d7-497e-9aa4-74241dd6c560
md"""
# Define the model
```math
 \begin{align}
    & \min Z = 920E +35 x_2 + 45 x_3 \\
   &\text{subject to} &&\\
    & -  40 E + 2.0 x_1 +1.0 x_2 + 0.70 x_3 & \leq & 470\\
    & x_1 + x_2 + x_3 &=& 3 500 \\
    & E &\leq& 100 \\
    & E, x_1, x_2, x_3 &\geq& 0 
 \end{align}
```
"""

# ╔═╡ 51804401-2ff7-4f96-a25a-5f0e59cf4a53
md"""
# Set up the model in JuMP
"""

# ╔═╡ fe8e9c04-4322-4ecd-8a97-9e9e75379e00
md"""
This is a nonlinear optimization problem, so we will use the Ipopt solver. Note that syntax is slightly different for non-linear functions.

There are three main changes to solve nonlinear programs in JuMP.

- Use `@NLobjective` instead of `@objective` if nonlinear 
- Use `@NLconstraint` instead of `@constraint` if nonlinear 
- Use `@NLexpression` instead of `@expression` if nonlinear 

"""

# ╔═╡ 6710634d-208b-4f55-9e47-b4e004514a66
md"""
## Define the model object

First, we need to give the model a name and specify that we are using `Ipopt.Optimizer` to use the Ipopt solver for non-linear and integer programming. This creates a "container" for the model specification and solution.
"""

# ╔═╡ 1cfcf9bb-cced-4ebd-a885-08c84162740f
# initialize the model object with the Ipopt solver
model = Model(Ipopt.Optimizer)

# ╔═╡ db8c1aee-fc85-471e-ad33-d07c37d2a013
md"""
## Define variables
"""

# ╔═╡ f59a5250-5dc7-4c48-a03c-e19fc524dccb
md"""
Define the decision variables in this section. Include constraints on the variable domains, including non-negativity constraints.

If you make a mistake setting up the constraints, do not change the cell where those variables were defined and rerun it (JuMP will throw an error). Instead, create a new code cell by clicking on the + sign below a cell, then use the `set_lower_bound`, `set_upper_bound`, `delete_lower_bound`, and `delete_upper_bound` functions.

Alternatively, you can just make your edits, close the notebook and restart Pluto.
"""

# ╔═╡ fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
@variable(model, E >= 0)

# ╔═╡ 8b994b49-8364-43af-99da-141068620097
@variable(model, x[1:3] >= 0)

# ╔═╡ 70223245-40fc-4755-9233-57d65cf0272a
md""" ## Define Objective: 

"""

# ╔═╡ 0bb61701-62e8-410d-ae85-7ad5d44d69a7
@NLobjective(model, Min, 77.5E^1.55 + 35x[2] + 45x[3])

# ╔═╡ ecb79e7f-d965-42ad-8f52-151eb5859e8c
md"""
## Define constraints

Create a new cell for each needed constraint. Give each constraint a unique name. If you make a mistake entering the constraint, use the `set_normalized_coefficient` and `set_normalized_rhs` functions to correct the coefficients or the constant. You can also remove constraints using `delete` and `unregister` (use both).
"""

# ╔═╡ 50d03f64-540c-4e15-a484-0b3cb72d0444
@constraint(model, effluent, -40E + 2x[1] +1x[2] + 0.7x[3] <= 470)

# ╔═╡ 88671baa-52ab-4e72-b74c-e720457f5b89
md"""
Call your model object to see the specification.
"""

# ╔═╡ 6f96f93a-5b29-4b31-8cf7-159e93d17a5a
@constraint(model, area, sum(x) == 3500)

# ╔═╡ 5a0eed68-3e7d-496c-9511-ee8534d67f65
@constraint(model, max_eff, E <= 100)

# ╔═╡ 0056220e-362c-447d-8b12-89e0ecbc08a7
md"""
However, we don't just want to solve the original problem, we want to add in some margin of safety in case our assumptions about runoff are wrong. If we want to reduce our output by 10%, the new effluent constraint has a right-hand side of -930 kg (since the reduction is by 10% of the 14,000 kg threshold, or 1,400 kg). We can change the constraint using `set_normalized_rhs()`.
"""

# ╔═╡ ebc01b54-3eb1-499e-9f22-05a7e18f6e97
set_normalized_rhs(effluent, -930)

# ╔═╡ 8043a705-187e-41ed-8f4b-51d882a002e9
md"""
This results in the following optimization model.
"""

# ╔═╡ d4f7a8d4-20b0-4f98-9ab9-5c40c21a2e7f
latex_formulation(model)

# ╔═╡ 7f265d7d-fd5d-46e1-8668-3beec2bae104
md"""
# Solve the model

Run the optimization command and query the variable values.
"""

# ╔═╡ 5896d26c-36ed-4adc-b015-933fcc75a2ec
optimize!(model)

# ╔═╡ 29de0b8b-afb6-42af-a246-04a29caa9cf5
value.(E)

# ╔═╡ af265a38-193b-4e13-a4bf-d3c94aed1051
value.(x)

# ╔═╡ f80a1a06-6832-4985-acab-b52658c521e3
md"""
Notice that this changed constraint reduces the amount of untreated land to 21 ha from the original 1098 ha!
"""

# ╔═╡ efdc39bc-3d87-486e-8ada-bb6c871e0ab8
md"""
# Risk Analysis

Our margin of safety bought us (and the lake) some breathing room, but how often might the lake still be susceptible to eutrophication? To answer this question, we need to make an assumption about our uncertainties.

Let's assume for the sake of this tutorial that we are confident in our sewage and land treatment efficiencies. However, we can't control year-to-year variability in runoff from other sources. We assumed that this was 9,530 kg in our optimization, but while this might be a best estimate, there's almost certainly going to be some uncertainty. Let's say that, based on historical data, we estimate that a normal distribution with mean 9,530 kg and standard deviation 1,000 kg is reasonable.
"""

# ╔═╡ 31ec9abe-40b6-4949-8810-02f3e61fc498
md"""
## Sampling from Distributions
"""

# ╔═╡ 1be1410f-60f2-4537-ab38-a2a041bdc49d
md"""
We need to be able to sample from our chosen distribution to quantify the probability of exceeding the threshold. In Julia, this can be done with the `Distributions` package.

`Distributions` works more like SciPy in Python than statistical sampling in R: We'll create a distribution *object* and then use the `rand` function to sample from it.
"""

# ╔═╡ 6bae4842-da8a-468d-a75a-0b732c4947cc
dist = Normal(9530, 1000)

# ╔═╡ 12d7af63-8fa3-47f2-ac2b-1ac23aff9c94
samples = rand(dist, 100000)

# ╔═╡ da9048c9-f581-4884-a0b2-2f053cd479da
md"""
## Calculating the Exceedance Probability
Now we can compute the probability of exceedance. Since we cut our runoff by 1,400 kg, the threshold will be exceeded when other runoffs exceed 10,930 kg. That means that we want to calculate the probability of being in the red region below.
"""

# ╔═╡ 409fc1d2-6eb2-4a93-8db3-8ce1c2353a9d
begin
	plot(x->pdf(dist, x), xlims=[6000, 13000])
	plot!(x->pdf(dist, x), 10930, 32000, fillrange=0, c=:red4, legend=false)
end

# ╔═╡ 93ae2e73-1ae5-492b-a82e-deba3842d389
md"""
Given a sufficiently large sample size, we can approximate this by computing the frequency of exceeding that threshold. As this is Monte Carlo estimation, the probability will change based on the specific sample, and the error variance will change based on the number of samples.
"""

# ╔═╡ 36bad8d2-ab8a-4def-bfa4-76485ced7964
sum(samples .>= 10930) / length(samples)

# ╔═╡ Cell order:
# ╠═2f2edce8-1872-11ec-32b3-671bc66f8d3b
# ╠═d64ab580-fbb7-4809-b4e2-5b886f2c558e
# ╠═4530eb97-aa41-4253-a1be-c34567fb3b26
# ╟─7640589c-56d7-497e-9aa4-74241dd6c560
# ╟─51804401-2ff7-4f96-a25a-5f0e59cf4a53
# ╟─fe8e9c04-4322-4ecd-8a97-9e9e75379e00
# ╟─6710634d-208b-4f55-9e47-b4e004514a66
# ╠═1cfcf9bb-cced-4ebd-a885-08c84162740f
# ╟─db8c1aee-fc85-471e-ad33-d07c37d2a013
# ╟─f59a5250-5dc7-4c48-a03c-e19fc524dccb
# ╠═fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
# ╠═8b994b49-8364-43af-99da-141068620097
# ╟─70223245-40fc-4755-9233-57d65cf0272a
# ╠═0bb61701-62e8-410d-ae85-7ad5d44d69a7
# ╟─ecb79e7f-d965-42ad-8f52-151eb5859e8c
# ╠═50d03f64-540c-4e15-a484-0b3cb72d0444
# ╟─88671baa-52ab-4e72-b74c-e720457f5b89
# ╠═6f96f93a-5b29-4b31-8cf7-159e93d17a5a
# ╠═5a0eed68-3e7d-496c-9511-ee8534d67f65
# ╠═0056220e-362c-447d-8b12-89e0ecbc08a7
# ╠═ebc01b54-3eb1-499e-9f22-05a7e18f6e97
# ╟─8043a705-187e-41ed-8f4b-51d882a002e9
# ╠═d4f7a8d4-20b0-4f98-9ab9-5c40c21a2e7f
# ╟─7f265d7d-fd5d-46e1-8668-3beec2bae104
# ╠═5896d26c-36ed-4adc-b015-933fcc75a2ec
# ╠═29de0b8b-afb6-42af-a246-04a29caa9cf5
# ╠═af265a38-193b-4e13-a4bf-d3c94aed1051
# ╟─f80a1a06-6832-4985-acab-b52658c521e3
# ╟─efdc39bc-3d87-486e-8ada-bb6c871e0ab8
# ╟─31ec9abe-40b6-4949-8810-02f3e61fc498
# ╟─1be1410f-60f2-4537-ab38-a2a041bdc49d
# ╠═df80e20b-afaf-44aa-b39f-2bdceabdff62
# ╠═6bae4842-da8a-468d-a75a-0b732c4947cc
# ╠═12d7af63-8fa3-47f2-ac2b-1ac23aff9c94
# ╟─da9048c9-f581-4884-a0b2-2f053cd479da
# ╠═409fc1d2-6eb2-4a93-8db3-8ce1c2353a9d
# ╟─93ae2e73-1ae5-492b-a82e-deba3842d389
# ╠═36bad8d2-ab8a-4def-bfa4-76485ced7964
