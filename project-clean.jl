### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 026772f0-13c1-4cd6-8dda-1bd79af4abc8
# Installing Packages 
begin
	using Pkg
	using JuMP, Clp
	Pkg.add("Statistics")
	import Statistics
end

# ╔═╡ b81709c0-5c1c-11ec-245b-d7b4e0f911eb
students = [(name = "Anna Cliche", cornell_id = "amc527"),
			(name = "Cormac Mahoney", cornell_id = "cam495"),
			(name = "Demola Ogunnaike", cornell_id = "dko22")]

# ╔═╡ 600ef85e-66c5-4a82-a419-782317cacfb5
md"""
#### Defining Global Variables
"""

# ╔═╡ 53978ef0-af78-4933-af68-8621d6ef0842
begin 
	totalArea = 1700582400; #ft^2
	timeHorizon = 50; #years

	#quartiles:  1 	2 	3 	4
	HVIweights = [0.1 0.2 0.3 0.4];
	percentArea = [.20 .23 .27 .30];
	#tempVar = [-1.265741024 -0.436508545 0.308562915 0.904330533]; #the degree deviation from the mean temp
	tempVar2 = [-0.041853195 -0.014433661 0.010202991 0.029902738]; #the % deviation from the mean temp
	# tempVar = oldTemp.*tempVar2;
	
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
end 

# ╔═╡ 3d810efd-0eda-4d82-a082-2f056d8544e4
md"""
#### Defining Available Areas per Quadrant
"""

# ╔═╡ 0ffa59a4-3f9b-4f8f-ac6b-7b757ddad487
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

# ╔═╡ c064697b-e3e8-4d6c-91bd-31e3fb44d4b5
md"""

#### Defining Model 

#### Objecitve: Minimize Cost  
Find the minimum cost needed to install and maintain technologies to reduce the Urban Heat Island effect given an original temperature and a desired minimum temperature change. 

#### Decision Variables
- ``X_{ij}`` represents the area of quadrant i that is renovated to method j (in mi)
- ``socialConstraint_{ij}`` represents the social benefit caused by the use of method of j over the area of quadrant i


#### Other Variables of Interest
- ``quadTempChange1`` represents the temperature change in quadrant 1 caused by treatment (in degrees Celsius)
- ``quadTempChange2`` represents the temperature change in quadrant 2 caused by treatment (in degrees Celsius)
- ``quadTempChange3`` represents the temperature change in quadrant 3 caused by treatment (in degrees Celsius)
- ``quadTempChange4`` represents the temperature change in quadrant 4 caused by treatment (in degrees Celsius)
- ``temperatureChange`` represents the overall temperature change due treatment (in degrees Celsius)

#### Constraints 
- The overall temperature change from the model must exceed or be equal to the minimum temperature change 
- The temperature change in each quadrant must be less than or equal to the idealized temperature (oldTemp - minTempChange)
- The treatment applied to each area of the quadrant that is renovated to method j must not exceed the available area for that treatment
- The social constraint for each area of the quadrant that is renovated to method j must be equal to the treatment allotted for that area multiplied by the social impact of that treatment method. 
- The net social benefit impact for each quadrant, defined as the sum of the social benefits for a quadrant divided by the area of quadrant that is renovated to method j, must exceed 0.25 

"""

# ╔═╡ c2487fe0-2ef9-4efb-a246-c9585bfb6c4b
function optimizeUHIModel(oldTemp,minTempChange)
	
	# Declaring Model 
	UHImodel = Model(Clp.Optimizer)
	
	# Defining Variables for Model
	@variable(UHImodel, 0 <= X[i=1:4, j=1:6]) #Decision Variables
	@variable(UHImodel, socialConstraint[i=1:4, j=1:6])
	
	# Objective: Total Cost Function 
	@objective(UHImodel, Min, begin 						
		(X[1,1]+X[2,1]+X[3,1]+X[4,1])*(totalCost[1]) + 
		(X[1,2]+X[2,2]+X[3,2]+X[4,2])*(totalCost[2]) + 
		(X[1,3]+X[2,3]+X[3,3]+X[4,3])*(totalCost[3]) + 
		(X[1,4]+X[2,4]+X[3,4]+X[4,4])*(totalCost[4]) + 
		(X[1,5]+X[2,5]+X[3,5]+X[4,5])*(totalCost[5]) + 
		(X[1,6]+X[2,6]+X[3,6]+X[4,6])*(totalCost[6]) 
	end)
	
	# Defining Temperature Changes 
	tempVar = oldTemp.*tempVar2;
	quadTempChange1 = 
