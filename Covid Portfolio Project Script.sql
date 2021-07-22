SELECT *
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM CovidPortfolioProject..CovidVacinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
Order By 1, 2

--Looking Total Cases VS Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS "DeathPercentage"
FROM CovidPortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
Order By 1, 2

--Looking Population VS Total Cases
SELECT location, date, population, total_cases, (total_cases/population)*100 AS "CasePercentage"
FROM CovidPortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
Order By 1, 2

--Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionNumber, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
Group By location, population
Order By PercentPopulationInfected desc

--Looking countries with total death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NULL
Group By location
Order By TotalDeathCount desc

--Looking continents with Highest Death Counts

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NULL
Group By location
Order By TotalDeathCount desc

-- Across the World per day

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ((SUM(cast(new_deaths as int)))/(SUM(new_cases)))*100 AS "NewDeathPercentage"
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group By date
Order By 1, 2

-- Across the World Totally

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ((SUM(cast(new_deaths as int)))/(SUM(new_cases)))*100 AS "NewDeathPercentage"
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order By 1, 2

SELECT * 
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVacinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date

-- Looking at Total Population vs vacinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVacinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order By 2, 3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVacinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order By 2, 3

--Looking for number of vaccinations per population
--Using CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVacinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM popvsVac

--Using Temp Table

DROP Table IF Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Locatin nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RolingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVacinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM #PercentPopulationVaccinated

--Creating view to store data for latter visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVacinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
