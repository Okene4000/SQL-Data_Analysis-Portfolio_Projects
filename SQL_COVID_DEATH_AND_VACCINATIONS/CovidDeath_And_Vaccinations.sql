--Checking the general data from the covid deaths table
SELECT *
FROM [PORTFOLIO PROJECT]..coviddeaths

-- Checking the general data from the covid vaccination table in ascending order. The default order for ORDER BY statement is ASCENDING ORDER
SELECT *
FROM [PORTFOLIO PROJECT]..covidvaccinations
ORDER BY 1,2

--Checking covid deaths data with specified columns in the covid death table by ascending order
SELECT location, date, total_cases, new_cases, new_deaths, population
FROM [PORTFOLIO PROJECT]..coviddeaths
ORDER BY 1,2

-- calculating death percentage in different locations using data from covid death table in ascending order
SELECT location, date, total_cases, new_deaths, population, (new_deaths/ population) * 100 as death_percentage
FROM [PORTFOLIO PROJECT]..coviddeaths
ORDER BY 1,2

-- Calculating new cases data  vs new deaths data, percentage in different locations using data from the  covid death table
SELECT location, new_cases, new_deaths, population, (new_deaths/ new_cases) * 100 as newcase_newdeath_percentage
FROM [PORTFOLIO PROJECT]..coviddeaths
ORDER BY 1,2


-- Showing Data on location with the highest death rate and death percentage
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

--Global numbers
select SUM(new_cases) as totalglobalcases, SUM(cast(new_deaths as int)) as totalglobaldeathcase, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
from [PORTFOLIO PROJECT]..coviddeaths
where continent is not NULL
order by 1,2

--Retrieving data from new tests vs positive rates 
select location, continent, date, new_tests, positive_rate, (positive_rate / new_tests) * 100 as positiveratepercentage
from [PORTFOLIO PROJECT]..covidvaccinations
where continent is not NULL
order by 1,2

--data containing covid death and covid vaccinations
select *
from [PORTFOLIO PROJECT]..coviddeaths dea
join [PORTFOLIO PROJECT]..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 3,4

--data on total population vs people vaccinated
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
from [PORTFOLIO PROJECT]..coviddeaths dea
join [PORTFOLIO PROJECT]..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 3,4

--
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [PORTFOLIO PROJECT]..coviddeaths dea
join [PORTFOLIO PROJECT]..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 3,4

--Get the percentage of the rolling people vaccinated vs population
--using CTE

With vac_pop (location, continent, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [PORTFOLIO PROJECT]..coviddeaths dea
join [PORTFOLIO PROJECT]..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
)
select *, (rollingpeoplevaccinated/ population) * 100 as vacpercentage
from vac_pop

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

insert into #vaccinatedpeoplepercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [PORTFOLIO PROJECT]..coviddeaths dea
join [PORTFOLIO PROJECT]..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

select *, (Rollingpeoplevaccinated/population) * 100 as vacpeopleper
from #vaccinatedpeoplepercentage

--create view to store data for visualization

create view vaccinatedpeoplepercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [PORTFOLIO PROJECT]..coviddeaths dea
join [PORTFOLIO PROJECT]..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

CREATE VIEW globalnewcasesvsglobalnewdeaths as
select date, SUM(new_cases) as totalglobalnewcases, SUM(cast(new_deaths as int)) as totalglobaldeaths
from [PORTFOLIO PROJECT]..coviddeaths
group by date
--order by 1,2

CREATE VIEW Global_numbers as
select SUM(new_cases) as totalglobalcases, SUM(cast(new_deaths as int)) as totalglobaldeathcase, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
from [PORTFOLIO PROJECT]..coviddeaths
where continent is not NULL
--order by 1,2
