
--select * 
--from PorrfolioProject..CovidVaccination$
--order by 3, 4

--Select data we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PorrfolioProject..CovidDeaths$
where continent is not null
order by location, date

--Total cases vs Total Deaths
--Likelihood of dying if you get covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorrfolioProject..CovidDeaths$
where location='Azerbaijan' and continent is not null
order by location, date


--  Total cases vs Population
-- The percentage of population who got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PorrfolioProject..CovidDeaths$
where location='Azerbaijan' and continent is not null
order by location, date

-- Coutries with Highest Infection rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PorrfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Highest Death count per Continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PorrfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PorrfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
select  date, sum(new_cases) as TotalCase, sum(cast(new_deaths as int)) as TotalDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorrfolioProject..CovidDeaths$
where continent is not null
group by date
order by date


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeoplevaccination
from CovidDeaths$ dea
Join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
Select *,(RollingPeopleVaccinated/Population)
From #PercentPopulationVaccinated


--Create view for later visualization
Create View #PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeoplevaccination
from CovidDeaths$ dea
Join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null











