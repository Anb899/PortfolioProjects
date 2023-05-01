/*
 * Covid 19 Data Exploration: Data up to 2021-04-30
 * Skills used: Joins, CTE's, Windows functions, Aggregate Functions, Creating Views, Converting Data Types
 */



SELECT *
FROM CovidDeaths cd 
where continent is not ''
order by 3, 4


UPDATE CovidDeaths 
Set new_cases_smoothed  = NULL 
WHERE new_cases_smoothed  = '' OR new_cases_smoothed  IS NULL 

UPDATE CovidDeaths 
Set total_deaths  = NULL 
WHERE total_deaths  = '' OR total_deaths  IS NULL 


-- Select the data that we are going to be starting with 
Select location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths cd 
Order by 1,2


-- Total cases vs Total deaths
-- Shows likelihood of dying if you had contracted covid in you country

Select location, date, total_cases, total_deaths, (total_deaths * 1.0 / total_cases)*100 as DeathPercentage
FROM CovidDeaths cd 
WHERE location like '%Canada%'
Order by 1,2

-- Total cases vs Population
-- Shows what percentage of the population infected with COVID

Select location, date, population, total_cases, total_deaths,(total_cases  * 1.0 / population)*100 as InfectedPercentage
FROM CovidDeaths cd 
--WHERE location like '%Canada%'
Order by 1,2


-- Countries with highest infection rate compared to Population.

SELECT location, population, Max(total_cases * 1.0) as HighestInfectionCount, Max((total_cases * 1.0 /population)) * 100 as PercentPopualtionInfected
FROM CovidDeaths cd 
Group by location, population 
Order by PercentPopualtionInfected desc

-- Countries with highest death count per Population

SELECT location, Max(total_deaths * 1.0) as TotalDeathCount
FROM CovidDeaths cd 
WHERE continent is not ''
Group by location 
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- continents with the highest deatch count per population

SELECT location, Max(total_deaths * 1.0) as TotalDeathCount
FROM CovidDeaths cd 
WHERE continent is ''
Group by location 
Order by continent desc


-- Global Numbers
 
Select date, SUM(new_cases)as New_Cases , SUM(new_deaths) as New_Deaths, SUM(new_deaths * 1.0)/SUM(new_cases * 1.0) * 100 as DeathPercentage
FROM CovidDeaths cd 
WHERE continent is ''
GROUP by date 
Order by 1,2


--Total pop vs Vaccinations
--Shows percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations	
, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER by cd.location, cd.date) as RollingVaccinationCount
FROM CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent <> '' --AND cd.location LIKE '%Canada%'
order by 2, 3

-- Use CTE (Common Table Expression) to perform calculation on PARTITION By in previous QUERY 

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
as
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations	
, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER by cd.location, cd.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population) * 100
FROM CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent <> ''

)

SELECT *, (RollingVaccinationCount/Population) * 100 as PercentageVaccinated
FROM PopvsVac



--Creating view to store data for later visulizations

--% of populations vaccinated with all locations

Create View PercentPopulationVaccinated as
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
as
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations	
, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER by cd.location, cd.date) as RollingVaccinationCount
FROM CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent <> ''

)

SELECT *, (RollingVaccinationCount/Population) * 100 as PercentageVaccinated
FROM PopvsVac


-- % of population vaccinated in Canada 
Create View PercentCanadaVaccinated as
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
as
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations	
, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER by cd.location, cd.date) as RollingVaccinationCount
FROM CovidDeaths cd 
join CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent <> '' AND cd.location LIKE '%Canada%'

)

SELECT *, (RollingVaccinationCount/Population) * 100 as PercentageVaccinated
FROM PopvsVac





