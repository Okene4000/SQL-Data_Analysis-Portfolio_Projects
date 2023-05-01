select *
from [PORTFOLIO PROJECT]..coviddeaths

select *
from [PORTFOLIO PROJECT]..covidvaccinations
order by 1,2

--Checking covid deaths data
select location, date, total_cases, new_cases, new_deaths, population
from [PORTFOLIO PROJECT]..coviddeaths
order by 1,2

-- calculating death percentage in different locations using data
select location, date, total_cases, new_deaths, population, (new_deaths/ population) * 100 as deathpercentage
from [PORTFOLIO PROJECT]..coviddeaths
order by 1,2

-- new cases data  vs new deaths data 
select location, new_cases, new_deaths, population, (new_deaths/ new_cases) * 100 as newcasenewdeathpercentage
from [PORTFOLIO PROJECT]..coviddeaths
order by 1,2


--Data on location with the highest death rate and deathpercentage
select location, MAX(new_deaths) as deathrate, population, MAX((new_deaths/ population)) * 100 as deathpercentage
from [PORTFOLIO PROJECT]..coviddeaths
where continent is not null
group by location, population
order by deathrate desc

--Looking at Global new cases vs Global new deaths
select date, SUM(new_cases) as totalglobalnewcases, SUM(cast(new_deaths as int)) as totalglobaldeaths
from [PORTFOLIO PROJECT]..coviddeaths
group by date
order by 1,2

--Looking at the highest global covid death data.
select date, SUM(new_cases) as totalglobalnewcases, SUM(cast(new_deaths as int)) as totalglobaldeaths
from [PORTFOLIO PROJECT]..coviddeaths
group by date
order by totalglobaldeaths desc

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
