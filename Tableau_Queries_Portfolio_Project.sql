-- Queries for Tableau


-- Total worldwide cases, vaccinations, deaths and death percentage
SELECT MAX(dea.total_cases) AS total_covid_cases, 
MAX(CAST(vac.total_vaccinations AS float)) AS total_covid_vaccinations, 
MAX(CAST(dea.total_deaths AS float)) AS total_covid_deaths
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


-- Continent Population, total cases, total vaccinations, total deaths, total infection percentage, total vaccination percentage and total death percentage
SELECT dea.location AS continent, dea.population, 
MAX(dea.total_cases) AS total_covid_cases, 
MAX(CAST(vac.total_vaccinations AS float)) AS total_covid_vaccinations, 
MAX(CAST(dea.total_deaths AS float)) AS total_covid_deaths,
MAX(dea.total_cases)/dea.population*100 AS total_infection_percentage,
MAX(CAST(vac.total_vaccinations AS float))/dea.population*100 AS total_vaccination_percentage,
MAX(CAST(dea.total_deaths AS float))/dea.population*100 AS population_death_percentage,
MAX(CAST(dea.total_deaths AS float))/MAX(dea.total_cases)*100 AS covid_death_percentage
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NULL
AND dea.location NOT IN ('World', 'European Union', 'International')
GROUP BY dea.location, dea.population
ORDER BY dea.location



-- Countries Population, total cases, total vaccinations, total deaths, total infection percentage, total vaccination percentage and total death percentage against population and total covid cases
SELECT dea.location, dea.population, dea.date,
MAX(dea.total_cases) AS total_covid_cases, 
MAX(CAST(vac.total_vaccinations AS float)) AS total_covid_vaccinations, 
MAX(CAST(dea.total_deaths AS float)) AS total_covid_deaths,
MAX(dea.total_cases)/dea.population*100 AS total_infection_percentage,
MAX(CAST(vac.total_vaccinations AS float))/dea.population*100 AS total_vaccination_percentage,
MAX(CAST(dea.total_deaths AS float))/dea.population*100 AS population_death_percentage,
MAX(CAST(dea.total_deaths AS float))/MAX(dea.total_cases)*100 AS covid_death_percentage
FROM covid_db..CovidDeaths AS dea
JOIN covid_db..CovidVacc AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population, dea.date
ORDER BY dea.location