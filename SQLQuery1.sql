/* The data were taken from 'ourworldindata' 
   and are valid until the 3rd of April 2022 */

SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent is not null -- Values like Asia, Africa, Europe etc appear in location collumn when there is null values in continent collumn  
Order by 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccinations
--WHERE continent is not null
--Order by 3,4

-- Select data we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
WHERE continent is not null
Order by 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you contract covid in Greece

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%Greece%' and continent is not null
Order by 1,2

-- Looking at total cases vs population 
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_population_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%Greece%' and continent is not null
Order by 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS total_infected, MAX(total_cases/population)*100 AS infected_population_percentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
Group by location, population
Order by infected_population_percentage desc

-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS total_deaths
FROM PortfolioProject..covid_deaths
WHERE continent is not null
Group by location 
Order by total_deaths desc

-- Breaking things down by continent

SELECT location, MAX(CAST(total_deaths as int)) AS total_deaths
FROM PortfolioProject..covid_deaths
WHERE continent is null and location NOT LIKE '%income%'
Group by location 
Order by total_deaths desc

-- There missing data with the method commented out below

--SELECT continent, MAX(CAST(total_deaths as int)) AS total_deaths
--FROM PortfolioProject..covid_deaths
--WHERE continent is not null
--Group by continent 
--Order by total_deaths desc



-- GLOBAL NUMBERS

-- Total cases, deaths and percentage for each day

SELECT date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
Group by date
Order by 1,2

-- Total cases, deaths and percentage for all days

SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
Order by 1,2


-- Looking at total population vs vaccination

SELECT  dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
FROM PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2, 3

-- Calculate what percentage of a country is vaccinated at all days using CTE

With Pop_vs_Vac (continent, location, date, population,new_vaccinations, total_people_vaccinated)
as
(
SELECT  dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
FROM PortfolioProject..covid_deaths dea
	Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3	
)
SELECT *, (total_people_vaccinated/population)*100 as percentage_of_people_vaccinated
From pop_vs_vac


-- Calculate what percentage of a country is vaccinated at all days using Temp table

drop table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_people_vaccinated numeric
)
Insert into #percent_population_vaccinated
SELECT  dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
FROM PortfolioProject..covid_deaths dea
	Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3

SELECT *, (total_people_vaccinated/population)*100 as percentage_of_people_vaccinated
From #percent_population_vaccinated


-- Creating view for visualizations

Create view PercentPopulationVaccinated as
SELECT  dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
FROM PortfolioProject..covid_deaths dea
	Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3

SELECT *
FROM PercentPopulationVaccinated
