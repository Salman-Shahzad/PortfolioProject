--select * from CovidDeaths$ order by 3,4
--select * from CovidVaccinataions$ order by 3,4

--select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths$ order by 1,2 

-- total cases vs total deaths
select location,date,total_cases,total_deaths, (convert(float,total_deaths))/(nullif (convert(float,total_cases),0))*100 as DeathPercentage 
from CovidDeaths$ where location like '%pak%'
and continent is not null
order by 1,2


-- total cases vs popoualtion
select location,date,total_cases,population, (convert(float,total_cases))/(nullif (convert(float,population),0))*100 as TotalCase 
from CovidDeaths$ where location like '%states%'
and continent is not null
order by 1,2

--COuntries with higest infection rate vs popluation
select location,population,max(total_cases) as highest_infection_count, max(convert(float,total_cases))/(nullif (convert(float,population),0))*100 as HigestInfectRate
from CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by location,population
order by HigestInfectRate desc


--Countries Higest Death Count per population

select location,max(cast(total_deaths as int)) as death_toll 
from CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by location,population
order by death_toll desc


--Showing COntinets death toll
select continent,max(cast(total_deaths as int)) as death_toll 
from CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by continent
order by death_toll desc


select date,sum(new_cases)as totalCases,sum(cast(new_deaths as int))as newDeaths,sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as death_toll
from CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--total population data vs vaccinations
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from CovidDeaths$ death join CovidVaccinataions$ as vaccine
on death.date= vaccine.date and death.location = vaccine.location
where death.continent is not null 
order by 2,3

-- use CTE for above
 with PopVsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
 as
 (
 select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
	sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
	from CovidDeaths$ death join CovidVaccinataions$ as vaccine
	on death.date= vaccine.date and death.location = vaccine.location
	where death.continent is not null 
	--order by 2,3
)


select *,(RollingPeopleVaccinated/Population)*100 from PopVsVac


-- temp table for the above
drop table if exists  #PercentagePeopleVaccinated
Create table #PercentagePeopleVaccinated
(
  Continent varchar(255),
  Location varchar(255),
  Date dateTime,
  population bigint,
  new_vacination bigint,
  RollingPeopleVaccinated bigint

)
Insert into #PercentagePeopleVaccinated 
 select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
	sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
	from CovidDeaths$ death join CovidVaccinataions$ as vaccine
	on death.date= vaccine.date and death.location = vaccine.location
	where death.continent is not null 
	--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 from  #PercentagePeopleVaccinated




--create some views
create view PercentagePeopleVaccinated as
 select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
	sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
	from CovidDeaths$ death join CovidVaccinataions$ as vaccine
	on death.date= vaccine.date and death.location = vaccine.location
	where death.continent is not null 
	--order by 2,3
create view DeathToll as
select location,max(cast(total_deaths as int)) as death_toll 
from CovidDeaths$ 
--where location like '%states%'
where continent is not null
group by location,population
--order by death_toll desc


