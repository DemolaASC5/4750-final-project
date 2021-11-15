### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 2f2edce8-1872-11ec-32b3-671bc66f8d3b
begin
	import Pkg  # import the Julia package manager
	Pkg.add("JuMP") # install the JuMP package
	Pkg.add("Clp") # install the Ipopt interface
	#Pkg.update()
end

# ╔═╡ d64ab580-fbb7-4809-b4e2-5b886f2c558e
using JuMP, Clp # load required packages

# ╔═╡ 7640589c-56d7-497e-9aa4-74241dd6c560
md"""
# Define the model
```math
 \begin{align}
    & \max Z = 220G_1 + 240G_2 + 370G_3 \\
   &\text{subject to} &&\\
    & 0.5G_1 + G_2 + 1.5G_3 & \leq & 320\\
    & 1.5G_1 + 2G_2 + 2G_3 & \leq& 720 \\
    & G_1, G_2, G_3 &\geq& 0 
 \end{align}
```
"""

# ╔═╡ 51804401-2ff7-4f96-a25a-5f0e59cf4a53
md"""
# Set up the model in JuMP
"""

# ╔═╡ 6710634d-208b-4f55-9e47-b4e004514a66
md"""
## Define the model object

First, we need to give the model a name and specify that we are using `Clp.Optimizer`. This creates a "container" for the model specification and solution.
"""

# ╔═╡ 1cfcf9bb-cced-4ebd-a885-08c84162740f
forest_model = Model(Clp.Optimizer) # initialize the model object with the Ipopt solver

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
begin 
	@variable(forest_model, G[1:3], lower_bound=0)
end

# ╔═╡ 70223245-40fc-4755-9233-57d65cf0272a
md""" ### Define Objective: 

"""

# ╔═╡ 1bc66dd0-a5cc-45b3-aa07-1fd3782382b1
@objective(forest_model, Max, 400G[1]+520G[2]+710G[3])

# ╔═╡ ecb79e7f-d965-42ad-8f52-151eb5859e8c
md"""
### Define constraints

"""

# ╔═╡ 0bb61701-62e8-410d-ae85-7ad5d44d69a7
begin
	@constraint(forest_model,spruceLimit, 0.5G[1] + G[2] + 1.5G[3] <= 320)
	@constraint(forest_model,firLimit, 1.5G[1] + 2G[2] + 2G[3] <= 720)
end 

# ╔═╡ 88671baa-52ab-4e72-b74c-e720457f5b89
md"""
Call your model object to see the specification.
"""

# ╔═╡ 6f96f93a-5b29-4b31-8cf7-159e93d17a5a
latex_formulation(forest_model)

# ╔═╡ 7f265d7d-fd5d-46e1-8668-3beec2bae104
md"""
# Solve the model

Run the optimization command and query the variable values.
"""

# ╔═╡ 5896d26c-36ed-4adc-b015-933fcc75a2ec
optimize!(forest_model)

# ╔═╡ e4e190f8-568c-41b7-9651-734037da4c50
# query variable values
value.(G)

# ╔═╡ 70bb83c6-4b54-47f4-bab5-1e2ffd92ee25
objective_value(forest_model)


# ╔═╡ ee4a69bb-7677-4422-8889-62490f73c43f
md"""
# Sensitivity Analysis

Run the optimization command and query the variable values.
"""

# ╔═╡ fa4ab34f-d5eb-4c1b-9730-182d1754c8ab
has_duals(forest_model)

# ╔═╡ f6df5c77-b302-4dbd-8f51-665dd48ae80e
dual(spruceLimit)

# ╔═╡ 4c2894a2-be7a-4a98-8b52-a744d0db9e5c
shadow_price(spruceLimit)

# ╔═╡ 9097edea-1959-4657-8ec3-14895f3da82e
shadow_price(firLimit)

# ╔═╡ 9f47dfbe-4116-467e-993d-840637e98095
set_normalized_rhs(spruceLimit, 320)

# ╔═╡ 63c90892-c0fc-430e-b8c9-1c7fd77a7768
set_normalized_rhs(firLimit, 722)

# ╔═╡ 62541ea4-f0cc-4ce3-b944-915590e0ee70
latex_formulation(forest_model)

# ╔═╡ e5e8826a-4512-4679-aaad-de29f9785e1a
optimize!(forest_model)

# ╔═╡ b075dce9-18e4-42ad-9432-faba5ce0f58e
objective_value(forest_model)

# ╔═╡ 69dc2bac-1363-4329-8c17-cc897b781251
value.(G)

# ╔═╡ Cell order:
# ╠═2f2edce8-1872-11ec-32b3-671bc66f8d3b
# ╠═d64ab580-fbb7-4809-b4e2-5b886f2c558e
# ╠═7640589c-56d7-497e-9aa4-74241dd6c560
# ╟─51804401-2ff7-4f96-a25a-5f0e59cf4a53
# ╟─6710634d-208b-4f55-9e47-b4e004514a66
# ╠═1cfcf9bb-cced-4ebd-a885-08c84162740f
# ╟─db8c1aee-fc85-471e-ad33-d07c37d2a013
# ╟─f59a5250-5dc7-4c48-a03c-e19fc524dccb
# ╠═fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
# ╟─70223245-40fc-4755-9233-57d65cf0272a
# ╠═1bc66dd0-a5cc-45b3-aa07-1fd3782382b1
# ╟─ecb79e7f-d965-42ad-8f52-151eb5859e8c
# ╠═0bb61701-62e8-410d-ae85-7ad5d44d69a7
# ╟─88671baa-52ab-4e72-b74c-e720457f5b89
# ╠═6f96f93a-5b29-4b31-8cf7-159e93d17a5a
# ╠═7f265d7d-fd5d-46e1-8668-3beec2bae104
# ╠═5896d26c-36ed-4adc-b015-933fcc75a2ec
# ╠═e4e190f8-568c-41b7-9651-734037da4c50
# ╠═70bb83c6-4b54-47f4-bab5-1e2ffd92ee25
# ╟─ee4a69bb-7677-4422-8889-62490f73c43f
# ╠═fa4ab34f-d5eb-4c1b-9730-182d1754c8ab
# ╠═f6df5c77-b302-4dbd-8f51-665dd48ae80e
# ╠═4c2894a2-be7a-4a98-8b52-a744d0db9e5c
# ╠═9097edea-1959-4657-8ec3-14895f3da82e
# ╠═9f47dfbe-4116-467e-993d-840637e98095
# ╠═63c90892-c0fc-430e-b8c9-1c7fd77a7768
# ╠═62541ea4-f0cc-4ce3-b944-915590e0ee70
# ╠═e5e8826a-4512-4679-aaad-de29f9785e1a
# ╠═b075dce9-18e4-42ad-9432-faba5ce0f58e
# ╠═69dc2bac-1363-4329-8c17-cc897b781251
