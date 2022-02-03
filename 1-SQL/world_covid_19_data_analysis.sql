-- ANALYZE WORLD COVID 19 DATA

select * from covid19_data..covid19_data20220202

-- Total world population as at 31st Jan 2022

select 
round(population/1000000000 ,2) as world_population_in_billions
from covid19_data..covid19_data20220202 
where location = 'World' and date = '2022-01-31'


-- Total covid cases as at 31st Jan 2022

select 
round(total_cases/1000000 ,2) as total_cases_in_millions
from covid19_data..covid19_data20220202 
where location = 'World' and date = '2022-01-31'

-- World - Total positive cases / deaths / fully vaccinated / booster dose percentage as at 31st Jan 2022

select 
round((total_cases/population)*100 ,2 )as positive_case_percentage, 
round((total_deaths/total_cases)*100 ,2 ) as death_percentage,
round((people_fully_vaccinated/population)*100 ,2 ) as fully_vaccinated_percentage,
round((total_boosters/population)*100 ,2 ) as booster_dose_percentage
from covid19_data..covid19_data20220202 
where location = 'World' and date = '2022-01-31'


--Daily world covid data analysis

-- Population Vs positive_cases

with popVSpositive (date,population,new_cases,cummulative_daily_cases_count)
as
(
select FORMAT(date,'yyyy-MM-dd') as date,
population,new_cases,
sum(cast(new_cases as int)) over (Partition by location order by location, date) as cummulative_daily_cases_count
from covid19_data..covid19_data20220202
where location='World' and date < '2022-02-01'
)
select * from popVSpositive
order by date

-- Population Vs deaths

with PopVsDth (date,population,new_deaths,cummulative_daily_death_count)
as
(
select FORMAT(date,'yyyy-MM-dd') as date, population,new_deaths,
	sum(cast(new_deaths as int)) over (Partition by location order by location, date) as cummulative_daily_death_count
from covid19_data..covid19_data20220202
where location='World' and date < '2022-02-01'
)
select * from PopVsDth
order by date


-- Population Vs Vaccinations

with PopVsVac (date,population,new_vaccinations,cummulative_daily_vaccination_count)
as
(
select FORMAT(date,'yyyy-MM-dd') as date,population,new_vaccinations,
	sum(cast(new_vaccinations as int)) over (Partition by location order by location, date) as cummulative_daily_vaccination_count
from covid19_data..covid19_data20220202
where location='World' and date < '2022-02-01'
)
select * from PopVsVac
order by date


-- World Fully vaccinated data

select FORMAT(date,'yyyy-MM-dd') as date,population,people_fully_vaccinated
from covid19_data..covid19_data20220202
where location='World' and date < '2022-02-01'
order by date


-- All Figures

with PopVsAnalysis (date,population,
	new_cases,cummulative_daily_cases_count,
	new_deaths,cummulative_daily_death_count,
	new_vaccinations,cummulative_daily_vaccination_count)
as
(
select FORMAT(date,'yyyy-MM-dd') as date,population,
	new_cases,
	sum(cast(new_cases as int)) over (Partition by location order by location, date) as cummulative_daily_cases_count,
	new_deaths,
	sum(cast(new_deaths as int)) over (Partition by location order by location, date) as cummulative_daily_death_count,
	new_vaccinations,
	sum(cast(new_vaccinations as int)) over (Partition by location order by location, date) as cummulative_daily_vaccination_count
from covid19_data..covid19_data20220202
where location='World' and date < '2022-02-01'
)
select * from PopVsAnalysis
order by date

