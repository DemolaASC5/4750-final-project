### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ 41c5c9e1-179a-4d9f-8f10-deeb9770c102
begin
	using Pkg
	Pkg.add("XLSX")
	Pkg.add("Statistics")
end

# ╔═╡ 9d8601da-ca8f-48bd-83f9-369e84bb4249
using JuMP, Clp

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

# ╔═╡ bab59ba1-0506-4ec8-a87f-4f55d49062f5
oldTemp = 30.55; #Celsius

# ╔═╡ d84e1d84-2ed0-4e49-9034-294908a64d6d
begin
	totalArea = 1700582400; #ft^2
	timeHorizon = 50; #years

	#quartiles:  1 	2 	3 	4
	HVIweights = [0.1 0.2 0.3 0.4];
	percentArea = [0.074285714 0.325714286 0.514285714 0.085714286];
	tempVar = [-1.265741024 -0.436508545 0.308562915 0.904330533];
	
	# the following given the percent of the each quartiles area that is un/available for each treatment method:
	perUnavailable = [.60 .30 .30 .20]; #A
	perRoof = [.16 .17 .17 .20]; 		#B,C
	perStreet = [.10 .20 .20 .25];		#D
	perSidewalk = [.10 .20 .20 .25]; 	#E
	perPark = [.04 .08 .08 .10]; 		#F

	#treatment methods:
		# 	 A 	  B 	C 	  D 	E 	  F 	
	deltaT = [0 -6.67 -5.71 -4.00 -5.60 -10.0]; #expected ambient temperature change
	installCost = [0 12.50 1.50 0.60 1.736 3.50];  # $/sqft
	maintCost = [0 0.31 0.20 0.12 0.0067 0.50];    # $/sqft/yr
	totalCost = installCost+maintCost*timeHorizon; # $/sqft
	methodWeights = [0 .40 .125 .075 .20 .20]; 


	#Model Inputs: temperature, given above as average and extreme
	
end

# ╔═╡ d2212704-6a76-45e3-bb6a-ffddd6d1c4c8
totalCost

# ╔═╡ 4973992f-7afa-4109-bfc0-6db154f1b916
begin
	quadrantArea = totalArea*percentArea;
	availableArea = zeros(4,6)
	for i=1:4
		availableArea[i,1]=quadrantArea[i]*perUnavailable[i];
	end
	for i=1:4
		availableArea[i,2]=quadrantArea[i]*perRoof[i];
		availableArea[i,3]=quadrantArea[i]*perRoof[i];
	end
	for i=1:4
		availableArea[i,4]=quadrantArea[i]*perStreet[i];
	end	
	for i=1:4
		availableArea[i,5]=quadrantArea[i]*perSidewalk[i];
	end	
	for i=1:4
		availableArea[i,6]=quadrantArea[i]*perPark[i];
	end
end

# ╔═╡ 867d63a8-39da-41e7-90fb-56efbe530a3b
availableArea
# each row represents the quadrants: 1 2 3 4
# each column represents the treatment method: A B C D E F
# the value at row i, column j represents the area of quadrant i that is available for the treatment method j

# ╔═╡ 0c0522ba-5ab5-4573-a4ba-ffe31210e91f
UHImodel = Model(Clp.Optimizer)

# ╔═╡ 20da94e4-3a47-4ea7-ada4-1b0697526285
@variable(UHImodel, 0 <= X[i=1:4, j=1:6] <= 1)

# ╔═╡ 991efd91-b696-478c-a9d5-eb7a39237129
@objective(UHImodel, Min, begin 						#total cost function
	(X[1,1]+X[2,1]+X[3,1]+X[4,1])*(totalCost[1]) +
	(X[1,2]+X[2,2]+X[3,2]+X[4,2])*(totalCost[2]) +
	(X[1,3]+X[2,3]+X[3,3]+X[4,3])*(totalCost[3]) +
	(X[1,4]+X[2,4]+X[3,4]+X[4,4])*(totalCost[4])
end)

