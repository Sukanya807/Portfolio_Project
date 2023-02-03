
-- Select the data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths$
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Cases Vs Total Deaths
Likelihood of dying from COVID in different countries currently
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
FROM covid_deaths$
WHERE location  = 'Canada' AND continent IS NOT NULL



-- Total Cases vs Population
 Shows what percentage of population got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_cpositive
FROM covid_deaths$
WHERE continent IS NOT NULL
ORDER BY location, date

-- Which countries have the highest infection rate compared to population?
SELECT location,population, MAX(total_cases) as max_num_cases, MAX((total_cases/population)*100) AS max_pop_percentage_infected
FROM covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_pop_percentage_infected DESC

--Which countries have the highest death count per population?
SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS max_deaths
FROM covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_deaths DESC;




-- BREAKING IT DOWN BY CONTINENTS


-- showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS max_deaths
FROM covid_deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_deaths DESC;


-- GLOBAL Numbers By Date
SELECT  date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS BIGINT)) AS total_deaths, 
SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases)*100 AS global_death_percentage
FROM covid_deaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY  total_cases

---- GLOBAL Numbers OVERALL
SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS BIGINT)) AS total_deaths, 
SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases)*100 AS global_death_percentage
FROM covid_deaths$
WHERE continent IS NOT NULL
ORDER BY  total_cases


-- JOINING THE TABLES

--Looking at Total Population vs Vaccinations
WITH table_rolling_sum AS(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
   SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)AS rolling_people_vaccinated
FROM covid_deaths$ AS cd
JOIN covid_vaccination$ AS cv
ON cd.location = cv.location AND cd.date= cv.date	
WHERE cd.continent IS NOT NULL)
--ORDER BY 2,3)

SELECT *, (rolling_people_vaccinated/population)*100
FROM table_rolling_sum

-- TEMP TABLE (SAME AS ABOVE)

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert Into #percentpopulationvaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM covid_deaths$ AS cd
JOIN covid_vaccination$ AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cv.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percentpopulationvaccinated




