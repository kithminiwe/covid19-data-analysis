-- ANALYZE COUNTRY WISE COVID 19 DATA

-- Total cases reported in each country as at 31st Jan

select 
location,continent,sum(new_cases) as total_reported_cases
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent
order by 3

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- Countries with no covid positive cases reported

select 
location,continent,population
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent,population
having sum(new_cases) is null


with notaffected (location,continent,population)
as
(
select 
location,continent,population
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent,population
having sum(new_cases) is null
)
select STRING_AGG(location,',') from notaffected;

-- Guernsey,Jersey,Nauru,Niue,Northern Cyprus,Pitcairn,Sint Maarten (Dutch part),Tokelau,Turkmenistan,Tuvalu

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- Mostly affected countries in the world

select top 20
location,continent,sum(new_cases) as total_reported_cases
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent
order by 3 desc

-- Countries reported with more than 10M postive cases

select
location,continent,sum(new_cases) as total_reported_cases, round(sum(new_cases)/1000000,0) as total_reported_cases_to_nearrest_million
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent
having round(sum(new_cases)/1000000,0) >=10
order by 3 desc


with notaffected (location,continent,total_reported_cases)
as
(
select top 20
location,continent,sum(new_cases) as total_reported_cases
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent
order by 3 desc
)
select string_agg(location,',') from notaffected;

-- United States,India,Brazil,France,United Kingdom,Russia,Italy,Turkey,Germany,Spain,
-- Argentina,Iran,Colombia,Mexico,Poland,Netherlands,Indonesia,Ukraine,South Africa,Philippines


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- Daily Cumualtive count

-- Population Vs positive_cases

with popVSpositive (continent,location,date,population,new_cases,cummulative_daily_cases_count)
as
(
select continent,location, FORMAT(date,'yyyy-MM-dd') as date, population,new_cases,
	sum(cast(new_cases as int)) over (Partition by location order by location, date) as cummulative_daily_cases_count
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
)
select * from popVSpositive;


-- Population Vs deaths

with PopVsDth (continent,location,date,population,new_deaths,cummulative_daily_death_count)
as
(
select continent,location,FORMAT(date,'yyyy-MM-dd') as date, population,new_deaths,
	sum(cast(new_deaths as int)) over (Partition by location order by location, date) as cummulative_daily_death_count
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
)
select * from PopVsDth;


-- Population Vs Vaccinations

with PopVsVac (continent,location,date,population,new_vaccinations,cummulative_daily_vaccination_count)
as
(
select continent,location,FORMAT(date,'yyyy-MM-dd') as date,population,new_vaccinations,
	sum(cast(new_vaccinations as int)) over (Partition by location order by location, date) as cummulative_daily_vaccination_count
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
)
select * from PopVsVac;


-- All Figures

with PopVsAnalysis (continent,location,date,population,
	new_cases,cummulative_daily_cases_count,
	new_deaths,cummulative_daily_death_count,
	new_vaccinations,cummulative_daily_vaccination_count)
as
(
select continent,location,FORMAT(date,'yyyy-MM-dd') as date,population,
	new_cases,
	sum(cast(new_cases as int)) over (Partition by location order by location, date) as cummulative_daily_cases_count,
	new_deaths,
	sum(cast(new_deaths as int)) over (Partition by location order by location, date) as cummulative_daily_death_count,
	new_vaccinations,
	sum(cast(new_vaccinations as int)) over (Partition by location order by location, date) as cummulative_daily_vaccination_count
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
)
select * from PopVsAnalysis;


-- Country wise -Total positive cases / deaths / fully vaccinated / booster dose percentage as at 31st Jan 2022

select 
location,continent,MAX(population),
round((MAX(total_cases)/MAX(population))*100 ,2 )as positive_case_percentage, 
round((MAX(total_deaths)/MAX(total_cases))*100 ,2 ) as death_percentage,
round((MAX(people_fully_vaccinated)/MAX(population))*100 ,2 ) as fully_vaccinated_percentage,
round((MAX(total_boosters)/MAX(population))*100 ,2 ) as booster_dose_percentage
from covid19_data..covid19_data20220202 
where continent is not null and date < '2022-02-01'
group by location,continent


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- Per day analysis

-- New cases per day

select FORMAT(date,'yyyy-MM-dd') as date,
sum(population) as total_population,
sum(cast(new_cases as int)) as total_daily_cases
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
group by date
order by date

-- New cases per day Vs new_tests per day

select 
FORMAT(date,'yyyy-MM-dd') as date,
sum(population) as total_population,
sum(cast(new_tests as int)) as total_daily_tests,
sum(cast(new_cases as int)) as total_daily_cases
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
group by date
order by date

-- New vaccinations per day

select FORMAT(date,'yyyy-MM-dd') as date,
sum(population) as total_population,
sum(cast(new_vaccinations as int)) as total_daily_vaccination
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
group by date
order by date

-- New deaths per day

select FORMAT(date,'yyyy-MM-dd') as date,
sum(population) as total_population,
sum(cast(new_deaths as int)) as total_daily_deaths
from covid19_data..covid19_data20220202
where continent is not null and date < '2022-02-01'
group by date
order by date


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


-- Likelihood of dying if a perdon got covid positive in a particular country

select location, MAX(total_cases) as total_reported_cases,MAX(cast(total_deaths as int)) total_deaths, 
round((MAX(total_deaths)/MAX(total_cases))*100,2) as death_percentage
from covid19_data..covid19_data20220202
where location = 'United states'
group by location


-- 10 countries with the highest likelihood of dying due to covid

select top 10
location, MAX(total_cases) as total_reported_cases,MAX(cast(total_deaths as int)) total_deaths, 
round((MAX(total_deaths)/MAX(total_cases))*100,2) as death_percentage
from covid19_data..covid19_data20220202
where continent is not null
group by location
order by death_percentage desc

-- 10 countries with the highest likelihood of dying due to covid
-- considering total_cases > 100,000

select top 20
location, MAX(total_cases) as total_reported_cases,MAX(cast(total_deaths as int)) total_deaths, 
round((MAX(total_deaths)/MAX(total_cases))*100,2) as death_percentage
from covid19_data..covid19_data20220202
where continent is not null
group by location
having MAX(total_cases) > 100000
order by death_percentage desc


select top 10
location, MAX(total_cases) as total_cases,MAX(cast(total_deaths as int)) total_deaths, 
round((MAX(total_deaths)/MAX(total_cases))*100,2) as death_percentage
from covid19_data..covid19_data20220202
where continent is not null
group by location
order by 2,4 desc
