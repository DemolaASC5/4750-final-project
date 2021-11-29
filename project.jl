### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 7c00440f-18fb-45c8-ad6f-6db855afbea2
begin
	using Pkg
	Pkg.add("XLSX")
	Pkg.add("Statistics")
end

# ╔═╡ 06f79570-4636-11ec-1ab2-f36e6b5586f3
students = [(name = "Anna Cliche", cornell_id = "amc527"),
			(name = "Cormac Mahoney", cornell_id = "cam495"),
			(name = "Demola Ogunnaike", cornell_id = "dko22")
		   ]


# ╔═╡ 4563cda0-f28a-48a0-8bae-a958ae9d5bc2
begin
	import XLSX
	import Statistics
end

# ╔═╡ 61353d15-eb27-47e2-a1ec-64144586eda4
# Defining Global Variables
begin 
	xf = XLSX.readdata("Tidy/HVI_Ranking_Cleaned.xlsx", "HVI!A1:D176")
    geoid = xf[:,1][2:176]
	temp = xf[:,2][2:176]
	z_score = xf[:,3][2:176]
	std = Statistics.mean(xf[:,4][2:176])
	average = 87
	extreme = 96 
	average_temp = []
	extreme_temp = []
	q1 = [] 
	q2 = []
	q3 = []
	q4 = []
end 

# ╔═╡ 0a08368d-3886-4886-b8df-ff2512209a20
# Helper Function Converting Fahrenheit to Celsius
function get_celsius(farenheit)
	return 5*(farenheit-32)*(1/9)
end 

# ╔═╡ 107371d6-14ea-454a-b08d-4609ab15d0eb
# Recalculating Means with New Temperatures 
begin
	i = 1 
	while i < length(temp)
		push!(average_temp, get_celsius(z_score[i]*std+average))
		push!(extreme_temp, get_celsius(z_score[i]*std+extreme))
		i+=1
	end 
end 

# ╔═╡ d109e432-a64d-4f1f-b771-46efeca8f614
# Adding Ranges to Quartiles
begin 
	separator = (maximum(average_temp) - minimum(average_temp))/4
	index = 1
	while index < length(temp)
		if average_temp[index] > get_celsius(average) - 2*separator && average_temp[index] <= get_celsius(average) - separator
			push!(q1, [geoid[index], average_temp[index], extreme_temp[index]]) 
		elseif average_temp[index] > get_celsius(average) - separator && average_temp[index] <= get_celsius(average)
			push!(q2, [geoid[index], average_temp[index], extreme_temp[index]])
		elseif average_temp[index] > get_celsius(average) && average_temp[index] <= get_celsius(average) + separator
			push!(q3, [geoid[index], average_temp[index], extreme_temp[index]]) 
		else 
			push!(q4, [geoid[index], average_temp[index], extreme_temp[index]])
		end 
		index += 1
	end 
end 

# ╔═╡ e23086c2-6489-4e63-affa-7b90039553b5
length(q1)

# ╔═╡ 1fc1e175-d3cc-425f-80a6-3d730226ce18
length(q2)

# ╔═╡ 7026516e-d7a7-4946-a9b1-f53752bc306e
length(q3)

# ╔═╡ 713cb104-8389-404a-91f8-a159a8021d2f
length(q4)

# ╔═╡ Cell order:
# ╠═06f79570-4636-11ec-1ab2-f36e6b5586f3
# ╠═7c00440f-18fb-45c8-ad6f-6db855afbea2
# ╠═4563cda0-f28a-48a0-8bae-a958ae9d5bc2
# ╠═61353d15-eb27-47e2-a1ec-64144586eda4
# ╠═0a08368d-3886-4886-b8df-ff2512209a20
# ╠═107371d6-14ea-454a-b08d-4609ab15d0eb
# ╠═d109e432-a64d-4f1f-b771-46efeca8f614
# ╠═e23086c2-6489-4e63-affa-7b90039553b5
# ╠═1fc1e175-d3cc-425f-80a6-3d730226ce18
# ╠═7026516e-d7a7-4946-a9b1-f53752bc306e
# ╠═713cb104-8389-404a-91f8-a159a8021d2f
