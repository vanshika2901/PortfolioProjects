select * from project_portfolio..coviddeaths$ order by 3,4


--select * from project_portfolio..CovidVaccinations$ order by 3,4

--selecting data I will be working with
select location,date,total_cases,new_cases,total_deaths,population 
from project_portfolio..coviddeaths$ where continent is not null order by 1,2

-- looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100
as DeathPercentage from project_portfolio..coviddeaths$ where location like '%states%' and continent is not null order by 1,2

--looking at total cases vs population
--what percentage of population has got covid
select location,date,population,total_cases,(total_cases/population)*100
as percentpopulationinfected from project_portfolio..coviddeaths$ where location like '%states%' and continent is not null 
order by 1,2


-- looking at countries with highest infection rate compared to population
select location, population,max(total_cases) as highestinfectioncount,
max((total_cases/population)*100) as percentpopulationinfected 
from project_portfolio..coviddeaths$ where continent is not null group by location,population order by percentpopulationinfected desc

--showing Countries with highest death count per population
select location,max(cast(total_deaths as int)) 
as totaldeathcount from project_portfolio..coviddeaths$ where continent is not null group by location
order by totaldeathcount desc

--lets break things down by continent
--showing continents with the highest death count per population
select continent,max(cast(total_deaths as int)) 
as totaldeathcount from project_portfolio..coviddeaths$ where continent is not null group by continent
order by totaldeathcount desc

--correct data
select location,max(cast(total_deaths as int)) 
as totaldeathcount from project_portfolio..coviddeaths$ where continent is null group by location
order by totaldeathcount desc



-- Global numbers
select date,sum(total_cases) as total_cases,sum(cast(total_deaths as int)) as total_deaths,
(sum(cast(total_deaths as int))/sum(total_cases)*100) as DeathPercentage
from project_portfolio..coviddeaths$ where continent is not null  group by date order by 1

--total cases across the world

select sum(total_cases) as total_cases,sum(cast(total_deaths as int)) as total_deaths,
(sum(cast(total_deaths as int))/sum(total_cases)*100) as DeathPercentage
from project_portfolio..coviddeaths$ where continent is not null;



--joining the two tables deaths and vaccination 
-- looking at total population vs vaccinations
-- use cte

with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select de.continent,de.location,de.date,de.population,va.new_vaccinations, 
sum(convert(int,va.new_vaccinations)) over (partition by de.location Order by de.location,de.date)
as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100 --here cte is required
from project_portfolio..coviddeaths$ de join project_portfolio..covidVaccinations$ va 
on de.location=va.location and de.date=va.date
where de.continent is not null
--order by 1,2,3
)
select *, (Rollingpeoplevaccinated/population)*100 from popvsvac




--temp table
drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated(continent nvarchar(255),location nvarchar(255),
Date datetime,population numeric,new_vaccinations numeric, RollingPeopleVaccinated numeric)


insert into percentPopulationVaccinated 
select de.continent,de.location,de.date,de.population,va.new_vaccinations, 
sum(convert(int,va.new_vaccinations)) over (partition by de.location Order by de.location,de.date)
as RollingPeopleVaccinated
from project_portfolio..coviddeaths$ de join project_portfolio..covidVaccinations$ va 
on de.location=va.location and de.date=va.date
where de.continent is not null --order by 2,3

select *, (Rollingpeoplevaccinated/population)*100 from percentPopulationVaccinated 



--creating view to store data for later visualisations

create view percentpopuvaccinated as 
select de.continent,de.location,de.date,de.population,va.new_vaccinations, 
sum(convert(int,va.new_vaccinations)) over (partition by de.location Order by de.location,de.date)
as RollingPeopleVaccinated
from project_portfolio..coviddeaths$ de join project_portfolio..covidVaccinations$ va 
on de.location=va.location and de.date=va.date
where de.continent is not null
--order by 1,2,3


select * from percentpopuvaccinated