### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 2f2edce8-1872-11ec-32b3-671bc66f8d3b
begin
	import Pkg  # import the Julia package manager
	Pkg.add("JuMP") # install the JuMP package
	Pkg.add("Clp") # install the Ipopt interface
	Pkg.update()
end

# ╔═╡ d64ab580-fbb7-4809-b4e2-5b886f2c558e
using JuMP, Clp # load required packages

# ╔═╡ 7640589c-56d7-497e-9aa4-74241dd6c560
md"""
# Define the model
```math
 \begin{align}
    & \min Z = 77.5 E^{1.55} +35 x_2 + 45 x_3 \\
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
eutrophic_model = Model(Clp.Optimizer);

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
begin
	@variable(eutrophic_model, x1 >= 0) 
	@variable(eutrophic_model, x2 >= 0) 
	@variable(eutrophic_model, x3 >= 0) 
	@variable(eutrophic_model, 100 >= E >= 0) 
end

# ╔═╡ 70223245-40fc-4755-9233-57d65cf0272a
md""" ### Define Objective: 

"""

# ╔═╡ 0bb61701-62e8-410d-ae85-7ad5d44d69a7
# @NLobjective(eutrophic_model, Min, 77.5*E^1.55 + 35*x2 + 45*x3)
@objective(eutrophic_model, Min, 920*E + 35*x2 + 45*x3) 

# ╔═╡ ecb79e7f-d965-42ad-8f52-151eb5859e8c
md"""
## Define constraints

Create a new cell for each needed constraint. Give each constraint a unique name. If you make a mistake entering the constraint, use the `set_normalized_coefficient` and `set_normalized_rhs` functions to correct the coefficients or the constant. You can also remove constraints using `delete` and `unregister` (use both).
"""

# ╔═╡ c8c57471-d791-4297-8e9c-c9b010e03082
begin
	@constraint(eutrophic_model, -40*E + 2*x1 + x2 + 0.7*x3 <= 470)
	@constraint(eutrophic_model, x1 + x2 + x3 == 3500)
end

# ╔═╡ 88671baa-52ab-4e72-b74c-e720457f5b89
md"""
Call your model object to see the specification.
"""

# ╔═╡ 6f96f93a-5b29-4b31-8cf7-159e93d17a5a
latex_formulation(eutrophic_model)

# ╔═╡ 7f265d7d-fd5d-46e1-8668-3beec2bae104
md"""
# Solve the model

Run the optimization command and query the variable values.
"""

# ╔═╡ 5896d26c-36ed-4adc-b015-933fcc75a2ec
optimize!(eutrophic_model)

# ╔═╡ Cell order:
# ╠═2f2edce8-1872-11ec-32b3-671bc66f8d3b
# ╠═d64ab580-fbb7-4809-b4e2-5b886f2c558e
# ╟─7640589c-56d7-497e-9aa4-74241dd6c560
# ╟─51804401-2ff7-4f96-a25a-5f0e59cf4a53
# ╟─fe8e9c04-4322-4ecd-8a97-9e9e75379e00
# ╟─6710634d-208b-4f55-9e47-b4e004514a66
# ╠═1cfcf9bb-cced-4ebd-a885-08c84162740f
# ╟─db8c1aee-fc85-471e-ad33-d07c37d2a013
# ╟─f59a5250-5dc7-4c48-a03c-e19fc524dccb
# ╠═fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
# ╟─70223245-40fc-4755-9233-57d65cf0272a
# ╠═0bb61701-62e8-410d-ae85-7ad5d44d69a7
# ╟─ecb79e7f-d965-42ad-8f52-151eb5859e8c
# ╠═c8c57471-d791-4297-8e9c-c9b010e03082
# ╟─88671baa-52ab-4e72-b74c-e720457f5b89
# ╠═6f96f93a-5b29-4b31-8cf7-159e93d17a5a
# ╟─7f265d7d-fd5d-46e1-8668-3beec2bae104
# ╠═5896d26c-36ed-4adc-b015-933fcc75a2ec
