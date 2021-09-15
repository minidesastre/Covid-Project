--This is a Exploratory Analysis of Covid Data from  Our World In Data, Source URL: https://ourworldindata.org/covid-deaths

--Looking at Total Cases vs Total Deaths:
--Shows likelihood of dying if you contract COVID in Spain

SELECT Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [SQL Covid Project]..CovidDeaths
WHERE location like '%spain%'
ORDER BY 1,2



--Looking at Total Cases vs Population
--Shows what percentage of population got Covid 
SELECT Location, date,population, total_cases ,(total_cases/population)*100 as PercentPopulationInfected
FROM [SQL Covid Project]..CovidDeaths
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

--Shows what percentage of population got Covid in Spain

SELECT Location, date,population, total_cases ,(total_cases/population)*100 as PercentPopulationInfected 
FROM [SQL Covid Project]..CovidDeaths
WHERE location like '%spain%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
FROM [SQL Covid Project]..CovidDeaths
WHERE dea.continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing the continents with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM [SQL Covid Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing the Highest Death Count by Continent

SELECT location,MAX(cast(total_deaths as float)) as TotalDeathCount
FROM [SQL Covid Project]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY  TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,SUM(CAST(total_deaths AS float)) as total_deaths,SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM [SQL Covid Project]..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--USE CTE

With PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
AS 
	(


-- JOIN OF THE COVID DEATHS TABLE AND THE COVID VACCINATION TABLE
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [SQL Covid Project]..CovidDeaths dea
JOIN [SQL Covid Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100 as 
FROM PopvsVac




--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population float,
 new_vaccinations float,
 rollingpeoplevaccinated numeric
 )
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [SQL Covid Project]..CovidDeaths dea
JOIN [SQL Covid Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


--Create View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM [SQL Covid Project]..CovidDeaths dea
JOIN [SQL Covid Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


