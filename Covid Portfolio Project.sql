Select*
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3, 4

--Select*
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
order by 1, 2

--Looking at countries with highest infection rate compared to population

Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location,population
order by PercentagePopulationInfected desc

--Showing the countries with Highest Death Count per Population

Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent



--Showing the continents with the highest death count per population

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1, 2


--Looking at Total Population vs Vccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,SUM(CONVERT(int,vaccination.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ deaths
Join PortfolioProject..CovidVaccinations$ vaccination
on deaths.location=vaccination.location
and deaths.date=vaccination.date
Where deaths.continent is not null
--Order by 2, 3

--Use CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,SUM(CONVERT(int,vaccination.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ deaths
Join PortfolioProject..CovidVaccinations$ vaccination
on deaths.location=vaccination.location
and deaths.date=vaccination.date
Where deaths.continent is not null
--Order by 2, 3
)
Select*,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,SUM(CONVERT(int,vaccination.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ deaths
Join PortfolioProject..CovidVaccinations$ vaccination
on deaths.location=vaccination.location
and deaths.date=vaccination.date
--Where deaths.continent is not null
--Order by 2, 3

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,SUM(CONVERT(int,vaccination.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ deaths
Join PortfolioProject..CovidVaccinations$ vaccination
on deaths.location=vaccination.location
and deaths.date=vaccination.date
Where deaths.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated