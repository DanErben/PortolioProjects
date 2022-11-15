SELECT *  FROM CovidProject.deaths;


-- Select data to be studied
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.deaths
ORDER BY location, date;


-- total deaths vs total cases in the US.  shows the probability of death 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM CovidProject.deaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY location, date;


-- total cases vs total population.  what percent of the population got infected
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_infected 
FROM CovidProject.deaths
WHERE location = 'United States' 
ORDER BY location, date;


-- What countries have the highest infection to population ratio?
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_infected  
FROM CovidProject.deaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY percent_infected DESC;

-- What countries have the highest total death count?
SELECT location, MAX(total_deaths) AS total_death_count
FROM CovidProject.deaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY total_death_count DESC; 


-- Which continents have the highest total death count?
SELECT continent, MAX(total_deaths) AS total_death_count
FROM CovidProject.deaths
WHERE continent IS not null
GROUP BY continent
ORDER BY total_death_count DESC; 

			-- GLOBAL NUMBERS
-- Global death percentage per day
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100  AS global_death_pcnt 
FROM CovidProject.deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases)

-- Global death percentage for entire time range(2020-01-01 to 2021-04-30)
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100  AS global_death_pcnt 
FROM CovidProject.deaths
WHERE continent IS NOT NULL;


			-- VACCINATIONS TABLE
-- What is the total number of people in the world who've been vaccinated?
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
SUM(vax.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS rolling_sum_newvaxxed
FROM CovidProject.vaccinations AS vax
INNER JOIN CovidProject.deaths
    ON  deaths.location = vax.location
    AND deaths.date = vax.date  
WHERE deaths.continent IS NOT NULL  
ORDER BY 2,3;

-- using CTE.   
WITH vaxxed_population_ratio
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
SUM(vax.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS rolling_sum_newvaxxed
FROM CovidProject.vaccinations AS vax
INNER JOIN CovidProject.deaths
    ON  deaths.location = vax.location
    AND deaths.date = vax.date  
WHERE deaths.continent IS NOT NULL  
)
SELECT *, (rolling_sum_newvaxxed/population)*100  AS rolling_pct
FROM vaxxed_population_ratio;


-- creating a view to store data for later visualizations
CREATE VIEW CovidProject.percent_population_vaxxed AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
SUM(vax.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS rolling_sum_newvaxxed
FROM CovidProject.vaccinations AS vax
INNER JOIN CovidProject.deaths
    ON  deaths.location = vax.location
    AND deaths.date = vax.date  
WHERE deaths.continent IS NOT NULL;

SELECT * FROM CovidProject.percent_population_vaxxed;










