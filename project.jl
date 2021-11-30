### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 41c5c9e1-179a-4d9f-8f10-deeb9770c102
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


# ╔═╡ d6ccc27a-be8c-43e7-adc1-7f222944d169
begin
	import XLSX
	import Statistics
end

# ╔═╡ e404eb93-06d1-47a0-9c0e-bf8a778b53ed
# Defining Global Variables
begin 
	xf = XLSX.readdata("Tidy/HVI_Ranking_Cleaned.xlsx", "HVI!A1:AB176")
    geoid = xf[:,1][2:176]
	temp = xf[:,2][2:176]
	hvi = xf[:,27][2:176]
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

# ╔═╡ 714f98f2-a42b-458d-99cd-28af107ca3c2
# Helper Function Converting Fahrenheit to Celsius
function get_celsius(farenheit)
	return 5*(farenheit-32)*(1/9)
end 

# ╔═╡ a4a11d6a-c7c3-4026-94d4-66f56f63475f
# Recalculating Means with New Temperatures 
begin
	i = 1 
	while i < length(temp)
		push!(average_temp, get_celsius(z_score[i]*std+average))
		push!(extreme_temp, get_celsius(z_score[i]*std+extreme))
		i+=1
	end 
end 

# ╔═╡ 03d5dd5b-5992-4dc9-98c0-af18129482c3
# Adding Ranges to Quartiles
begin 
	separator = (maximum(average_temp) - minimum(average_temp))/4
	index = 1
	while index < length(temp)
		if hvi[index] > 0.7 && hvi[index] <= 1 
			push!(q1, [geoid[index], average_temp[index], extreme_temp[index]]) 
		elseif hvi[index] > 0.5 && hvi[index] <= 0.7 
			push!(q2, [geoid[index], average_temp[index], extreme_temp[index]])
		elseif hvi[index] > 0.3 && hvi[index] <= 0.5 
			push!(q3, [geoid[index], average_temp[index], extreme_temp[index]]) 
		else 
			push!(q4, [geoid[index], average_temp[index], extreme_temp[index]])
		end 
		index += 1
	end 
end 

# ╔═╡ 456f63c4-4d4b-4679-9c42-228787c29d9c
length(q1)

# ╔═╡ f31ec0b3-7a90-42e0-9969-f1bb6048e77c
length(q2)

# ╔═╡ 586b6484-2062-471c-9bc4-f5e017ced3c1
length(q3)

# ╔═╡ 60a19d85-c9e4-4f17-b12d-6c83ff29d0bf
length(q4)

# ╔═╡ ee0dee84-a004-4d92-961d-af819f1393a8
md"""

#### Decision Variables
- ``X_{ij}`` represents the area of section i that is renovated to method j (in mi)

#### Objective: Minimize Cost
minimizing the cost (installation + maintenace)

#### Constraints:
###### Nonnegativity
Because we cannot have negative waste flows, all of the waste and residual streams must be greater or equal to zero. For the relevant i,j,k values:
```math
X_{ij} \geq 0
``` 
"""

# ╔═╡ d84e1d84-2ed0-4e49-9034-294908a64d6d
begin
	totalArea = 1700582400; #ft^2
	timeHorizon = 50; #years

	#in the following order of each treatment method
		# 	 A 	  B 	C 	  D 	E 	  F 	
	deltaT = [0 -6.67 -5.71 -4.00 -5.60 -10.0];
	installCost = [0 12.50 1.50 0.60 1.736 3.50];
	maintCost = [0 0.31 0.20 0.12 0.0067 0.50];
	methodWeights = [0 .40 .125 .075 .20 .20];


	#Model Inputs: temperature, given above as average and extreme
	
end

# ╔═╡ Cell order:
# ╠═06f79570-4636-11ec-1ab2-f36e6b5586f3
# ╠═41c5c9e1-179a-4d9f-8f10-deeb9770c102
# ╠═d6ccc27a-be8c-43e7-adc1-7f222944d169
# ╠═e404eb93-06d1-47a0-9c0e-bf8a778b53ed
# ╠═714f98f2-a42b-458d-99cd-28af107ca3c2
# ╠═a4a11d6a-c7c3-4026-94d4-66f56f63475f
# ╠═03d5dd5b-5992-4dc9-98c0-af18129482c3
# ╠═456f63c4-4d4b-4679-9c42-228787c29d9c
# ╠═f31ec0b3-7a90-42e0-9969-f1bb6048e77c
# ╠═586b6484-2062-471c-9bc4-f5e017ced3c1
# ╠═60a19d85-c9e4-4f17-b12d-6c83ff29d0bf
# ╟─ee0dee84-a004-4d92-961d-af819f1393a8
# ╠═d84e1d84-2ed0-4e49-9034-294908a64d6d
