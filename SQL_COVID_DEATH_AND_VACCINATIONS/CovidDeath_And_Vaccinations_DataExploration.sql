--Count the number of rows in the Covid death table
SELECT COUNT(*)
FROM [PORTFOLIO PROJECT]..coviddeaths

--Count the number of rows in the Covid vaccination table
 SELECT COUNT(*)
 FROM [PORTFOLIO PROJECT]..covidvaccinations

--Checking the general data from the covid deaths table
SELECT *
FROM [PORTFOLIO PROJECT]..coviddeaths

-- Checking the general data from the covid vaccination table in ascending order.
SELECT *
FROM [PORTFOLIO PROJECT]..covidvaccinations
ORDER BY 1,2 --The default order for order by statement is the ascending order

--Checking covid deaths data with specified columns in the covid death table by ascending order
SELECT location, date, total_cases, new_cases, new_deaths, population
FROM [PORTFOLIO PROJECT]..coviddeaths
ORDER BY 1,2

-- calculating death percentage in different Countries using data from covid death table in ascending order
SELECT location, date, total_cases, new_deaths, population, (new_deaths/ population) * 100 as death_percentage
FROM [PORTFOLIO PROJECT]..coviddeaths
ORDER BY 1,2

-- Calculating new cases data  vs new deaths data, percentage in different Countries using data from the  covid death table
SELECT location, new_cases, new_deaths, population, (new_deaths/ new_cases) * 100 as newcase_newdeath_percentage
FROM [PORTFOLIO PROJECT]..coviddeaths
ORDER BY 1,2


-- Showing Data on Countries with the highest death rate and death percentage
SELECT location, MAX(new_deaths) as deathrate, population, MAX((new_deaths/ population)) * 100 as death_percentage
FROM [PORTFOLIO PROJECT]..coviddeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY deathrate DESC

--Showing data on Global new cases vs Global new deaths
SELECT date, SUM(new_cases) as totalglobalnewcases, SUM(cast(new_deaths as int)) as totalglobaldeaths
FROM [PORTFOLIO PROJECT]..coviddeaths
GROUP BY date
ORDER BY 1,2

--Showing data on the highest global covid death data.
SELECT date, SUM(new_cases) as totalglobalnewcases, SUM(cast(new_deaths as int)) as totalglobal_deaths
FROM [PORTFOLIO PROJECT]..coviddeaths
GROUP BY date
ORDER BY totalglobaldeaths DESC

--Showing data based on Global numbers
SELECT SUM(new_cases) as totalglobalcases, SUM(cast(new_deaths as int)) as totalglobaldeathcase, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
FROM [PORTFOLIO PROJECT]..coviddeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Retrieving data from new tests vs positive rates and the percentage of positive rates based on Countries.
SELECT location, continent, date, new_tests, positive_rate, (positive_rate / new_tests) * 100 as positiveratepercentage
FROM [PORTFOLIO PROJECT]..covidvaccinations
WHERE continent is NOT NULL
ORDER BY 1,2

--This query shows all datas containing covid death and covid vaccinations
SELECT *
FROM [PORTFOLIO PROJECT]..coviddeaths dea
JOIN [PORTFOLIO PROJECT]..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 3,4

--The query shows data on total population vs people vaccinated in different Countries
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
FROM [PORTFOLIO PROJECT]..coviddeaths dea
JOIN [PORTFOLIO PROJECT]..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 3,4

--This query shows the total number of people vaccinated Globally in a rolling count per day.
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rollingpeople_vaccinated
FROM [PORTFOLIO PROJECT]..coviddeaths dea
JOIN [PORTFOLIO PROJECT]..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 3,4

--Get the percentage of the rolling people vaccinated vs population using CTE
-- We will take the query for total number of people vaccinated globally in a rolling count (line 75 to 82) as our subquery.

WITH vac_pop (location, continent, date, population, new_vaccinations, Rollingpeople_vaccinated)
as
( SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM [PORTFOLIO PROJECT]..coviddeaths dea
JOIN [PORTFOLIO PROJECT]..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
 dea.continent is NOT NULL)
SELECT *, (rollingpeoplevaccinated/ population) * 100 as vac_percentage
FROM vac_pop

--TEMP TABLE
DROP TABLE if exists #vaccinatedpeoplepercentage
CREATE TABLE #vaccinatedpeoplepercentage
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

-- Insert data into the Temp Table
INSERT INTO #vaccinatedpeoplepercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM [PORTFOLIO PROJECT]..coviddeaths dea
JOIN [PORTFOLIO PROJECT]..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL

--This query shows the percentage of people vaccinated using the temp table.
SELECT *, (Rollingpeoplevaccinated/population) * 100 as vacpeople_percentage
FROM #vaccinatedpeoplepercentage

--create view to store data for visualization for the percentage of vaccinated people
CREATE VIEW vaccinatedpeoplepercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM [PORTFOLIO PROJECT]..coviddeaths dea
JOIN [PORTFOLIO PROJECT]..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL

--Create view to store data for visualization for the global new cases vs global new deaths
CREATE VIEW globalnewcasesvsglobalnewdeaths as
SELECT date, SUM(new_cases) as totalglobalnewcases, SUM(cast(new_deaths as int)) as totalglobaldeaths
FROM [PORTFOLIO PROJECT]..coviddeaths
GROUP BY date

--Create view to store visualization for the Global number of Covid cases.
CREATE VIEW Global_numbers as
SELECT SUM(new_cases) as totalglobalcases, SUM(cast(new_deaths as int)) as totalglobaldeathcase, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
FROM [PORTFOLIO PROJECT]..coviddeaths
WHERE continent is NOT NULL
