-- Select data that I am going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at Total Caes vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Poland' AND continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Poland' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate DESC


-- Countries with highest death count per population
 SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC


-- GLOBAL NUMBERS


-- Global daily death percentage
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2



--Total global death percentage
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- Looking at total population versus vaccination
SELECT deaths.continent, deaths.location, deaths.date, population, vacc.new_vaccinations
, SUM(CONVERT(INT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths deaths
JOIN PortfolioProject.dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2, 3

-- Using CTE
WITH POPvsVACC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, population, vacc.new_vaccinations
, SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths deaths
JOIN PortfolioProject.dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS GlobalRollingVaccination
FROM POPvsVACC


-- Temp Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentagePopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, population, vacc.new_vaccinations
, SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths deaths
JOIN PortfolioProject.dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS GlobalRollingVaccination
FROM #PercentagePopulationVaccinated


-- Creating View to store data for visualizations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, population, vacc.new_vaccinations
, SUM(CONVERT(BIGINT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths deaths
JOIN PortfolioProject.dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3