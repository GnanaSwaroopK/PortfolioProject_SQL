SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3, 4

-- Selecting data that is going to be used

SELECT location, date, total_cases, new_cases, total_deaths
FROM [Portfolio Project]..CovidDeaths

-- Looking at total cases vs total deaths

SELECT location, SUM(total_cases) AS NumCases, SUM(CAST(total_deaths AS int)) AS NumDeaths
FROM [Portfolio Project]..CovidDeaths
WHERE total_cases <> 'NULL' AND 
total_deaths <> 'NULL'
GROUP BY location

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

-- Global numbers

SELECT SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS int)) AS NewDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Global numbers by date

SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS int)) AS NewDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at toal population vs vaccinations

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
	AND dea.location = 'India'

-- Total vaccinations aggregate function

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumbers
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- USING CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinationNumbers)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumbers
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RollingVaccinationNumbers/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated --In case there are changes to be made after the query is run once, this is necessary as it cannot override the table when its already created
CREATE TABLE #PercentagePopulationVaccinated
(
Continenet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationNumbers
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *, (RollingVaccinationNumbers/Population)*100
FROM #PercentPopulationVaccinated

