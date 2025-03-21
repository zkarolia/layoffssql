-- Data cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates 
-- 2. Standardise the Data
-- 3. Null Values or Blank values
-- 4. Remove Any Columns 

-- Removing duplicates 

CREATE TABLE layoffs_staging
LIKE layoffs; 

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`) AS Row_Num
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE Row_Num > 1;


SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE Row_Num > 1;


CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging3;

INSERT INTO layoffs_staging3
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging3
WHERE ROW_NUM > 1;

DELETE
FROM layoffs_staging3
WHERE ROW_NUM > 1;

SELECT *
FROM layoffs_staging3;

-- Standardising data 

SELECT company, TRIM(company)
FROM layoffs_staging3; 

UPDATE layoffs_staging3
SET company = Trim(company);

SELECT *
FROM layoffs_staging3
Where industry LIKE 'crypto%';

UPDATE layoffs_staging3
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT country
FROM layoffs_staging3
WHERE country LIKE 'United states%';

SELECT DISTINCT country, TRIM(TRAILING'.'FROM country)
FROM layoffs_staging3
ORDER BY 1;

UPDATE layoffs_staging3
SET country = TRIM(TRAILING'.'FROM country)
WHERE country LIKE 'United States';

SELECT `date`, 
str_to_date(`date`,'%m/%d/%Y')
From layoffs_staging3;

UPDATE layoffs_staging3
SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;

-- Removing null 

UPDATE layoffs_staging3
SET industry = NULL 
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging3
WHERE INDUSTRY IS NULL
OR industry = ''; 

SELECT *
FROM layoffs_staging3
WHERE company = 'airbnb';

SELECT *
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry   
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Removing columns 

SELECT *
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;

-- Exploronatory data analysis

SELECT *
FROM layoffs_staging3;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging3;

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT company, sum(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging3;

SELECT industry, sum(total_laid_off)
FROM layoffs_staging3
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, sum(total_laid_off)
FROM layoffs_staging3
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging3
GROUP BY Year(`date`)
ORDER BY 1 DESC;

SELECT stage, sum(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 1 DESC;



    


