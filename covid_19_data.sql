DROP DATABASE IF EXISTS covid_19;

CREATE DATABASE covid_19;

\c covid_19;

CREATE TABLE IF NOT EXISTS covid_19_data (
    serialNumber int,
    observationDate date, 
    province varchar, 
    country varchar,
    lastUpdate timestamp,
    confirmed int,
    deaths int,
    recovered int
);


-- Retrieve the total confirmed, death, and recovered cases.
SELECT
  SUM("confirmed") as total_confirmed_cases,
  SUM("deaths") as total_deaths_cases,
  SUM("recovered") as total_recovered_cases
FROM covid_19_data


-- Retrieve the total confirmed, deaths and recovered cases for the first quarter
-- of each year of observation.
SELECT
  SUM("confirmed") as total_confirmed_cases,
  SUM("deaths") as total_deaths_cases,
  SUM("recovered") as total_recovered_cases,
	EXTRACT('year' FROM "observationDate") as year
FROM covid_19_data
WHERE EXTRACT('month' FROM "observationDate") <= 3 GROUP BY year


-- information for each country:
-- ● The total number of confirmed cases
-- ● The total number of deaths
-- ● The total number of recoveries
SELECT
	country,
  SUM("confirmed") as total_confirmed_cases,
  SUM("deaths") as total_deaths_cases,
  SUM("recovered") as total_recovered_cases
FROM covid_19_data
GROUP BY country
ORDER BY country ASC


-- Retrieve the percentage increase in the number of death cases from 2019 to 2020.
SELECT
  year_2019, year_2020, (((year_2020 - year_2019)/year_2019) * 100) as percentage_difference
FROM (
  SELECT
    SUM(CASE WHEN extract(year FROM "observationDate") = 2019 THEN deaths END) as year_2019,
    SUM(CASE WHEN extract(year FROM "observationDate") = 2020 THEN deaths END) as year_2020
  FROM covid_19_data
  ) subq


-- Retrieve information for the top 5 countries with the highest confirmed cases.
SELECT
  country,
  SUM("confirmed") as total_confirmed_cases 
FROM covid_19_data
GROUP BY country
ORDER BY total_confirmed_cases DESC LIMIT 5


-- Compute the total number of drop (decrease) or increase in the confirmed cases from month to
-- month in the 2 years of observation.
SELECT
  year, month, total_confirmed_cases,
  LEAD(total_confirmed_cases) OVER () - total_confirmed_cases AS new_column_total_confirmed,
  CASE WHEN LEAD(total_confirmed_cases) OVER () - total_confirmed_cases > 0 THEN
  'INCREASE' ELSE 'DECREASE' END AS output
FROM(
  SELECT
    extract(year FROM "observationDate") AS year,
    extract(month FROM "observationDate") AS month,
  	SUM("confirmed") AS total_confirmed_cases
  FROM covid_19_data
  GROUP BY year, month
  ORDER BY year, month ASC
  )subq
