### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 2f2edce8-1872-11ec-32b3-671bc66f8d3b
begin
	import Pkg  # import the Julia package manager
	Pkg.add("JuMP") # install the JuMP package
	Pkg.add("Clp") # install the Clp.jl interface
end

# ╔═╡ 6fec4d6d-c108-46d6-a40e-f2dac0e025b7
begin
	Pkg.add("PlutoUI")
	using PlutoUI
	PlutoUI.TableOfContents(title="Contents", indent=true, depth=4)
end

# ╔═╡ c21b40dd-f918-4e21-a5b2-e52e5cbb10a0
using JuMP, Clp

# ╔═╡ 7640589c-56d7-497e-9aa4-74241dd6c560
md"""
# Define the model

A new treatment technology has been developed which makes the cost of CRUD treatment linear, rather than quadratic. The cost of treatment is now
```math
C(E_1, E_2, E_3) = 7500E_1 + 9000E_2 + 7000E_3,
```
where ``E_i`` is the treated fraction of emitted CRUD from factory ``i``.

The constraints are the same, as those were determined by regulation:
```math
\begin{align*}
1000E_1 &\geq 500 \\
835E_1 + 1200E_2 &\geq 1459 \\
637E_1 + 916E_2 + 1600E_3 &\geq 2357 \\
E_1, E_2, E_3 &\leq 0 \\
E_1, E_2, E_3 &\geq 1
\end{align*}
```

The goal of this exercise is to find the values of ``E_1``, ``E_2``, and ``E_3`` which minimize the cost of treatment while putting the factory system in compliance with the CRUD regulations. Feel free to also open the linear programming in JuMP tutorial and the [JuMP documentation](https://jump.dev/JuMP.jl/stable/) to reference syntax.
"""

# ╔═╡ 51804401-2ff7-4f96-a25a-5f0e59cf4a53
md"""
# Set up the model in JuMP
"""

# ╔═╡ 6710634d-208b-4f55-9e47-b4e004514a66
md"""
## Define the model object

First, we need to give the model a name and specify that we are using `Clp.Optimizer` to use the clp linear programming solver. This creates a "container" for the model specification and solution.
"""

# ╔═╡ 1cfcf9bb-cced-4ebd-a885-08c84162740f
crud_model = Model(Clp.Optimizer) # initialize the model object with the Clp solver

# ╔═╡ db8c1aee-fc85-471e-ad33-d07c37d2a013
md"""
## Define variables
"""

# ╔═╡ f59a5250-5dc7-4c48-a03c-e19fc524dccb
md"""
Define the decision variables in this section. Include constraints on the variable domains, including non-negativity constraints.

If you make a mistake setting up the constraints, do not change the cell where those variables were defined and rerun it (JuMP will throw an error). Instead, create a new code cell by clicking on the + sign below a cell, then use the `set_lower_bound`, `set_upper_bound`, `delete_lower_bound`, and `delete_upper_bound` functions.
"""

# ╔═╡ fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
@variable(crud_model, E[1:3] >= 0)

# ╔═╡ 58d20e5c-8940-4142-8f2a-060932418a9d
set_upper_bound(E[1],1)

# ╔═╡ 3547cbc7-a765-4ffb-836c-e14884b03d55
set_upper_bound(E[2],1)

# ╔═╡ a557101e-70fd-4b66-8be0-e78ed1188095


# ╔═╡ dbb7525f-66a8-4020-a89a-934fa05881ab
all_variables(crud_model)

# ╔═╡ ecb79e7f-d965-42ad-8f52-151eb5859e8c
md"""
## Define constraints

Create a new cell for each needed constraint. Give each constraint a unique name. If you make a mistake entering the constraint, use the `set_normalized_coefficient` and `set_normalized_rhs` functions to correct the coefficients or the constant. You can also remove constraints using `delete` and `unregister` (use both).
"""

# ╔═╡ 6f96f93a-5b29-4b31-8cf7-159e93d17a5a


# ╔═╡ 88671baa-52ab-4e72-b74c-e720457f5b89
md"""
Call your model object to see the specification.
"""

# ╔═╡ 78f33886-d868-4546-ae8e-a70f755bbe76
# call the model object
crud_model

# ╔═╡ ed11417a-603f-4a69-a12b-bf2c50dca10b
md"""
## Define objective function

Use the cell below to define the objective function. If you make a mistake, create a new cell and use the `set_objective_coefficient` function.
"""

# ╔═╡ 0ce97251-73b4-4f1f-9b8f-79e4c5b1f920


# ╔═╡ 1ed0272d-367f-4303-9161-0aeb33780556
md"""
Now we can call the model object again to see the full specification.
"""

# ╔═╡ 666738bd-98d7-41a7-b32e-8cd483dcb379
crud_model

# ╔═╡ 7f265d7d-fd5d-46e1-8668-3beec2bae104
md"""
# Solve the model

Run the optimization command and query the variable values.
"""

# ╔═╡ e9ef4440-534c-4e9f-9ae1-b89c381f24f9
optimize!(crud_model)

# ╔═╡ e4e190f8-568c-41b7-9651-734037da4c50
# query variable values

# ╔═╡ 5edc3464-aa86-451a-9c42-9657b9729335
md"""
# Interpret model results

Use the cell below to jot down your thoughts about the problem and solution. Does the solution seem reasonable to you? What are your recommendations? What additional information would you like to have? 
"""

# ╔═╡ 26f9ac46-871b-4b27-9256-196b70c9f5ba


# ╔═╡ Cell order:
# ╟─2f2edce8-1872-11ec-32b3-671bc66f8d3b
# ╠═c21b40dd-f918-4e21-a5b2-e52e5cbb10a0
# ╠═6fec4d6d-c108-46d6-a40e-f2dac0e025b7
# ╟─7640589c-56d7-497e-9aa4-74241dd6c560
# ╟─51804401-2ff7-4f96-a25a-5f0e59cf4a53
# ╟─6710634d-208b-4f55-9e47-b4e004514a66
# ╠═1cfcf9bb-cced-4ebd-a885-08c84162740f
# ╟─db8c1aee-fc85-471e-ad33-d07c37d2a013
# ╟─f59a5250-5dc7-4c48-a03c-e19fc524dccb
# ╠═fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
# ╠═58d20e5c-8940-4142-8f2a-060932418a9d
# ╠═3547cbc7-a765-4ffb-836c-e14884b03d55
# ╠═a557101e-70fd-4b66-8be0-e78ed1188095
# ╠═dbb7525f-66a8-4020-a89a-934fa05881ab
# ╟─ecb79e7f-d965-42ad-8f52-151eb5859e8c
# ╠═6f96f93a-5b29-4b31-8cf7-159e93d17a5a
# ╟─88671baa-52ab-4e72-b74c-e720457f5b89
# ╠═78f33886-d868-4546-ae8e-a70f755bbe76
# ╟─ed11417a-603f-4a69-a12b-bf2c50dca10b
# ╠═0ce97251-73b4-4f1f-9b8f-79e4c5b1f920
# ╟─1ed0272d-367f-4303-9161-0aeb33780556
# ╠═666738bd-98d7-41a7-b32e-8cd483dcb379
# ╟─7f265d7d-fd5d-46e1-8668-3beec2bae104
# ╠═e9ef4440-534c-4e9f-9ae1-b89c381f24f9
# ╠═e4e190f8-568c-41b7-9651-734037da4c50
# ╟─5edc3464-aa86-451a-9c42-9657b9729335
# ╠═26f9ac46-871b-4b27-9256-196b70c9f5ba
