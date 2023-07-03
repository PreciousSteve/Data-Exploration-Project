--Select the whole dataset for a glance
SELECT *
FROM dbo.CovidData
WHERE continent IS NOT NULL
ORDER BY 3,4

--Changing datatypes
ALTER TABLE CovidData
ALTER COLUMN total_cases DECIMAL(28,0)

ALTER TABLE CovidData
ALTER COLUMN total_deaths DECIMAL(28,0)

ALTER TABLE CovidData
ALTER COLUMN population DECIMAL(28,0)

--Selecting the data needed
SELECT location,
		date,
		total_cases,
		new_cases, 
		total_deaths, 
		new_deaths, 
		population 
FROM CovidData
WHERE continent IS NOT NULL
ORDER BY 1,2

--Percentage of total deaths vs total cases worldwide. Added the nullif function due to 'divide by zero error encountered'
SELECT location,
		date,
		total_cases, 
		total_deaths, 
		(total_deaths/NULLIF(total_cases, 0))*100 AS PercentageDeathWorld 
FROM CovidData
WHERE continent IS NOT NULL
ORDER BY 1,2

--Percentage of total deaths vs total cases in Nigeria
WITH cte_PercentageDeath AS (
SELECT location,
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/NULLIF(total_cases, 0))*100 as PercentageDeath 
FROM CovidData
WHERE location = 'Nigeria' AND continent IS NOT NULL )
SELECT location,
		date, 
		total_cases, 
		total_deaths, 
		REPLACE((ROUND(PercentageDeath, 2)),'0','') as PercentageDeathNigeria
FROM cte_PercentageDeath
ORDER BY PercentageDeathNigeria desc


--Percentage of total cases vs population in Nigeria
--shows the percentage of population that got covid in nigeria

SELECT location,
		date,
		population,
		total_cases, 
	    (total_cases/NULLIF(population, 0))*100 AS PercentageInfectedNigeria 
FROM CovidData
WHERE location = 'Nigeria'
ORDER BY 1,2

--countries with highest infection rate vs population

SELECT location, 
		population,
		MAX(total_cases) highest_infection_rate,
		MAX(total_cases/NULLIF(population, 0))*100 AS PercentagePopulationInfected
FROM CovidData
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Continent with Highest death count
SELECT continent, MAX(total_deaths) HighestDeathCount
from CovidData
where continent IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Countries with highest Death count

SELECT location, MAX(total_deaths) HighestDeathCount
from CovidData
where continent IS NOT NULL AND location NOT IN ('World', 'High Income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income','European Union')
GROUP BY location
ORDER BY HighestDeathCount DESC


--Total population vs per day vaccinations
SELECT data1.continent, data1.location, data1.date, data1.population, data1.new_vaccinations, SUM(CAST(data1.new_vaccinations AS INT)) OVER (PARTITION BY data1.location, data1.date) AS PeopleVaccinated
FROM CovidData data1
join CovidData data2
     ON data1.location = data2.location 
	 AND data1.date = data2.date
where data1.continent IS NOT NULL 
ORDER BY 1, 2, 3

--creating a temp table
DROP TABLE IF EXISTS
CREATE TABLE #PeopleVaccinated
 (Continent varchar(255),
  Location varchar(255),
  Date date,
  Population numeric,
  New_vaccination numeric)

INSERT INTO #PeopleVaccinated
SELECT data1.continent, data1.location, data1.date, data1.population, data1.new_vaccinations, SUM(CAST(data1.new_vaccinations AS INT)) OVER (PARTITION BY data1.location, data1.date) AS PeopleVaccinated
FROM CovidData data1
join CovidData data2
     ON data1.location = data2.location 
	 AND data1.date = data2.date
where data1.continent IS NOT NULL 
ORDER BY 1, 2, 3

