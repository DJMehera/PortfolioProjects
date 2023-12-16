SELECT *
FROM covid_db..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM covid_db..CovidVacc
--ORDER BY 3, 4


-- Taking a look at selective columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Death rate in different countries from covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_rate'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Death rate in India from covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_rate'
FROM covid_db..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2


-- Covid affect rate in different countries
SELECT location, date, total_cases, population, (total_cases/population)*100 AS 'affect_rate'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Covid affected rate in India
SELECT location, date, total_cases, population, (total_cases/population)*100 AS 'affect_rate'
FROM covid_db..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2


-- Countries with the highest infection rate
SELECT location, population, MAX(total_cases) AS 'highest_inf_count', MAX(total_cases/population)*100 AS 'max_affect_rate'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_affect_rate DESC


-- Highest infection rate in India
SELECT location, population, MAX(total_cases) AS 'highest_inf_count', MAX(total_cases/population)*100 AS 'max_affect_rate'
FROM covid_db..CovidDeaths
GROUP BY location, population
HAVING location = 'India'
ORDER BY max_affect_rate DESC


-- Countries with the highest death rate
SELECT location, population, MAX(CAST(total_deaths AS int)) AS 'highest_death_count', MAX(total_deaths/population)*100 AS 'max_death_rate'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_death_rate DESC


-- Countries with highest death
SELECT location, MAX(CAST(total_deaths AS int)) AS 'highest_death_count'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC

-- Continents with highest death
SELECT location, MAX(CAST(total_deaths AS int)) AS 'highest_death_count'
FROM covid_db..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death_count DESC


-- Global numbers broken by date
SELECT date, SUM(new_cases) AS 'total_no_cases', SUM(CAST(new_deaths AS float)) AS 'total_no_deaths', ((SUM(CAST(new_deaths AS float))/SUM(new_cases)))*100 AS death_rate
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Just the global numbers
SELECT SUM(new_cases) AS 'total_no_cases', SUM(CAST(new_deaths AS float)) AS 'total_no_deaths', ((SUM(CAST(new_deaths AS float))/SUM(new_cases)))*100 AS death_rate
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Taking a look at CovidVacc Table

SELECT *
FROM covid_db..CovidVacc
ORDER BY 3, 4


-- Joining CovidDeaths and CovidVacc Tables
SELECT *
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
ON dea.location = vac.location
AND dea.date = vac.date


-- Taking a look at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vac)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_people_vac/population)*100 AS percent_roll_vac
FROM PopvsVac


-- Temp Table
DROP TABLE IF EXISTS #Percent_Pop_Vacc
CREATE TABLE #Percent_Pop_Vacc
	(
		continent NVARCHAR(255),
		location NVARCHAR(255),
		date DATETIME,
		population NUMERIC,
		new_vaccinations NUMERIC,
		rolling_people_vac NUMERIC
	)
INSERT INTO	#Percent_Pop_Vacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vac/population)*100 AS percent_roll_vac
FROM #Percent_Pop_Vacc


-- Total infected, total Vaccinations, total deaths and and total death percentage for different countries
SELECT dea.location AS country, dea.population AS country_population, SUM(dea.new_cases) AS total_covid_cases, SUM(CONVERT(int, vac.new_vaccinations)) AS total_covid_vaccinations, SUM(CAST(dea.new_deaths AS float)) AS total_covid_deaths, SUM(CAST(dea.new_deaths AS float))/SUM(dea.new_cases)*100 AS total_covid_death_percent
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY dea.location






-- Creating Views

-- Infection rate in different countries at different dates
CREATE VIEW infection_rate AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS 'inf_rate'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL

-- Countries with highest infection rate
CREATE VIEW highest_infection_rate AS
SELECT location, population, MAX(total_cases) AS 'max_inf_count', MAX(total_cases)/population*100 AS 'max_inf_rate'
FROM covid_db..CovidDeaths
GROUP BY location, population

-- Countries with highest death
CREATE VIEW highest_death_country AS
SELECT location, MAX(CAST(total_deaths AS int)) AS 'highest_death_count'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

-- Continents with highest death
CREATE VIEW highest_death_continent AS
SELECT location, MAX(CAST(total_deaths AS int)) AS 'highest_death_count'
FROM covid_db..CovidDeaths
WHERE continent IS NULL
GROUP BY location

-- Countries death rate data
CREATE VIEW highest_death_rate_country AS
SELECT location, population, MAX(CAST(total_deaths AS int)) AS 'highest_death_count', MAX(CAST(total_deaths AS int))/population*100 AS 'max_death_rate'
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population

-- Total number of cases, total deaths and death per number of cases broken by date
CREATE VIEW global_numbers AS
SELECT date, SUM(new_cases) AS 'total_no_cases', SUM(CAST(new_deaths AS float)) AS 'total_no_deaths', SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS death_rate
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

-- Total infected, total Vaccinations, total deaths and and total death percentage for different countries
CREATE VIEW country_covid_data AS
SELECT dea.location AS country, dea.population AS country_population, SUM(dea.new_cases) AS total_covid_cases, SUM(CONVERT(int, vac.new_vaccinations)) AS total_covid_vaccinations, SUM(CAST(dea.new_deaths AS float)) AS total_covid_deaths, SUM(CAST(dea.new_deaths AS float))/SUM(dea.new_cases)*100 AS total_covid_death_percent
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population

-- Number of people getting vaccinated in countries per day
CREATE VIEW pop_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

