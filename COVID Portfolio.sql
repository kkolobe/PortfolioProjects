Select *
From PortfoliPro..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfoliPro..CovidVaccinations
--order by 3,4

--Select the data that we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfoliPro..CovidDeaths  
order by 1,2

--looking at the Total Cases vs Total Deaths 
--likelyhood of dying if you contracted Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfoliPro..CovidDeaths 
where Location like '%south africa%'
order by 1,2

--looking at the Total cases vs Population
--Showing percentage of population that got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PopPercentage
From PortfoliPro..CovidDeaths 
--where Location like '%south africa%'
order by 1,2

--looking at countries with highest infection rates to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfoliPro..CovidDeaths 
--where Location like '%south africa%'
Group by Location, population 
order by PercentagePopulationInfected desc;

--Show countries with Highest Death count per  population

Select Location , MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfoliPro..CovidDeaths
where continent is not null
Group by Location 
Order by TotalDeathCount desc;

--let;s break it down by continent
--Showing Continents with Highest Death Counts per population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfoliPro..CovidDeaths
--where Location like '%south africa%'
where continent is not null 
group by continent
order by TotalDeathCount desc;

--GLOBAL NUMBERS

Select  SUM(total_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfoliPro..CovidDeaths 
--where Location like '%south africa%'
WHERE continent is not null 
--group by date
order by 1,2

--We'll look at the total population vs vaccination


WITH PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccinatedPeople)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinatedPeople
--(CumulativeVaccinatedPeople/population)--USE CTE
FROM PortfoliPro..CovidDeaths dea
Join PortfoliPro..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
SELECT *, (CumulativeVaccinatedPeople/population)*100 AS PercentageCumVacPeople
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopVacc
Create table #PercentPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccinatedPeople numeric
)

Insert into #PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinatedPeople
--(CumulativeVaccinatedPeople/population)--USE CTE
FROM PortfoliPro..CovidDeaths dea
Join PortfoliPro..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

SELECT *, (CumulativeVaccinatedPeople/population)*100 AS PercentageCumVacPeople
FROM #PercentPopVacc

--Creating view to store data for later visualisations

Create View PopvsVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinatedPeople
--(CumulativeVaccinatedPeople/population)--USE CTE
FROM PortfoliPro..CovidDeaths dea
Join PortfoliPro..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PopvsVac
