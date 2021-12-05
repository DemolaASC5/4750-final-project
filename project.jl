### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ 9d8601da-ca8f-48bd-83f9-369e84bb4249
using JuMP, Clp

# ╔═╡ 06f79570-4636-11ec-1ab2-f36e6b5586f3
students = [(name = "Anna Cliche", cornell_id = "amc527"),
			(name = "Cormac Mahoney", cornell_id = "cam495"),
			(name = "Demola Ogunnaike", cornell_id = "dko22")]

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
	percentArea = [.20 .23 .27 .30];
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
	for i=1:4  availableArea[i,1]=quadrantArea[i]*perUnavailable[i]; end
	for i=1:4
		availableArea[i,2]=quadrantArea[i]*perRoof[i];
		availableArea[i,3]=quadrantArea[i]*perRoof[i];
	end
	for i=1:4 availableArea[i,4]=quadrantArea[i]*perStreet[i]; end	
	for i=1:4 availableArea[i,5]=quadrantArea[i]*perSidewalk[i]; end	
	for i=1:4 availableArea[i,6]=quadrantArea[i]*perPark[i]; end
end

# ╔═╡ 867d63a8-39da-41e7-90fb-56efbe530a3b
availableArea
# each row represents the quadrants: 1 2 3 4
# each column represents the treatment method: A B C D E F
# the value at row i, column j represents the area of quadrant i that is available for the treatment method j

# ╔═╡ 0c0522ba-5ab5-4573-a4ba-ffe31210e91f
UHImodel = Model(Clp.Optimizer)

# ╔═╡ 20da94e4-3a47-4ea7-ada4-1b0697526285
@variable(UHImodel, 0 <= X[i=1:4, j=1:6]) #Decision Variables

# ╔═╡ 991efd91-b696-478c-a9d5-eb7a39237129
@objective(UHImodel, Min, begin 						#total cost function
	(X[1,1]+X[2,1]+X[3,1]+X[4,1])*(totalCost[1]) +
	(X[1,2]+X[2,2]+X[3,2]+X[4,2])*(totalCost[2]) +
	(X[1,3]+X[2,3]+X[3,3]+X[4,3])*(totalCost[3]) +
	(X[1,4]+X[2,4]+X[3,4]+X[4,4])*(totalCost[4])
end)

# ╔═╡ 819162a4-90a7-4781-b1b0-fd6b0e962f59
minTempChange = 1;

# ╔═╡ 24e335d3-decb-4f85-b70a-36e2b1fee467
begin
quadTempChange1 = tempVar[1] + 
X[1,1]*deltaT[1]/availableArea[1,1] + X[1,2]*deltaT[2]/availableArea[1,2] + 	X[1,3]*deltaT[3]/availableArea[1,3] + X[1,4]*deltaT[4]/availableArea[1,4] + X[1,5]*deltaT[5]/availableArea[1,5] + X[1,6]*deltaT[6]/availableArea[1,6];

quadTempChange2 = tempVar[2] + 
X[2,1]*deltaT[1]/availableArea[2,1] + X[2,2]*deltaT[2]/availableArea[2,2] + 	X[2,3]*deltaT[3]/availableArea[2,3] + X[2,4]*deltaT[4]/availableArea[2,4] + X[2,5]*deltaT[5]/availableArea[2,5] + X[2,6]*deltaT[6]/availableArea[2,6];

quadTempChange3 = tempVar[3] + 
X[3,1]*deltaT[1]/availableArea[3,1] + X[3,2]*deltaT[2]/availableArea[3,2] + 	X[3,3]*deltaT[3]/availableArea[3,3] + X[3,4]*deltaT[4]/availableArea[3,4] + X[3,5]*deltaT[5]/availableArea[3,5] + X[3,6]*deltaT[6]/availableArea[3,6];

quadTempChange4 = tempVar[4] + 
X[4,1]*deltaT[1]/availableArea[4,1] + X[4,2]*deltaT[2]/availableArea[4,2] + 	X[4,3]*deltaT[3]/availableArea[4,3] + X[4,4]*deltaT[4]/availableArea[4,4] + X[4,5]*deltaT[5]/availableArea[4,5] + X[4,6]*deltaT[6]/availableArea[4,6];
end

# ╔═╡ 9a83bd91-4a32-4340-b0f1-2bbd114f2ee3
@expression(UHImodel, quad1Tempchange, tempVar[1] + 
X[1,1]*deltaT[1]/availableArea[1,1] + X[1,2]*deltaT[2]/availableArea[1,2] + 	X[1,3]*deltaT[3]/availableArea[1,3] + X[1,4]*deltaT[4]/availableArea[1,4] + X[1,5]*deltaT[5]/availableArea[1,5] + X[1,6]*deltaT[6]/availableArea[1,6])

# ╔═╡ 66d0186f-5b39-404f-adbe-116191db4236
temperatureChange = oldTemp - 1/totalArea*(quadrantArea[1]*quadTempChange1 +quadrantArea[2]*quadTempChange2 +quadrantArea[3]*quadTempChange3 +quadrantArea[3]*quadTempChange4);

# ╔═╡ d6bee536-f55d-45e0-b4fc-4c3d81fc8785
# working on expression for the overall temperature change
@constraint(UHImodel, ResultingTemperatureChange, temperatureChange - oldTemp >= minTempChange )

# ╔═╡ 5e6bc7d0-cc71-44f4-912e-7a8a9146c58e
# constraint for Xij cannot be bigger than the available space
@constraints(UHImodel, begin
	X[1,1] <= availableArea[1,1] 
	X[1,2] <= availableArea[1,2]
	X[1,3] <= availableArea[1,3] 
	X[1,4] <= availableArea[1,4]
	X[1,5] <= availableArea[1,5]
	X[1,6] <= availableArea[1,6]

	X[2,1] <= availableArea[2,1]
	X[2,2] <= availableArea[2,2]
	X[2,3] <= availableArea[2,3] 
	X[2,4] <= availableArea[2,4]
	X[2,5] <= availableArea[2,5]
	X[2,6] <= availableArea[2,6]

	X[3,1] <= availableArea[3,1]
	X[3,2] <= availableArea[3,2]
	X[3,3] <= availableArea[3,3]
	X[3,4] <= availableArea[3,4]
	X[3,5] <= availableArea[3,5]
	X[3,6] <= availableArea[3,6]

	X[4,1] <= availableArea[4,1]
	X[4,2] <= availableArea[4,2]
	X[4,3] <= availableArea[4,3]
	X[4,4] <= availableArea[4,4]
	X[4,5] <= availableArea[4,5]
	X[4,6] <= availableArea[4,6]

end)
# need to somehow include the social benefits/weights

# ╔═╡ 152e438d-c7c6-4e02-91d3-c21ae78d264f
latex_formulation(UHImodel)

# ╔═╡ 7751958e-9072-42d3-a0c8-b7cdedae617b
optimize!(UHImodel)

# ╔═╡ b1ce85d8-9518-48e6-851d-8ac84f25c6ed
objective_value(UHImodel)

# ╔═╡ b7688b63-963a-4094-913a-2de1df374b09
value.(X) 

# ╔═╡ a9086a0a-2226-4a20-8154-bfd19f9f2a67
value.(temperatureChange)


# ╔═╡ 56bedfa5-82f2-4732-bacd-b920a4affe0e
oldTemp

# ╔═╡ c24c426c-4247-408d-a222-b1dea19fd2c5
value.(quad1Tempchange)

# ╔═╡ 58a78f9b-caaa-4978-a8a4-8e3d88958c5b


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Clp = "e2554f3b-3117-50c0-817c-e040a3ddf72d"
JuMP = "4076af6c-e467-56ae-b986-b466b2749572"

