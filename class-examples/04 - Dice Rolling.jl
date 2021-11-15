### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 2b18fd9a-3a92-11ec-3ad8-2b5ae69f5f69
begin
	# import and install the Distributions package
	import Pkg
	Pkg.add("Distributions")
	Pkg.add("Plots")
	using Distributions, Plots
end

# ╔═╡ b2627751-bf38-41c5-a43f-32e0663f6612
dice_dist = DiscreteUniform(1, 6) # define distribution for a single dice roll

# ╔═╡ 891ebd07-0617-4130-88af-0cf9df1a8762
# this function rolls several dice repeatedly and returns the sums of each trial
function dice_roll_repeated(n_trials, n_dice)
	roll_results = zeros(n_trials)
	for i=1:n_trials
		roll_results[i] = sum(rand(dice_dist, n_dice))
	end
	return roll_results
end

# ╔═╡ b6638c69-9fa4-478f-ada7-d6357c87792d
rolls = dice_roll_repeated(100000, 4) # roll four dice 100,000 times

# ╔═╡ efb063af-182c-48ad-9682-91437a3dcac4
sum(rolls .== 19) / length(rolls) # calculate probability of 19

# ╔═╡ e6f58814-8161-4095-a740-447dbfd3b21c
md"""
## Change in Estimate With Additional Samples

Let's view how this estimate changes as we add each additional sample.
"""

# ╔═╡ ebe45268-4ff2-4e3b-92ec-c2915cef7ef1
avg_freq = zeros(length(rolls)) # initialize storage for frequencies by sample length

# ╔═╡ a05c47d2-e9c3-4260-b234-719c5e68b922
# compute average frequency of 19s
begin
	avg_freq[1] = rolls[1] == 19
	count = 1
	for i=2:length(rolls)
		avg_freq[i] = (avg_freq[i-1] * (i-1) + (rolls[i] == 19)) / i
	end
end

# ╔═╡ 4651a2be-8194-4dab-ad63-8d5fa3587d10
avg_freq

# ╔═╡ 5850f757-104e-4f26-bd25-e5c0e7b08c2d
# plot the running frequency and the true value
begin
	plot(avg_freq, label="frequency of 19s", legend=:bottom)
	hline!([0.0432], color="red", label="true value") # plot the true value for comparison
end

# ╔═╡ Cell order:
# ╠═2b18fd9a-3a92-11ec-3ad8-2b5ae69f5f69
# ╠═b2627751-bf38-41c5-a43f-32e0663f6612
# ╠═891ebd07-0617-4130-88af-0cf9df1a8762
# ╠═b6638c69-9fa4-478f-ada7-d6357c87792d
# ╠═efb063af-182c-48ad-9682-91437a3dcac4
# ╟─e6f58814-8161-4095-a740-447dbfd3b21c
# ╠═ebe45268-4ff2-4e3b-92ec-c2915cef7ef1
# ╠═a05c47d2-e9c3-4260-b234-719c5e68b922
# ╠═4651a2be-8194-4dab-ad63-8d5fa3587d10
# ╠═5850f757-104e-4f26-bd25-e5c0e7b08c2d
