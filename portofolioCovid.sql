
--covid 19 sudah terjadi hampir 2 tahun di beberapa negara, kasus baru yang bermunculan hingga kasus kematian yang saat ini masih naik turun.
--upaya-upaya yang dilakukan di beberapa negara untuk mencegah infeksi virus tersebut salah satunya adalah vaksinasi. covid 19 sangat berdampak
--untuk dunia dari semua aspek . pada kali ini terdapat data covid 19 di dunia yang terdiri dari 2 table yaitu table CovidDeaths dan
--tabel CovidVaccinasi yang diperoleh dari sumber https://ourworldindata.org/covid-deaths,
--dari data tersebut akan dilakukan analisis untuk mendapatkan insight yang bermanfaat.

--1. dimana lokasi yang paling banyak kasus covid 19 dari yang terbesar ke yang terkecil?
select location, sum(cast(total_deaths as int)) as total_terbanyak
from PortofolioProject..CovidDeaths
group by location
order by total_terbanyak desc;
--jawab: lokasi paling banyak terkena kasus covid adalah world yaitu 1327174456.

--2. berapa persen total kematian dari total kasus berdasarkan lokasi?
select location, sum(total_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, (sum(cast(total_deaths as int)))/(sum(total_cases))*100 as percent_CasesOfDeaths
from PortofolioProject..CovidDeaths
group by location
order by location;

--3. jumlah lokasi, jumlah continent.
select count(distinct location) as jumlah_lokasi, count(distinct continent) as jumlah_continent
from PortofolioProject..CovidDeaths;
--jawab: lokasi = 233, continent=6

--4. jumlah populasi per lokasi.
select location, sum(population) as jmlPopBasedOnLoc
from PortofolioProject..CovidDeaths
where location not in ('World', 'Europen Union', 'International')
group by location
order by 2 desc;

--5. jumlah populasi per continent
select continent, sum(population) as jmlPopBasedOncont
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc;

--6. berapa persentase terbesar banyaknya kasus dari jumlah populasi berdasarkan lokasi.
select location, sum(population) as jumPopulasi, sum(total_cases) as total_cases, (sum(total_cases)/sum(population))*100 as persentaseTotalCases
from PortofolioProject..CovidDeaths
group by location, population
order by persentaseTotalCases desc;
--persentase terbesar adalah Andorra dengan jumlah populasi 47185940 dan total cases 4671839 yaitu 9,9%

select continent, location, population, date, new_cases, total_cases
from PortofolioProject..CovidDeaths
where new_cases is not null and total_cases is not null
order by new_cases;

--7. berapa persen total kematian dari jumlah populasi berdasarkan lokasi?
select location, sum(population) as jumPopulasi, sum(cast(total_deaths as int)) as total_deaths, (sum(cast(total_deaths as int)))/(sum(population))*100 as percent_DeathsOfPop
from PortofolioProject..CovidDeaths
group by location
order by percent_DeathsOfPop desc;

--8. lokasi mana yang jumlah kematianya paling terbesar?
select location, max(cast(total_deaths as int)) as totalTertinggi
from PortofolioProject..CovidDeaths
where location not in ('world', 'Europe', 'Asia', 'North America', 'South America', 'European Union', 'United States')
group by location
order by totalTertinggi desc;
--berdasarkan data, angka kematian tertinggi ada pada brazil yaitu 607922.

--9. looking for new cases and new deaths and percentation of new deaths
select date, sum(new_cases), sum(cast(new_deaths as int)), ((sum(cast(new_deaths as int)))/(sum(new_cases)))*100 as percenOfnewDeaths
from PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--10. showing continent with highest deadth
select continent, max(cast(total_deaths as int)) as highestDeatCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by highestDeatCount desc
-- jawab : nilai kematian tertinggi ada pada North America yaitu sebesr 747057.

--11. menampilkan populasi dan jumlah vaksinasi
select dea.location, sum(dea.population) as jumPopulasi, sum(cast(vac.total_vaccinations as float)) as JumVaksinasi
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccination vac
on dea.location = vac.location
group by dea.location
order by 2,3;

--12. looking for population vs total_vaccination
--with CTE
with PopvsVac (continent, location, population, date, new_vaccinations, totalnewVac)
as(
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as totalnewVac
--, (totalLoocVacc/dea.population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select * , (totalnewVac/population)*100 as percentVacPop from PopvsVac

--fungsi over partition by adl untuk memisahkan hasil nilai agregate berdasarkan suatu kolom tertentu.

--13. TEMPORARY TABLE / TABLE SEMENTARA----------
create table percentPopVac
(continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
percentVacPop numeric)
--memasukan data ke table sementara percentPopVac
insert into percentPopVac
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as totalnewVac
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * , (percentVacPop/population)*100 as perPopVac from percentPopVac

select * from percentPopVac

--14. CREATE VIEW FOR TO STORE DTA FOR LATER VISUALIZATION
create view viewpercentPopVac1 as
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as totalnewVac
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from viewpercentPopVac

--15. menampilkan jumlah kasus berdasarkan lokasinya
select location, sum(new_cases) as totalCases
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by totalCases desc;

--16. jumlah kasus perbenua
select continent, sum(new_cases) as totalCases
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by totalCases desc;

--17. kasus kematian tertinggi perbenua
select continent, sum(cast(new_deaths as int)) as totalDeaths
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by totalDeaths desc;

--18. total kematian berdasarkan lokasi
select location, sum(cast(new_deaths as float)) as DeathsPerLocation
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by DeathsPerLocation desc;

--19. total cases total kematian setiap harinya berdasarkan tanggal lokasi di benua asia
select location, date, sum(new_cases) as newCases, sum(cast(new_deaths as float)) as newDeaths
from PortofolioProject..CovidDeaths
where continent in ('Asia')
group by location, date
order by date asc;

--20. populasi and total cases and total deaths berdasakan lokasinya
select location, sum(new_cases) as jmlCases, sum(cast(new_deaths as int)) as jmlDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as percentageDeathsOfCases
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by percentageDeathsOfCases desc;

--21. percentage total vaccination of population
select dea.location, dea.population, sum(cast(vac.new_vaccinations as float)) as total_vaccination, (sum(cast(vac.new_vaccinations as float))/dea.population)*100 as percentageVacOfPop
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccination vac
on dea.location = vac.location
where vac.new_vaccinations is not null
group by dea.population, dea.location
order by percentageVacOfPop desc;

--22. lokasi, new cases, and date
select location, cast(date as date) as date, new_cases from PortofolioProject..CovidDeaths
where date > '2020-12-31' and date < '2021-11-01' and continent is not null

select dea.population, dea.location, vac.date, vac.new_vaccinations, vac.total_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccination vac
on dea.date = vac.date
order by dea.location;

select distinct location from PortofolioProject..CovidDeaths
order by location ;

select distinct continent from PortofolioProject..CovidDeaths
order by continent asc;