[compat]
Clp = "~0.9.0"
JuMP = "~0.22.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[Clp]]
deps = ["BinaryProvider", "CEnum", "Clp_jll", "Libdl", "MathOptInterface", "SparseArrays"]
git-tree-sha1 = "4ef4031fda1e0df933983b23b81b83a3dd1963f3"
uuid = "e2554f3b-3117-50c0-817c-e040a3ddf72d"
version = "0.9.0"

[[Clp_jll]]
deps = ["Artifacts", "CoinUtils_jll", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "METIS_jll", "MUMPS_seq_jll", "OpenBLAS32_jll", "Osi_jll", "Pkg"]
git-tree-sha1 = "5e4f9a825408dc6356e6bf1015e75d2b16250ec8"
uuid = "06985876-5285-5a41-9fcb-8948a742cc53"
version = "100.1700.600+0"

[[CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[CoinUtils_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "9b4a8b1087376c56189d02c3c1a48a0bba098ec2"
uuid = "be027038-0da8-5614-b30d-e42594cb92df"
version = "2.11.4+2"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "d8f468c5cd4d94e86816603f7d18ece910b4aaf1"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.5.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "6406b5112809c08b1baa5703ad274e1dded0652f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.23"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JuMP]]
deps = ["Calculus", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MathOptInterface", "MutableArithmetics", "NaNMath", "Printf", "Random", "SparseArrays", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "de9c69c0862be0e11afe5d4aa3426af1d7ecac2c"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "0.22.1"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[METIS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "2dc1a9fc87e57e32b1fc186db78811157b30c118"
uuid = "d00139f3-1899-568f-a2f0-47f597d42d70"
version = "5.1.0+5"

[[MUMPS_seq_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "METIS_jll", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "a1d469a2a0acbfe219ef9bdfedae97daacac5a0e"
uuid = "d7ed1dd3-d0ae-5e8e-bfb4-87a502085b8d"
version = "5.4.0+0"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "JSON", "LinearAlgebra", "MutableArithmetics", "OrderedCollections", "Printf", "SparseArrays", "Test", "Unicode"]
git-tree-sha1 = "92b7de61ecb616562fd2501334f729cc9db2a9a6"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "0.10.6"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "7bb6853d9afec54019c1397c6eb610b9b9a19525"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.3.1"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ba4a8f683303c9082e84afba96f25af3c7fb2436"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.12+1"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Osi_jll]]
deps = ["Artifacts", "CoinUtils_jll", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "6a9967c4394858f38b7fc49787b983ba3847e73d"
uuid = "7da25872-d9ce-5375-a4d3-7a845f58efdd"
version = "0.108.6+2"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═06f79570-4636-11ec-1ab2-f36e6b5586f3
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
# ╠═819162a4-90a7-4781-b1b0-fd6b0e962f59
# ╠═24e335d3-decb-4f85-b70a-36e2b1fee467
# ╠═9a83bd91-4a32-4340-b0f1-2bbd114f2ee3
# ╠═66d0186f-5b39-404f-adbe-116191db4236
# ╠═d6bee536-f55d-45e0-b4fc-4c3d81fc8785
# ╠═5e6bc7d0-cc71-44f4-912e-7a8a9146c58e
# ╠═152e438d-c7c6-4e02-91d3-c21ae78d264f
# ╠═7751958e-9072-42d3-a0c8-b7cdedae617b
# ╠═b1ce85d8-9518-48e6-851d-8ac84f25c6ed
# ╠═b7688b63-963a-4094-913a-2de1df374b09
# ╠═a9086a0a-2226-4a20-8154-bfd19f9f2a67
# ╠═56bedfa5-82f2-4732-bacd-b920a4affe0e
# ╠═c24c426c-4247-408d-a222-b1dea19fd2c5
# ╠═58a78f9b-caaa-4978-a8a4-8e3d88958c5b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
