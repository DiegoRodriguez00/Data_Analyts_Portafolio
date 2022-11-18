Select  *
FROM Portafolio_Proyect..CovidDeaths_1
where continent is not null
order by 3,4


--Select *
--From Portafolio_Proyect.dbo.CovidVaccination_1
--order by 3,4

-- Select the data that we are going to use 

Select Location,date,total_cases,new_cases,total_deaths,population
From Portafolio_Proyect.dbo.CovidDeaths_1
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
From Portafolio_Proyect.dbo.CovidDeaths_1
Where location like'%states%'
order by 1,2

-- Looking at total cases vs population
--Shows what porcentage of population got covid

Select Location,date,total_cases,total_deaths,(total_cases/population)*100 as DeathsPercentage
From Portafolio_Proyect.dbo.CovidDeaths_1
where continent is not null
--Where location like'%states%'
order by 1,2


--Looking at Countries with highest Infection rate compared to population 
Select Location,population,max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as PercentPopulationInfected
From Portafolio_Proyect.dbo.CovidDeaths_1
--Where location like'%states%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Count per Population 
Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portafolio_Proyect.dbo.CovidDeaths_1
--Where location like'%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK DOWN BY CONTINENT

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portafolio_Proyect.dbo.CovidDeaths_1
--Where location like'%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing the continents with the highest death count per population 

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portafolio_Proyect.dbo.CovidDeaths_1
--Where location like'%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as  int)) as total_deaths,SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portafolio_Proyect.dbo.CovidDeaths_1
--Where location like'%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs Vaccinations
With PopvsVac(Continent, location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated 
-- (RollingPeopleVaccinated/population)*100
From Portafolio_Proyect.dbo.CovidDeaths_1  dea
JOIN  Portafolio_Proyect.dbo.CovidVaccination_1  vac 
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portafolio_Proyect.dbo.CovidDeaths_1 dea
Join Portafolio_Proyect.dbo.CovidVaccination_1 vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

 Create View PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portafolio_Proyect.dbo.CovidDeaths_1 dea
Join Portafolio_Proyect.dbo.CovidVaccination_1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated
