SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_log..CovidDeaths$
WHERE Continent is not NULL
ORDER BY 1,2;

--Total cases vs Total deaths in the country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_perc
FROM Covid_log..CovidDeaths$
WHERE location like '%States%'
WHERE Continent is not NULL
ORDER BY 1,2;


--Total cases vs population
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
FROM Covid_log..CovidDeaths$
WHERE location like '%States%'
WHERE Continent is not NULL
ORDER BY 1,2;

--Countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM Covid_log..CovidDeaths$
WHERE Continent is not NULL
Group by Location, Population
ORDER BY 4 desc;


--Countries with highest death count per population
SELECT continent, Population, MAX(cast(total_deaths as int)) as DeathCount
FROM Covid_log..CovidDeaths$
WHERE Continent is not NULL
Group by continent, Population
ORDER BY 3 desc;


--GLOBALLY

SELECT sum(new_cases) as TotalNewCases, sum(cast(total_deaths as int)) as DeathCount, sum(cast(total_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid_log..CovidDeaths$
where continent is not null

order by 1,2;

With PopulationVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccines) as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccines
from Covid_log..CovidDeaths$ dea
Join Covid_log..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
Select *, (RollingPeopleVaccines/Population)*100 From PopulationVsVac 


Create view PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccines
from Covid_log..CovidDeaths$ dea
Join Covid_log..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null