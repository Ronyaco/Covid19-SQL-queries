
-- Selecting the data to be used 
select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
where
	continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Death Percentage in Your Country
	select location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPct
	from PortfolioProject..CovidDeaths$
	continent is not null
	where location  like 'Australia'
	order by 1,2

-- Total Cases vs Population 
-- Percentage of popultation that got infected
select 
  location, 
  date,
  population,
  total_cases, 
  total_deaths, 
  (total_cases / population * 100) as Infection_Pct 
from 
  PortfolioProject..CovidDeaths$ 
where 
  continent is not null
  location like 'Australia' 
order by 
  1, 
  2

  -- Total Cases vs Population 
-- Percentage of popultation that got infected
select 
  location, 
  population, 
  Max(total_cases) as Highest_InfectionRate, 
  Max(
    (total_cases / population * 100)
  ) as Infection_Pct 
from 
  PortfolioProject..CovidDeaths$ 
Group by 
  population, 
  location 
order by 
  4 Desc

-- Shwoing Countries with highest Death count per population
select 
  location, 
  Max(
    cast(Total_deaths AS int)
  ) as TotalDeathCount 
from 
  PortfolioProject..CovidDeaths$ 
where 
  continent is not null 
Group by 
  location 
Order By 
  TotalDeathCount Desc

  -- Showing Countries with highest Death count per Continent
select 
  location, 
  Max(
    cast(Total_deaths AS int)
  ) as TotalDeathCount 
from 
  PortfolioProject..CovidDeaths$ 
where 
  continent is null 
Group by 
  location 
Order By 
  TotalDeathCount Desc

 --- Presenting Global numbers 

select 
  date, 
  sum(new_cases) as TotalCases, 
  sum(
    cast(new_deaths as int)
  ) as TotalDeaths,
  sum(cast(new_deaths as int))/sum(new_cases)*100
from 
  PortfolioProject..CovidDeaths$ 
where 
  continent is not null 
group by 
  date 
order by 
  1, 
  2

--- Total cases worlwide

select 
  sum(new_cases) as TotalCases, 
  sum(
    cast(new_deaths as int)
  ) as TotalDeaths, 
  sum(
    cast(new_deaths as int)
  )/ sum(new_cases)* 100 as Death_Percentage 
from 
  PortfolioProject..CovidDeaths$ 
where 
  continent is not null 
order by 
  1, 
  2

-- Total  Population Vs Total vaccination

select 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as RollingPeopleVaccinated
from 
  PortfolioProject..CovidDeaths$ as dea 
  join PortfolioProject..CovidVaccinations$ as vac 
  On dea.location = vac.location 
  and dea.date = vac.date
where dea.continent is not null
order by 2,3 asc


-- Use CTE
With PopvsVac (
  Continent, location, date, population, 
  New_vaccinations, RollingPeopleVaccinated
) as (
  Select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(
      convert(int, vac.new_vaccinations)
    ) OVER (
      Partition by dea.location 
      Order by 
        dea.location, 
        dea.date
    ) as RollingPeopleVaccinated 
  from 
    PortfolioProject..CovidDeaths$ as dea 
    join PortfolioProject..CovidVaccinations$ as vac On dea.location = vac.location 
    and dea.date = vac.date 
  where 
    dea.continent is not null
) 
select 
  *, 
  (
    RollingPeopleVaccinated / population
  )* 100 
from 
  PopvsVac

-- Using a Temporary Table
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated

Select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(
      convert(int, vac.new_vaccinations)
    ) OVER (
      Partition by dea.location 
      Order by 
        dea.location, 
        dea.date
    ) as RollingPeopleVaccinated 
  from 
    PortfolioProject..CovidDeaths$ as dea 
    join PortfolioProject..CovidVaccinations$ as vac On dea.location = vac.location 
    and dea.date = vac.date 
  where 
    dea.continent is not null

select *,  ( RollingPeopleVaccinated / population)* 100 
from  #PercentagePopulationVaccinated

-- Create view for future Viz


Create view PercentagePopulationVaccinated as 
Select 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(
    convert(int, vac.new_vaccinations)
  ) OVER (
    Partition by dea.location 
    Order by 
      dea.location, 
      dea.date
  ) as RollingPeopleVaccinated 
from 
  PortfolioProject..CovidDeaths$ as dea 
  join PortfolioProject..CovidVaccinations$ as vac On dea.location = vac.location 
  and dea.date = vac.date 
where 
  dea.continent is not null


select * from PercentagePopulationVaccinated


