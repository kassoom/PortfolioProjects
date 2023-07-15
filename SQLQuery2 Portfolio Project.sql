
select *
from PortfolioProject..CovidDeath
order by 3,4

select *
from PortfolioProject..CovidVacination
order by 3,4


--select data that we are going to use for the analysis

select location, date, total_cases, total_deaths
from PortfolioProject..CovidDeath
order by 1,2

--Analysing the total deaths vs the total cases

select location, date, total_cases, total_deaths , Convert(DECIMAL(15,3),total_deaths) / Convert(DECIMAL(15,3),total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%emirates%'
order by 1,2

--Analysing the population vs the total cases
--Shows the percentage of population that got the virus

select location, date, population ,total_cases,  Convert(DECIMAL(15,3),total_cases) / Convert(DECIMAL(15,3),population)*100 as CasePercentage
from PortfolioProject..CovidDeath
where location like '%emirates%'
order by 1,2

--Analysing the highest percentage of population that got the virus

select location, population ,MAX(CONVERT(Decimal(15,3), total_cases)) as HighesVirusInfectionCount,  MAX(Convert(DECIMAL(15,3),total_cases) / Convert(DECIMAL(15,3),population)*100) as HighestCasePercentage
from PortfolioProject..CovidDeath
Group by location, population
--where location like '%emirates%'
order by 4 desc

--Analysing the highest death count by country

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
Group by location
--where location like '%emirates%'
order by 2 desc

--Will do it by the continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null
Group by location
--where location like '%emirates%'
order by 2 desc

--Global Analysis

select date, SUM(cast(total_cases as int)) as TotalCases, SUM(cast(total_deaths as int)) as TotalDeaths , SUM(cast(total_deaths as float))/SUM(cast(total_cases as int))*100 as DeathPerc
from PortfolioProject..CovidDeath
where continent is not null
Group by date
--where location like '%emirates%'
order by date

-- Joining two tables

select *
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Comparing Population to Total Vaccination

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM	(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as SumOfVaccination
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE
with POPvsVAC (continent,location,date,population,new_vaccinations,SumOfVaccination)
as 
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM	(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as SumOfVaccination
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (SumOfVaccination/population)*100 as PercentageOfPPL_Vaccinated
from POPvsVAC

--Creating TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumOfVaccination numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM	(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as SumOfVaccination
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (SumOfVaccination/population)*100 as PercentageOfPPL_Vaccinated
from #PercentPopulationVaccinated

--Creating Views for Visualization

create view PopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM	(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as SumOfVaccination
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PopulationVaccinated