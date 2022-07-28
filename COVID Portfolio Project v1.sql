SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--Shows the likelihood of dying if you contract covid in each country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%' 
order by 1,2

--Looking at Total Cases vs Population
--Shows the percentage of the population that got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
--where location like '%states%' 
order by 1,2


-- Looking at countries with highest infection rate compare to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected Desc


--Showing the countries with the highest Death Count per population
--Because total_deaths was entered as nvarchar(255), we had to cast it as interger for the calculation to be accurate

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((cast(total_deaths as int)/population))*100 as PercentPopulationDeath 
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount Desc


-- LET'S BREAK THINGS DOWN BY Location

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount  
From PortfolioProject..CovidDeaths
--where location like '%states%'
--where continent is  not null
--where continent is null
Group by location
order by TotalDeathCount Desc


--BREAKING THINGS DOWN BY CONTINENT
--Showing the continent with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount  
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is  not null
Group by continent
order by TotalDeathCount Desc


-- Global Numbers

Select date, sum(new_cases) as SumofNewCases, max(total_cases) as MaxTotalCases
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

-- new_deaths was entered as nvarchar so we will cast it as int


Select date, sum(new_cases) as SumofNewCases,sum(cast(new_deaths as int)) as SumNewDeaths, max(total_cases) as MaxTotalCases
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

Select date, sum(new_cases) as SumofNewCases,sum(cast(new_deaths as int)) as SumNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

Select sum(new_cases) as SumofNewCases,sum(cast(new_deaths as int)) as SumNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--group by date
order by 1,2



Select * 
From PortfolioProject..CovidVaccinations

--JOIN TABLE COVIDDEATHS AND TABLE COVIDVACCINATION

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date


--NOW LOOKING AT TOTAL POPULATION VS VACCINATIONS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Above code showed that we couldn't use RollingPeopleVaccinated that we just created in our calculation, so we will do a temp table

-- USING CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--If you change anything in the above code and run it again, you get an error because tem-table executes once.
--To get around this constraint
--Add "DROP TABLE IF EXISTS" at the beginning of the code, so that it will drop and re-create everytime you run it.
-- See below

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--Querying off the View

Select *
From PercentPopulationVaccinated