X[1,1]*deltaT[1]/availableArea[1,1] + X[1,2]*deltaT[2]/availableArea[1,2] + 	X[1,3]*deltaT[3]/availableArea[1,3] + X[1,4]*deltaT[4]/availableArea[1,4] + X[1,5]*deltaT[5]/availableArea[1,5] + X[1,6]*deltaT[6]/availableArea[1,6];
quadTemp1 = oldTemp+tempVar[1]+quadTempChange1
	
quadTempChange2 = 
X[2,1]*deltaT[1]/availableArea[2,1] + X[2,2]*deltaT[2]/availableArea[2,2] + 	X[2,3]*deltaT[3]/availableArea[2,3] + X[2,4]*deltaT[4]/availableArea[2,4] + X[2,5]*deltaT[5]/availableArea[2,5] + X[2,6]*deltaT[6]/availableArea[2,6];
quadTemp2 = oldTemp+tempVar[2]+quadTempChange2
	
quadTempChange3 = 
X[3,1]*deltaT[1]/availableArea[3,1] + X[3,2]*deltaT[2]/availableArea[3,2] + 	X[3,3]*deltaT[3]/availableArea[3,3] + X[3,4]*deltaT[4]/availableArea[3,4] + X[3,5]*deltaT[5]/availableArea[3,5] + X[3,6]*deltaT[6]/availableArea[3,6];
quadTemp3 = oldTemp+tempVar[3]+quadTempChange3
	
quadTempChange4 = 
X[4,1]*deltaT[1]/availableArea[4,1] + X[4,2]*deltaT[2]/availableArea[4,2] + 	X[4,3]*deltaT[3]/availableArea[4,3] + X[4,4]*deltaT[4]/availableArea[4,4] + X[4,5]*deltaT[5]/availableArea[4,5] + X[4,6]*deltaT[6]/availableArea[4,6];
quadTemp4 = oldTemp+tempVar[4]+quadTempChange4
	
	temperatureChange = oldTemp - (quadrantArea[1]*quadTemp1 + quadrantArea[2]*quadTemp2 + quadrantArea[3]*quadTemp3 +quadrantArea[4]*quadTemp4)/totalArea;
	
	# Defining Constraints 
	@constraint(UHImodel, c, temperatureChange >= minTempChange)
	@constraint(UHImodel, tempChange1, quadTemp1 <= oldTemp - minTempChange)
	@constraint(UHImodel, tempChange2, quadTemp2 <= oldTemp - minTempChange)
	@constraint(UHImodel, tempChange3, quadTemp3 <= oldTemp - minTempChange)
	@constraint(UHImodel, tempChange4 ,quadTemp4 <= oldTemp - minTempChange)
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
	for i=1:4
		for j=1:6
			@constraint(UHImodel, socialConstraint[i,j] == 		     	X[i,j]*methodWeights[j])
		end 
		@constraint(UHImodel, sum(socialConstraint[[i],:]) >= (0.25)*sum(X[[i],:]))
	end
	
	# Optimizing Model
	optimize!(UHImodel)
	
	# Returns Model 
	return [UHImodel, X,temperatureChange,quadTemp1,quadTemp2,quadTemp3,quadTemp4,quadTempChange1,quadTempChange2,quadTempChange3,quadTempChange4]
	
end 

# ╔═╡ e6be1381-0c80-4680-9203-1656999273c7
md"""
#### Model Analysis Helper Functions
The functions, socialBenefitAnalysis and impactHVI, evaluate the social Benefit and the impact on the Heat Vulnerability Index based on the model solution. The higher the HVI value and the socialBenefit value, the better. 
"""

