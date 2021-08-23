/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT *
--  FROM Portfolio_project.dbo.covid_death
--  order by 3,4;

  --SELECT *
  --FROM Portfolio_project.dbo.covid_vac
  --order by 3,4;

  -- look at the death rate of America
  SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'death rate',(total_cases/population)*100 as 'Infected percent population'
  FROM Portfolio_project.dbo.covid_death
  where location like '%United States%'
  order by 1,2;


  SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'death rate', (total_cases/population)*100 as 'Infected percent population'
  FROM Portfolio_project.dbo.covid_death
  where location like '%Taiwan%'
  order by 1,2;

  -- show which country has the highest infected rate
  SELECT location, population, max(total_cases) as current_cases, (max(total_cases)/max(population))*100 as infected_rate
  FROM Portfolio_project.dbo.covid_death
  group by location, population
  order by infected_rate desc;

  --show which country has the highest death count per population
  SELECT location, population, max(cast(total_deaths as INT)) as death_cases, (max(total_deaths)/(population))*100 as death_rate
  FROM Portfolio_project.dbo.covid_death
  where continent is not null
  group by location, population
  order by death_cases desc;

  --show which continent has the highest death count per population
  SELECT continent, max(cast(total_deaths as INT)) as death_cases
  FROM Portfolio_project.dbo.covid_death
  where continent is not null
  group by continent
  order by death_cases desc;

  -- Global numbers
  
  SELECT date, sum(new_cases) as new_cases, sum(cast(new_deaths as INT)) as new_deaths, sum(cast(new_deaths as INT))/sum(new_cases)*100 as new_death_rate
  FROM Portfolio_project.dbo.covid_death
  -- where location like '%Taiwan%'
  where continent is not null
  group by date
  order by 1,2;

  SELECT sum(new_cases) as new_cases, sum(cast(new_deaths as INT)) as new_deaths, sum(cast(new_deaths as INT))/sum(new_cases)*100 as new_death_rate
  FROM Portfolio_project.dbo.covid_death
  -- where location like '%Taiwan%'
  where continent is not null
  --group by date
  order by 1,2;

  -- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vac

from Portfolio_project.dbo.covid_death dea
join Portfolio_project.dbo.covid_vac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- use CTE
with pop_vs_vac (continent, location, date, population, new_vaccinations,Rolling_vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vac
from Portfolio_project.dbo.covid_death dea
join Portfolio_project.dbo.covid_vac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (Rolling_vac/population) as vac_percentage
from pop_vs_vac;


-- use temp table
drop table if exists vac_pop_percentage
create table vac_pop_percentage
(
continent nvarchar(50),
location nvarchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_vac numeric
)
insert into vac_pop_percentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vac
from Portfolio_project.dbo.covid_death dea
join Portfolio_project.dbo.covid_vac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
select *, (Rolling_vac/population) as vac_percentage
from vac_pop_percentage;


--creating view to store data for later visualization
create view percent_vac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_vac
from Portfolio_project.dbo.covid_death dea
join Portfolio_project.dbo.covid_vac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;