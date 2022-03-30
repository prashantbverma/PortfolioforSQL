use PortfolioProject

select * from PortfolioProject..CovidDeaths
order by 3, 4

--select * from PortfolioProject..CovidVaccinations
--order by 3, 4


--Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select Location, DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location = 'India'
order by 1,2

--Total cases vs Population
--shows what percentage of population got covid

Select Location, DATE, Population, total_cases, (total_cases/population)*100 as CasesPerPop_Percentage
from CovidDeaths
where location = 'India'
order by 1,2

--Look for countries with highest infection rate compared to population

Select Location, Population, max(total_cases) as Highest_Infection_Count, max((total_cases/population)*100)as CasesPerPop_Percentage
from CovidDeaths
Group by location, Population
order by 4 desc

--show the country with highest death count per population
Select Location,  max(cast(total_deaths as int)) as Total_Deaths from CovidDeaths
where continent is not null
Group by location
order by Total_Deaths desc

--break up as per continent with highest death counts
Select location,  max(cast(total_deaths as int)) as Total_Deaths from CovidDeaths
where continent is null
Group by location
order by Total_Deaths desc

--Global Numbers deaths over cases
Select Date, Sum(new_cases) as Total_Cases, Sum(CAST(new_deaths as int)) as Total_deaths
From CovidDeaths
Where continent is not null
group by date
order by 1

--Global Numbers deaths over cases - Dates
Select Date, Sum(new_cases) as Total_Cases, Sum(CAST(new_deaths as int)) as Total_deaths, 
(Sum(CAST(new_deaths as int)) / Sum(new_cases))*100 as Total_Death_Per
From CovidDeaths
Where continent is not null
group by date
order by 3 Desc , 2 Desc

--Global Numbers deaths over cases
Select  Sum(new_cases) as Total_Cases, Sum(CAST(new_deaths as int)) as Total_deaths, 
(Sum(CAST(new_deaths as int)) / Sum(new_cases))*100 as Total_Death_Per
From CovidDeaths
Where continent is not null
--group by date


-- looking at total population vs vaccinations.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))  OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_vac
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
	where dea.continent is not null
	order by 2,3

--CTE
with pop_vac (continent, location, date, population, new_vaccinations, Rolling_vac)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))  OVER (Partition by dea.location order by dea.location, dea.date)as Rolling_vac
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
	where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_vac/population)*100  as RollingVacPerpopulation from pop_vac

