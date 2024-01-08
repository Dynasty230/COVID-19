--select Data you are going to use.
SELECT location, continent, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_db..covidDeaths
WHERE continent IS NOT NULL
--GROUP BY location
ORDER BY 1,2



--Looking at Total cases vs Total Deaths (How many cases do we have in each country and how many death)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 'Death Percentage'
FROM PortfolioProject_db..covidDeaths
WHERE location LIKE '%geria%'
ORDER BY 1,2



SELECT location, date, total_cases, population, (total_cases/population) * 100 'Death Percentage'
FROM PortfolioProject_db..covidDeaths
WHERE location LIKE '%nada%'
ORDER BY 1,2



--Looking at Countries with Highest Infection Rate Compared to the Population
SELECT location, MAX(total_cases) 'Highest Infection Number', population, 
MAX((total_cases/population)) * 100 'Percentage of the Infected Population'
FROM PortfolioProject_db..covidDeaths
GROUP BY location, population
ORDER BY 4 DESC



--Countries with the Highest Death count 
SELECT location, MAX(total_deaths) 'Total Deaths'
FROM PortfolioProject_db..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC





--Breaking down by continent
SELECT location, MAX(total_deaths) 'Total Deaths'
FROM PortfolioProject_db..covidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC


--Continenrs with the Highest Death count
SELECT continent, MAX(total_deaths) 'Total Deaths'
FROM PortfolioProject_db..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC




--Global cases and deaths percents
SELECT SUM(new_cases) AS 'Total cases', SUM(new_deaths) AS 'Total Deaths', SUM(new_deaths)/SUM(new_cases) * 100 'Death Percentage'
FROM PortfolioProject_db..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Looking at the total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'Total vaccination'
FROM PortfolioProject_db..covidDeaths dea
JOIN PortfolioProject_db..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3 



--Using CTE 
WITH PopvsVac (continent, location, date, population, New_vaccinations, PeopleVaccinated )
	AS (
	SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject_db..covidDeaths dea
JOIN PortfolioProject_db..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)

SELECT *, (PeopleVaccinated/population)*100
FROM PopvsVac
ORDER BY 6 DESC



--Using a temp table
CREATE TABLE #percentVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric,
)

INSERT INTO #percentVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject_db..covidDeaths dea
JOIN PortfolioProject_db..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


SELECT *, (PeopleVaccinated/population)*100
FROM #percentVaccinated


--Create view for visualization
CREATE VIEW percentVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioProject_db..covidDeaths dea
JOIN PortfolioProject_db..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *
FROM percentVaccinated