# ╔═╡ 19a1a43e-0ab8-4360-8978-3f1820cd55fb
md"""
temperature change = oldtemp - newtemp

newtemp = sum(quadrantArea*quadTempChange) / totalArea

= (quadrantArea[1]*quadTempChange[1] +quadrantArea[2]*quadTempChange[2] +quadrantArea[3]*quadTempChange[3]+quadrantArea[3]*quadTempChange[3]) / totalArea

each quadrant's quadTempChange = oldtemp*tempVar + tempChanges

each Xij's tempChanges = Xij*deltaT(j)/availableArea(ij)

"""

# ╔═╡ 819162a4-90a7-4781-b1b0-fd6b0e962f59
minTempChange = 0.5;

# ╔═╡ 24e335d3-decb-4f85-b70a-36e2b1fee467
begin
quadTempChange1 = oldTemp*tempVar[1] + 
X[1,1]*deltaT[1]/availableArea[1,1] + X[1,2]*deltaT[2]/availableArea[1,2] + 	X[1,3]*deltaT[3]/availableArea[1,3] + X[1,4]*deltaT[4]/availableArea[1,4] + X[1,5]*deltaT[5]/availableArea[1,5] + X[1,6]*deltaT[6]/availableArea[1,6];

quadTempChange2 = oldTemp*tempVar[2] + 
X[2,1]*deltaT[1]/availableArea[2,1] + X[2,2]*deltaT[2]/availableArea[2,2] + 	X[2,3]*deltaT[3]/availableArea[2,3] + X[2,4]*deltaT[4]/availableArea[2,4] + X[2,5]*deltaT[5]/availableArea[2,5] + X[2,6]*deltaT[6]/availableArea[2,6];

quadTempChange3 = oldTemp*tempVar[3] + 
X[3,1]*deltaT[1]/availableArea[3,1] + X[3,2]*deltaT[2]/availableArea[3,2] + 	X[3,3]*deltaT[3]/availableArea[3,3] + X[3,4]*deltaT[4]/availableArea[3,4] + X[3,5]*deltaT[5]/availableArea[3,5] + X[3,6]*deltaT[6]/availableArea[3,6];

quadTempChange4 = oldTemp*tempVar[4] + 
X[4,1]*deltaT[1]/availableArea[4,1] + X[4,2]*deltaT[2]/availableArea[4,2] + 	X[4,3]*deltaT[3]/availableArea[4,3] + X[4,4]*deltaT[4]/availableArea[4,4] + X[4,5]*deltaT[5]/availableArea[4,5] + X[4,6]*deltaT[6]/availableArea[4,6];
end

# ╔═╡ 66d0186f-5b39-404f-adbe-116191db4236
temperatureChange = oldTemp - 1/totalArea*(quadrantArea[1]*quadTempChange1 +quadrantArea[2]*quadTempChange2 +quadrantArea[3]*quadTempChange3 +quadrantArea[3]*quadTempChange4);

# ╔═╡ d6bee536-f55d-45e0-b4fc-4c3d81fc8785
# working on expression for the overall temperature change
@constraint(UHImodel, ResultingTemperatureChange, temperatureChange >= minTempChange )

# ╔═╡ 5e6bc7d0-cc71-44f4-912e-7a8a9146c58e
# constraint for Xij cannot be bigger than the available space

# need to somehow include the social benefits/weights

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
# ╠═bab59ba1-0506-4ec8-a87f-4f55d49062f5
# ╠═d84e1d84-2ed0-4e49-9034-294908a64d6d
# ╠═d2212704-6a76-45e3-bb6a-ffddd6d1c4c8
# ╠═4973992f-7afa-4109-bfc0-6db154f1b916
# ╠═867d63a8-39da-41e7-90fb-56efbe530a3b
# ╠═9d8601da-ca8f-48bd-83f9-369e84bb4249
# ╠═0c0522ba-5ab5-4573-a4ba-ffe31210e91f
# ╠═20da94e4-3a47-4ea7-ada4-1b0697526285
# ╠═991efd91-b696-478c-a9d5-eb7a39237129
# ╠═19a1a43e-0ab8-4360-8978-3f1820cd55fb
# ╠═819162a4-90a7-4781-b1b0-fd6b0e962f59
# ╠═24e335d3-decb-4f85-b70a-36e2b1fee467
# ╠═66d0186f-5b39-404f-adbe-116191db4236
# ╠═d6bee536-f55d-45e0-b4fc-4c3d81fc8785
# ╠═5e6bc7d0-cc71-44f4-912e-7a8a9146c58e
