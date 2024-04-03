--Select Data that we are going to be using

SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccinations

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

--Looking at Total Cases vs Total Deaths
	--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
WHERE Location LIKE '%uss%'
Order By 1,2

-- Looking at Total cases vs Population
	--Shows what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 AS PercentPeopleWithCovid
From CovidDeaths
WHERE Location LIKE '%uss%'
Order By 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 
AS PercentPopulationInfected
From CovidDeaths
Group By Location, Population
Order By 1,2


--Showing countries with highest death count per population 
Select Location, Population, MAX(cast(total_deaths as int)) AS TotalDeathsCount, ROUND(MAX((total_deaths/population))*100, 2) 
AS PercentPopulationDied
From CovidDeaths
WHERE continent is not null
Group By Location, Population
Order By 3 DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
From CovidDeaths
WHERE continent is not null
Group By continent
Order By 2 DESC

--GLOBAL NUMBERS

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
WHERE continent is not null
--Group By date
Order By 1

--Looking at Total Vacciantion vs Population !!!!!!!!!!!!!!

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 AS 
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM PopvsVac



--Temp Table

CREATE TABLE  #PercentPopulationVacinated
(
	Continent nvarchar(255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM #PercentPopulationVacinated


--Creating View to store data for later visualizations


CREATE View PercentPopulationVacinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3