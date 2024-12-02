                                          --Portfolio Project--
								           --Covid 19 Project--
								          --SQL DATA Exploration-- 


SELECT * FROM CovidDeaths;

-- Viewing Covid Deaths Table!
SELECT continent,location,date, total_cases, new_cases,total_deaths, population 
from CovidDeaths
ORDER BY 1,2;

-- Total Cases and Death wrt Continent & Location!

SELECT  continent,location as Location, MAX(cast(total_cases as int)) AS TotalCases, MAX(cast(total_deaths as int)) AS TotalDeaths
from CovidDeaths
WHERE CONTINENT IS NOT NULL
Group by continent, location
ORDER BY TotalDeaths Desc;

-- Percentage of Deaths!

SELECT  location, (sum(total_deaths)/sum(total_cases)) *100 AS DeathPercentage
from CovidDeaths
Group by location;


-- Shows your Infection Rate if live in Pakistan at that particular time

SELECT  continent, location ,date, population, total_cases , (total_cases/population)*100 as InfectRate
from CovidDeaths
WHERE location = 'Pakistan'
ORDER BY date;

-- Looking at a specific countries death percentage

SELECT  location , population, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths, (MAX(total_deaths)/MAX(total_cases))*100 as DeathPercentage
from CovidDeaths
WHERE location = 'Pakistan'
GROUP BY location, population
ORDER BY location;

-- Countries with Highest Infection Rate compared to Population

SELECT  location , population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectRate
from CovidDeaths
GROUP BY location, population
ORDER BY InfectRate DESC;

-- Countries HighestDeathCount wrt Population

SELECT population, location, MAX(cast(total_deaths as INT)) as HighestDeathCount 
from CovidDeaths
Where continent is not NULL
GROUP BY location, population
ORDER BY HighestDeathCount  DESC;

-- Let's look at things with respect to continent
-- Highest Death Count per Continent

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC; 

-- Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS INT)) as TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

--Using Partition by to update the people vaccinated per day
--The counter updates after each day


Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3


-- Since we cant use an already aggregated column for another aggreation in same select statement so we use CTE's

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Storing the total deaths per continent in a view table for later use, because its a very useful query and i need it for further visualizations!

CREATE VIEW DeathsPerContinent as
SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeaths DESC; 


-- Lets Create another view for infectRate in Pakistan since ill be using this alot

CREATE VIEW PakistanInfectRate as
SELECT  continent, location ,date, population, total_cases , (total_cases/population)*100 as InfectRate
from CovidDeaths
WHERE location = 'Pakistan';
