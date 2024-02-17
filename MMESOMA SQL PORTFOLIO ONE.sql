select * from
my_portfolio..['covid death$']
order by 3,4;


select * from
my_portfolio..['Covid vaccinations$']
order by 3,4;


--SELECTING DATA TO USE
select Location, date, total_cases, new_cases, total_deaths, population
from my_portfolio..['covid death$']
order by 1,2;


--TOTAL CASES VS TOTAL DEATHS
select Location, date, total_cases, total_deaths,  (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage 
from my_portfolio..['covid death$']
order by 1,2;


--SEEING THE TOTAL PERCENTAGE FROM MY COUNTRY, NIGERIA
select Location, date, total_cases, total_deaths,  (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage 
from my_portfolio..['covid death$']
where location like '%nigeria%'
order by 1,2;


--TOTAL CASES VS POPULATION FOR NIGERIA
select Location, date, population, total_cases,   (cast(total_cases as float)/(population))*100 as percentagecases
from my_portfolio..['covid death$']
where location like '%nigeria%'
order by 1,2;


--TOTAL CASES VS POPULATION WORLD WIDE
select Location, date, population, total_cases,   (cast(total_cases as float)/(population))*100 as percentagecases
from my_portfolio..['covid death$']
order by 1,2;


--LOOK AT COUNTRIES WITH HIGHEST INFECTION RATE VS POPULATION
select Location, population, MAX(total_cases) AS Highestinfectioncount, MAX((cast(total_cases as float)/(population)))*100 as Highestpopulationinfection
from my_portfolio..['covid death$']
--where location like '%nigeria%'
group by location, population
order by Highestpopulationinfection desc;


--Countries with HIGHEST DEATH COUNT PER POPULATION
select Location, MAX(cast(total_deaths as int)) as totaldeathcount 
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is not null --This removes null continents.
group by location
order by totaldeathcount desc;


--LOOKING AT THE DATA BY CONTINENTS and HOUSEHOLD INCOME BASED OFF THE DATA
select location, MAX(cast(total_deaths as int)) as totaldeathcount 
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is null --This removes null continents.
group by location
order by totaldeathcount desc;


--BREAK DOWN BY CONTINENTS
select continent, MAX(cast(total_deaths as int)) as totaldeathcount 
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is not null 
group by continent
order by totaldeathcount desc;


--SHOWING CONTINENTS VS DEATH COUNT
select continent, MAX(cast(total_deaths as int)) as totaldeathcount 
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is not null 
group by continent
order by totaldeathcount desc;


--SHOWING INFECTION COUNT % OF CONTINENT AND HOUSEHOLD INCOME BASED OFF THE DATA
select location, population, MAX(total_cases) AS Highestinfectioncount, MAX((cast(total_cases as float)/(population)))*100 as HighestCONTINENTinfection
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is null 
group by location, population
order by HighestCONTINENTinfection desc;


--GLOBAL NUMBERS
select date, sum(new_cases), sum(cast(new_deaths as int)) --total_deaths,  (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage 
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2 desc;


--DEATH PERCENTAGE GLOBALLY
select --date
sum(new_cases) as totalsumedcases, sum(cast(new_deaths as float)) as totalnewdeaths,
sum(cast(new_deaths as float))/sum(new_cases)*100 AS GLOBALDEATHPERCENTAGE
from my_portfolio..['covid death$']
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2;

select * from 
my_portfolio..['Covid vaccinations$']


--JOINING THE TWO TABLES
select * from 
my_portfolio..['covid death$'] as dea
JOIN my_portfolio..['Covid vaccinations$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date;


--TOTAL NO. OF PEOPLE VS VACCINATIONS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from 
my_portfolio..['covid death$'] as dea
JOIN my_portfolio..['Covid vaccinations$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


--VACCINATIONS PER DAY
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_calc_vaccine
from 
my_portfolio..['covid death$'] as dea
JOIN my_portfolio..['Covid vaccinations$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


--TOTAL POPULATIONS VS VACCINATIONS WITH THE AID OF CTE
with popvsvac (continent, location, date, population, new_vaccinations, rolling_calc_vaccine) --no. of columns have to match the select from statement
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as rolling_calc_vaccine
from 
my_portfolio..['covid death$'] as dea
JOIN my_portfolio..['Covid vaccinations$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_calc_vaccine/population)*100
from popvsvac; --you must always attach the select all when doing a CTE


--TOTAL POPULATION VS ICU PATIENTS PER DAY
with popvsvac (continent, location, date, population, new_vaccinations, icu_patients, icu_calc_vaccine) --no. of columns have to match the select from statement
as
(
select dea.continent, dea.location, dea.date, dea.population, dea.icu_patients, vac.new_vaccinations,
SUM(convert(int,dea.icu_patients)) over (partition by dea.location order by dea.location, dea.date) 
as icu_calc_vaccine
from 
my_portfolio..['covid death$'] as dea
JOIN my_portfolio..['Covid vaccinations$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (icu_calc_vaccine/population)*100
from popvsvac;


--DOING A TEMP TABLE
DROP TABLE IF EXISTS #PERCENTAGEPOPULATIONVAC
CREATE TABLE #PERCENTAGEPOPULATIONVAC
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population bigint,
new_vaccinations numeric,
rolling_calc_vaccine numeric
)

insert into #PERCENTAGEPOPULATIONVAC
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as rolling_calc_vaccine
from 
my_portfolio..['covid death$'] as dea
JOIN my_portfolio..['Covid vaccinations$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rolling_calc_vaccine/population)*100 as temprollingcalcvaccine
from #PERCENTAGEPOPULATIONVAC; 

