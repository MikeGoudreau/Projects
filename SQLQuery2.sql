
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVac
--order by 3,4

-- ^^^
-- Select Data that we are going to be using

-- Querys \/


Select Location, Continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Continent, Date, Total_cases, new_cases, total_deaths, Population
order by 1,2


-- Looking at Total cases vs Total deaths ^
-- Shows likelihood of dying if you contract covid in your country \/


Select Location, Continent, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
Group by Location, Date, Total_cases, Continent, Total_deaths
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted covid \/

Select Location, Continent, Date, total_cases, Population, (Total_cases/Population)*100 as ContractedPercentage
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Date, total_cases, Continent, Population
order by 1,2


-- Looking at countries with highest infection rate compared to population \/

Select Location, Continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Population, Continent
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population \/

Select Location, Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Continent
order by TotalDeathCount desc


-- By Continent \/

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Continent
order by TotalDeathCount desc



-- Global Numbers by date \/

Select Date, SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
Group by date
order by 1,2


--Global Numbers \/

Select SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
--Group by date
order by 1,2




-- Total population vs Vaccinations per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as TotalNumberVaccinated --(TotalNumberVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE  \/

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, TotalNumberVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as TotalNumberVaccinated --(TotalNumberVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (TotalNumberVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalNumberVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as TotalNumberVaccinated --(TotalNumberVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (TotalNumberVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as TotalNumberVaccinated --(TotalNumberVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