# ╔═╡ 5dcb64d1-40e2-4a07-b35d-88cf14246e3b
# Social Benefits: The greater the value, the more social benefit
function socialBenefitAnalysis(X)
	socialBenefit = zeros(1,4)
	socialBenefitNORMALIZED = zeros(1,4) 
	for i=1:4
		socialBenefit[i] = value.(sum(X[[i],:].*methodWeights[[1],:]'))
	end 
	totalSocialBenefit = sum(socialBenefit)
	for i = 1:4
		socialBenefitNORMALIZED[i] = socialBenefit[i]/totalSocialBenefit
	end 
	return [socialBenefit, socialBenefitNORMALIZED]; 
end 

# ╔═╡ d99db411-71d3-4f31-84c2-3a247c3d34a3
# HVI Impact: The higher HVI should result in a higher impact 
function impactHVI(quadTempChange)
	impactHVI = zeros(1,4)
	for i=1:4
		impactHVI[i] = value.(HVIweights[i]*quadTempChange[i])
		impactHVI[i] = abs(impactHVI[i])
	end 
	totalImpactHVI = sum(impactHVI)
	for i = 1:4
		impactHVI[i] = impactHVI[i]/totalImpactHVI
	end 
	return [totalImpactHVI,impactHVI]; 
end 

# ╔═╡ 49e2884a-c1ca-43cb-9c15-c651a0155125
md"""
#### Running Optimization Multiple Times: getData Function  
Adds each optimization iteration of the model into modelDictionary, given an original temperature, oldTemp and a minimum temperature change, minTempChange
"""

# ╔═╡ 7376f003-edfb-46f3-8794-009dccbc3f69
# Array to store iterations of the model 
modelDictionary = []

# ╔═╡ 6b6588b2-b1b9-4057-ae51-b38a907a2af2
md"""
#### Latex Formulation of the Model  
"""

# ╔═╡ dd797a9c-02fb-4129-9b90-46bbf09fa927
# Helper Function 
function showLatex(model)
	latex_formulation(model); 
end 

# ╔═╡ 7dbd5761-a4b9-47ba-a9c2-13f0f73e0166
# Adds each optimization iteration of the model into modelDictionary, given an original temperature, oldTemp and a minimum temperature change, minTempChange
# Takes in three parameters:  
# - oldTemp: initial temperature (number)
# - minTempChange: temperature change (number)
# - displayLatex: boolean; displays Latex if set to true 

function getData(oldTemp,minTempChange,displayLatex)
	modelData = optimizeUHIModel(oldTemp,minTempChange)
	UHImodel = modelData[1]
	X = modelData[2]
	temperatureChange = modelData[3]
	quadTemp = [modelData[4],modelData[5], modelData[6], modelData[7]]
	quadTempChange = [modelData[8],modelData[9], modelData[10], modelData[11]]
	push!(modelDictionary,[Dict("Old Temp" => oldTemp, "Minimum Temp Change" => minTempChange,"Objective" => objective_value(UHImodel), "X" => value.(X), "Temperature Change" => value.(temperatureChange), "Quad Temp" =>([value.(quadTemp[1]),value.(quadTemp[2]),value.(quadTemp[3]),value.(quadTemp[4])]), "Quad Temp Change" =>([value.(quadTempChange[1]),value.(quadTempChange[2]),value.(quadTempChange[3]),value.(quadTempChange[4])]), "Social Benefit"=>(socialBenefitAnalysis(X)), "Impact HVI" => impactHVI(quadTempChange))
	])
	if displayLatex == true
		showLatex(UHImodel); 
	end 
end

# ╔═╡ 45b549e1-e32b-43c0-bf2d-5bf6c50aaa99
getData(30.55,0.5,true)

# ╔═╡ 04f96896-39ec-48ce-ad9f-ce7d5bcd39b0
md"""
#### modelDictionary Documentation

General Form: modelDictionary[1][1][key]
- first index represents the index of modelDictionary 
- second index is always 1 
- third index is a key (see valid key values below)

To empty the Dictionary, run the resetDictionary function below
"""

# ╔═╡ 302b7089-afba-43e8-8190-b7af6876aeab
# Accessing modelDictionary iterations
# modelDictionary[1][1][key]
# 	where the first index represents the index of modelDictionary 
#   second index is always 1 
#   third index is a key (see valid key values above)

# ╔═╡ 3354f9db-cf87-4809-8872-d19bf8118abc
keys(modelDictionary[1][1])

# ╔═╡ 218332e1-ebdc-4fe5-b09b-494666c5b15a
function resetDictionary()
	while length(modelDictionary) > 0 
		pop!(modelDictionary)
	end 
end 

# ╔═╡ 65ad7161-1e58-4605-85fa-decbe3f67b2a
resetDictionary()

# ╔═╡ ed5946fc-8680-4b35-8b8a-95337077e0c8
md"""
#### Stochastic Analysis of Model  
By utilzing the Law of Large Numbers, N ~= 10,000, we hope to find an ideal cost solution for the average temperature scenario and the extreme temperature scenario. 
"""

# ╔═╡ 9fb9606f-7e91-483f-a8db-3c54c666484a
# Creates a stochastic dataset for 1000 random temperature values ranging from 30.55 degrees Celsius (average) to 36.67 degrees Celsius (extreme)
function generateStochastic()
	for i=1:10000
		getData(rand(3055:3667)/100,0.5,false)
	end 
end 

# ╔═╡ 1842c0a1-5545-47aa-a386-bf568e80adb3
# Finds the model Dictionary that matches with the Stochastic Average
function getMatching()
	generateStochastic()
	sum = 0 
	for i=1:10000
		sum += modelDictionary[i][1]["Objective"]
	end 
	for i=1:1000
		if abs(round(sum/10000)-modelDictionary[i][1]["Objective"]) <= 1*10^4
			# return i
			return modelDictionary[i][1]
		end 
	end 
end 

# ╔═╡ 485fd192-015a-4569-b0d4-36637e363b04
stochasticMatch = getMatching()

# ╔═╡ 6684158a-8f5b-4351-9cf8-fd8ef1188653
# Returns the Stochastic Social Benefits given model data
function stochasticSocialBenefits()
	socialBenefits = 0 
	for i=1:4
		socialBenefits += stochasticMatch["Social Benefit"][1][i]
	end 
	return socialBenefits
end  

# ╔═╡ 28a361c8-995b-4e2e-adba-1d869c1b387b
"Stochastic Objective: " * string(stochasticMatch["Objective"])

# ╔═╡ 36e4c970-8588-467a-b699-e0cc7b84bd58
"Stochastic Social Benefits: " * string(stochasticSocialBenefits())

# ╔═╡ 0d1c52d2-d0e3-4621-8f88-938b57b8ed77
"Stochastic HVI: " * string(stochasticMatch["Impact HVI"][1])

# ╔═╡ f2e32251-4e47-494a-b955-b08451fcab36
md"""
#### Acknowledgements & Sources   
- [Julia Documentation](https://docs.julialang.org/en/v1/)
- [Project Supplemental Doc](https://docs.google.com/document/d/1c8rLQg0OSOY7hnIkabI2GMhM1b-2YHsyMdj2sa8YkEU/edit)
- Special Thanks to Professor Lindsay Anderson, Professor Vivek Srikrishnan, and Teaching Assistant Vivienne Liu for instructing BEE 4750/5750: Environmental Systems Analysis in Fall 2021 and providing guidance and assistance in developing this project
"""

# ╔═╡ Cell order:
# ╟─b81709c0-5c1c-11ec-245b-d7b4e0f911eb
# ╠═026772f0-13c1-4cd6-8dda-1bd79af4abc8
# ╟─600ef85e-66c5-4a82-a419-782317cacfb5
# ╠═53978ef0-af78-4933-af68-8621d6ef0842
# ╟─3d810efd-0eda-4d82-a082-2f056d8544e4
# ╠═0ffa59a4-3f9b-4f8f-ac6b-7b757ddad487
# ╟─c064697b-e3e8-4d6c-91bd-31e3fb44d4b5
# ╠═c2487fe0-2ef9-4efb-a246-c9585bfb6c4b
# ╟─e6be1381-0c80-4680-9203-1656999273c7
# ╠═5dcb64d1-40e2-4a07-b35d-88cf14246e3b
# ╠═d99db411-71d3-4f31-84c2-3a247c3d34a3
# ╟─49e2884a-c1ca-43cb-9c15-c651a0155125
# ╠═7376f003-edfb-46f3-8794-009dccbc3f69
# ╠═7dbd5761-a4b9-47ba-a9c2-13f0f73e0166
# ╟─6b6588b2-b1b9-4057-ae51-b38a907a2af2
# ╟─dd797a9c-02fb-4129-9b90-46bbf09fa927
# ╟─45b549e1-e32b-43c0-bf2d-5bf6c50aaa99
# ╟─04f96896-39ec-48ce-ad9f-ce7d5bcd39b0
# ╟─302b7089-afba-43e8-8190-b7af6876aeab
# ╟─3354f9db-cf87-4809-8872-d19bf8118abc
# ╠═218332e1-ebdc-4fe5-b09b-494666c5b15a
# ╠═65ad7161-1e58-4605-85fa-decbe3f67b2a
# ╟─ed5946fc-8680-4b35-8b8a-95337077e0c8
# ╠═9fb9606f-7e91-483f-a8db-3c54c666484a
# ╠═1842c0a1-5545-47aa-a386-bf568e80adb3
# ╠═485fd192-015a-4569-b0d4-36637e363b04
# ╠═6684158a-8f5b-4351-9cf8-fd8ef1188653
# ╟─28a361c8-995b-4e2e-adba-1d869c1b387b
# ╟─36e4c970-8588-467a-b699-e0cc7b84bd58
# ╟─0d1c52d2-d0e3-4621-8f88-938b57b8ed77
# ╟─f2e32251-4e47-494a-b955-b08451fcab36
