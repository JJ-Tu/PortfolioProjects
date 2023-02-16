Select *
From PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

-- Select initial data to start with

Select Location, Date, total_cases, new_cases, total_deaths, Population
From PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths in the U.S.
-- Shows likelihood of dying in the United States if you contract covid
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%United States%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of the population that has contracted covid
Select Location, Date, Population, total_cases, (total_cases/population)*100 as PopulationInfectionPercentage
From PortfolioProjects..CovidDeaths
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionPercentage
From PortfolioProjects..CovidDeaths
Group by Location, population
order by PopulationInfectionPercentage desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc



-- Breaking data down by Continent (instead of by Country)


-- Showing Continents with Highest Death Count

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to calculate on Partition By in previous query

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingCountVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingCountVaccinations/Population)*100
From PopVsVac


-- Using Temp Table to calculate on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingCountVaccinations numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingCountVaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

--sp_RefreshView PercentPopulationVaccinated

Select *
From PercentPopulationVaccinated