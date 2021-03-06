
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


-- Looking at countries with highest infection rate compared to population \/ used for Tableau

Select Location, Continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Population, Continent
order by PercentPopulationInfected desc

-- countries with highest infection rate per day used for Tableau

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
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

--Total deaths \/ used for Tableau

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Global Numbers \/

Select SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
--Group by date
order by 1,2

-- Total cases / total deaths \/ used for Tableau

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
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

-- Temp Table \/

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

-- view for 1st query \/

Create View DataonCovid as
Select Location, Continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Continent, Date, Total_cases, new_cases, total_deaths, Population
--order by 1,2


-- view for 2nd query \/

Create View Likelihoodofdying as
Select Location, Continent, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
Group by Location, Date, Total_cases, Continent, Total_deaths
--order by 1,2


-- view for 3rd query \/

Create View ContractedPercentage as
Select Location, Continent, Date, total_cases, Population, (Total_cases/Population)*100 as ContractedPercentage
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Date, total_cases, Continent, Population
--order by 1,2

--view for 4th query \/

Create View HighestInfection as
Select Location, Continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Population, Continent
--order by PercentPopulationInfected desc

--view for 5th query \/

Create view HighestDeathCount as
Select Location, Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Location, Continent
--order by TotalDeathCount desc

--view for 6th query \/

Create View DeathsbyContinent as
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--#Where Location like '%states%'
Where continent is not null
Group by Continent
--order by TotalDeathCount desc

-- view for 7th query \/

Create View Globalnumbersperday as
Select Date, SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
Group by date
--order by 1,2

--view for 8th query \/

Create View Globalnumbers as
Select SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where Continent is not null
--Group by date
--order by 1,2

--view for 9th query \/

Create View Vaccinationsperday as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as TotalNumberVaccinated --(TotalNumberVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3