## Task 1
CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

## Task 2
DROP TABLE IF EXISTS disease_stats;
DROP TABLE IF EXISTS entity;

CREATE TABLE entity (
    id     INT PRIMARY KEY
        AUTO_INCREMENT,
    name   VARCHAR(255),
    code   VARCHAR(10)
);

CREATE TABLE disease_stats (
    stat_id              INT PRIMARY KEY
        AUTO_INCREMENT,
    entity_id            INT,
    year                 INT,
    number_yaws          FLOAT,
    polio_cases          FLOAT,
    cases_guinea_worm    FLOAT,
    number_rabies        FLOAT,
    number_malaria       FLOAT,
    number_hiv           FLOAT,
    number_tuberculosis  FLOAT,
    number_smallpox      FLOAT,
    number_cholera_cases INT,
    FOREIGN KEY (entity_id) REFERENCES entity(id)
);

INSERT INTO entity (name, code)
SELECT DISTINCT Entity, Code FROM infectious_cases;

INSERT INTO disease_stats (
    entity_id,
    year,
    number_yaws,
    polio_cases,
    cases_guinea_worm,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases
)
SELECT
    entity.id,
    raw.Year,
    raw.Number_yaws,
    raw.polio_cases,
    raw.cases_guinea_worm,
    raw.Number_rabies,
    raw.Number_malaria,
    raw.Number_hiv,
    raw.Number_tuberculosis,
    raw.Number_smallpox,
    raw.Number_cholera_cases
FROM infectious_cases AS raw
JOIN entity ON raw.Entity = entity.name AND raw.Code = entity.code;

## Task 3
SELECT
    entity.name           AS entity,
    entity.code           AS code,
    AVG(ds.number_rabies) AS average_number_rabies,
    MIN(ds.number_rabies) AS min_number_rabies,
    MAX(ds.number_rabies) AS max_number_rabies,
    SUM(ds.number_rabies) AS sum_number_rabies
FROM entity
JOIN disease_stats ds ON entity.id = ds.entity_id
WHERE ds.number_rabies IS NOT NULL AND ds.number_rabies != ''
GROUP BY entity.name, entity.code
ORDER BY average_number_rabies DESC
LIMIT 10;

## Task 4
SELECT
    year,
    CONCAT(year, '-01-01') AS start_year_date,
    CURDATE() AS current_year,
    TIMESTAMPDIFF(year, CONCAT(year, '-01-01'), CURDATE()) AS year_difference
FROM disease_stats;

## Task 5
DELIMITER //
DROP FUNCTION IF EXISTS YEAR_DIFFERENCE;
CREATE FUNCTION YEAR_DIFFERENCE(input_year INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE start_date DATE;
    DECLARE year_diff INT;

    SET start_date = CONCAT(input_year, '-01-01');
    SET year_diff = TIMESTAMPDIFF(YEAR, start_date, CURDATE());

    RETURN year_diff;
END//
DELIMITER ;

SELECT
    year,
    CONCAT(year, '-01-01') AS start_year_date,
    CURDATE() AS current_year,
    YEAR_DIFFERENCE(year) AS year_difference
FROM disease_stats;

