SELECT *
FROM coviddeaths
WHERE continent is NULL
ORDER BY 3,4;

SELECT location, date,total_cases,new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
ORDER BY 1,2;

-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopPercentage
FROM coviddeaths
WHERE location LIKE '%russia%'
ORDER BY 1,2;

-- Countries with highest Infection Rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercetagePopulationInfected
FROM coviddeaths
-- WHERE location LIKE '%russia%'
GROUP BY location, population
ORDER BY 1,2;

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM coviddeaths 
WHERE location NOT IN ('Europe',
'North America',
'European Union',
'South America',
'Africa',
'Oceania')
GROUP BY location
ORDER BY TotalDeathCount desc;

-- group by continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM coviddeaths 
WHERE location NOT IN ('Europe',
'North America',
'European Union',
'South America',
'Africa',
'Oceania')
GROUP BY continent
ORDER BY TotalDeathCount desc
;

-- global numbers

SELECT date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as float)) as Total_Deaths, sum(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location NOT IN ('Europe',
'North America',
'European Union',
'South America',
'Africa',
'Oceania')
GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as float)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS  RollingVaccinations
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
and d.date = v.date
WHERE d.location NOT IN ('Europe',
'North America',
'European Union',
'South America',
'Africa',
'Oceania')
ORDER BY 2, 3
;

-- CTE

WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingVaccinations)
AS 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as float)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS  RollingVaccinations
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
and d.date = v.date
WHERE d.location NOT IN ('Europe',
'North America',
'European Union',
'South America',
'Africa',
'Oceania')
ORDER BY 2, 3
)
SELECT *, RollingVaccinations/Population*100
FROM PopvsVac;

-- TEMP Table

DROP TABLE IF exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations varchar(255),
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as float)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS  RollingVaccinations
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
and d.date = v.date
WHERE d.location NOT IN ('Europe', 'North America', 'European Union', 'South America', 'Africa', 'Oceania')
ORDER BY 2, 3
;
SELECT *, RollingPeopleVaccinated/Population*100
FROM PercentPopulationVaccinated;

-- creating views 

CREATE VIEW PercentPopulationVaccinatedView
 AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as float)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS  RollingVaccinations
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
and d.date = v.date
WHERE d.location NOT IN ('Europe', 'North America', 'European Union', 'South America', 'Africa', 'Oceania')
ORDER BY 2, 3;

CREATE VIEW GlobalDeathView 
AS
SELECT date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as float)) as Total_Deaths, sum(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location NOT IN ('Europe',
'North America',
'European Union',
'South America',
'Africa',
'Oceania')
GROUP BY date
ORDER BY 1,2;