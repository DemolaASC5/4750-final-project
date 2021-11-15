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
\begin{align*}
 & \min  Z = 146, 880 - 17,280 Q_1 - 38880 Q_2 - 51840 Q_3 &  \\
 & \text{subject to} &&\\
     & 1390 Q_1  & \leq 150\\
     & 129 Q_1 +  152 Q_2 +  155 Q_3 & \leq 150 \\
     & 33 Q_1 +  196 Q_2 + 260 Q_3  &\leq 150 \\
     & Q_1  & \leq 0.4 \\
     & \quad Q_2 & \leq 2.0 \\
     & \quad \quad  Q_3 & \leq 1.2 \\
     & Q_1, Q_2, Q_3  &  \geq 0
\end{align*}
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
air_model = Model(Clp.Optimizer) # initialize the model object with the Ipopt solver

# ╔═╡ db8c1aee-fc85-471e-ad33-d07c37d2a013
md"""
## Define variables
"""

# ╔═╡ f59a5250-5dc7-4c48-a03c-e19fc524dccb
md"""
Define the decision variables in this section. Include constraints on the variable domains, including non-negativity constraints.

If you make a mistake setting up the constraints, do not change the cell where those variables were defined and rerun it (JuMP will throw an error). Instead, create a new code cell by clicking on the + sign below a cell, then use the `set_lower_bound`, `set_upper_bound`, `delete_lower_bound`, and `delete_upper_bound` functions.
"""

# ╔═╡ c8e8e3ea-477b-4b69-8add-c273a01abc04
unregister(air_model, :Q)

# ╔═╡ fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
begin 	
	@variables(air_model, begin
		Q[i=1:3] >= 0, (base_name = "Q")
	end)
end

# ╔═╡ 70223245-40fc-4755-9233-57d65cf0272a
md""" ### Define Objective: 

"""

# ╔═╡ fc25bd8e-5357-4358-9e9f-d737c021feff
@objective(air_model, Min, 146880-17280*Q[1]-38880*Q[2]-51840*Q[3])

# ╔═╡ ecb79e7f-d965-42ad-8f52-151eb5859e8c
md"""
## Define constraints

Create a new cell for each needed constraint. Give each constraint a unique name. If you make a mistake entering the constraint, use the `set_normalized_coefficient` and `set_normalized_rhs` functions to correct the coefficients or the constant. You can also remove constraints using `delete` and `unregister` (use both).
"""

# ╔═╡ 0bb61701-62e8-410d-ae85-7ad5d44d69a7
begin
	@constraint(air_model,1390*Q[1]<= 150)
	@constraint(air_model,129*Q[1]+152*Q[2]+155*Q[3]<= 150)
	@constraint(air_model,33*Q[1]+196*Q[2]+260*Q[3]<= 150)
	@constraint(air_model,Q[1]<=0.4)
	@constraint(air_model,Q[2]<=2.0)
	@constraint(air_model,Q[3]<=1.2)
end


# ╔═╡ 88671baa-52ab-4e72-b74c-e720457f5b89
md"""
Call your model object to see the specification.
"""

# ╔═╡ 6f96f93a-5b29-4b31-8cf7-159e93d17a5a
latex_formulation(air_model)

# ╔═╡ 7f265d7d-fd5d-46e1-8668-3beec2bae104
md"""
# Solve the model

Run the optimization command and query the variable values.
"""

# ╔═╡ 5896d26c-36ed-4adc-b015-933fcc75a2ec
optimize!(air_model)

# ╔═╡ e4e190f8-568c-41b7-9651-734037da4c50
# query variable values
value.(Q)

# ╔═╡ 70bb83c6-4b54-47f4-bab5-1e2ffd92ee25
objective_value(air_model)


# ╔═╡ Cell order:
# ╠═2f2edce8-1872-11ec-32b3-671bc66f8d3b
# ╠═d64ab580-fbb7-4809-b4e2-5b886f2c558e
# ╠═7640589c-56d7-497e-9aa4-74241dd6c560
# ╟─51804401-2ff7-4f96-a25a-5f0e59cf4a53
# ╟─6710634d-208b-4f55-9e47-b4e004514a66
# ╠═1cfcf9bb-cced-4ebd-a885-08c84162740f
# ╟─db8c1aee-fc85-471e-ad33-d07c37d2a013
# ╟─f59a5250-5dc7-4c48-a03c-e19fc524dccb
# ╠═c8e8e3ea-477b-4b69-8add-c273a01abc04
# ╠═fcfcb9c3-2e82-4ac6-bc54-916fa71066e0
# ╟─70223245-40fc-4755-9233-57d65cf0272a
# ╠═fc25bd8e-5357-4358-9e9f-d737c021feff
# ╟─ecb79e7f-d965-42ad-8f52-151eb5859e8c
# ╠═0bb61701-62e8-410d-ae85-7ad5d44d69a7
# ╟─88671baa-52ab-4e72-b74c-e720457f5b89
# ╠═6f96f93a-5b29-4b31-8cf7-159e93d17a5a
# ╟─7f265d7d-fd5d-46e1-8668-3beec2bae104
# ╠═5896d26c-36ed-4adc-b015-933fcc75a2ec
# ╠═e4e190f8-568c-41b7-9651-734037da4c50
# ╠═70bb83c6-4b54-47f4-bab5-1e2ffd92ee25
