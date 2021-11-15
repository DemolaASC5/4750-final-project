### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ f2db9afb-16e0-406a-85b5-afdbe17ef22d
begin
	# Install packages 
import Pkg  
Pkg.add("DataFrames")
Pkg.add("Plots")
Pkg.add("GLM")
end 

# ╔═╡ 42c59501-d365-4d95-a2ca-9278ef1943e6
begin
	using DataFrames
	using Plots
	using GLM
	using Statistics
end

# ╔═╡ 32fb37a0-fd64-4b16-b858-5cf1dd0bb1b0
data = DataFrame(x = [0,65,95], C = [0,0.1,0.18])

# ╔═╡ 6bcf7e56-0bc6-4608-8866-c1d862d0b545
begin
	fm = @formula(C ~ x)
	linearRegressor = lm(fm, data)
end

# ╔═╡ Cell order:
# ╠═f2db9afb-16e0-406a-85b5-afdbe17ef22d
# ╠═42c59501-d365-4d95-a2ca-9278ef1943e6
# ╠═32fb37a0-fd64-4b16-b858-5cf1dd0bb1b0
# ╠═6bcf7e56-0bc6-4608-8866-c1d862d0b545
