

-- Which country reported the maximum number of cases?

SELECT location, MAX(total_cases) AS max_cases
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_cases DESC ;

-- Which country reported the maximum number of deaths?
SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS max_deaths
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_deaths DESC;

-- Current likelihood of dying from COVID in different countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL
AND DATEPART(yy,date) = 2023 AND DATEPART(mm,date) =01 AND DATEPART(dd,date) = 31
ORDER BY death_percentage DESC;

-- Percentage of Population Infected and Percentage of Population Dead Per Country
SELECT location, 
       population,
       SUM(new_cases) AS total_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_deaths,
	   ROUND(SUM(new_cases)/population * 100,2) AS population_percentage_infected,
	   ROUND(SUM(CAST(new_deaths AS INT))/population * 100,2) AS population_percentage_dead
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_percentage_infected DESC;

-- Which countries have high infection rates AS on Jan 31, 2023?
SELECT location, population, MAX(total_cases) AS max_cases, MAX(total_cases)/population*100 AS percentage_population_infected
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY percentage_population_infected DESC;


-- Which countries have high death rates by population AS on Jan 31,2023?

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL
AND DATEPART(yy, date) = 2023 AND DATEPART(mm, date) = 01 AND DATEPART(dd, date) = 31
ORDER BY death_percentage DESC;


-- Global numbers

SELECT SUM(new_cases) AS total_cases,
       SUM(CAST(new_deaths AS INT)) AS total_deaths,
	   ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS global_death_percentage
	   
FROM dbo.covid_deaths$
WHERE continent IS NOT NULL;

-- Total Population vs Vaccination

WITH table_rolling_sum AS (SELECT cd.location, cd.date, cd.population, SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinated
FROM dbo.covid_deaths$ AS cd
JOIN dbo.covid_vaccination$ AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL)

SELECT *, (rolling_vaccinated/population)*100 AS percentage_vaccinated
FROM table_rolling_sum
WHERE DATEPART(yy, date) = 2023 AND DATEPART(mm, date) = 01 AND DATEPART(dd, date) = 31
ORDER BY percentage_vaccinated DESC;












