USE animal_shelter;

-- 1. COUNT: How many animals are in the shelter
SELECT COUNT(*) AS total_animals
FROM Animals;

-- 2. COUNT: Animals by adoption status
SELECT status, COUNT(*) AS count_per_status
FROM Animals
GROUP BY status;

-- 3. AVG: Average age of available animals
SELECT AVG(age) AS avg_age_available
FROM Animals
WHERE status = 'Available';

-- 4. COUNT: Number of animals in each species
SELECT s.name AS species_name, COUNT(a.animal_id) AS total_animals
FROM Species s
LEFT JOIN Animals a ON s.species_id = a.species_id
GROUP BY s.name;

-- 5. COUNT: How many adoptions each employee processed
SELECT e.name AS employee_name, COUNT(ad.adoption_id) AS total_adoptions
FROM Employees e
LEFT JOIN Adoptions ad ON e.employee_id = ad.employee_id
GROUP BY e.name;

-- 6. SUM: Total number of vaccines administered
SELECT COUNT(vv.vaccine_id) AS total_vaccines_given
FROM Visit_Vaccines vv;

-- 7. COUNT + GROUP BY: Most common vaccines
SELECT vac.name AS vaccine_name, COUNT(vv.vaccine_id) AS times_given
FROM Vaccines vac
LEFT JOIN Visit_Vaccines vv ON vac.vaccine_id = vv.vaccine_id
GROUP BY vac.name
ORDER BY times_given DESC;

-- 8. AVG: Average number of vaccines per visit
SELECT AVG(vaccine_count) AS avg_vaccines_per_visit
FROM (
    SELECT visit_id, COUNT(vaccine_id) AS vaccine_count
    FROM Visit_Vaccines
    GROUP BY visit_id
) AS subquery;

-- 9. HAVING: Employees who processed more than 1 adoption
SELECT e.name AS employee_name, COUNT(ad.adoption_id) AS total_adoptions
FROM Employees e
LEFT JOIN Adoptions ad ON e.employee_id = ad.employee_id
GROUP BY e.name
HAVING COUNT(ad.adoption_id) > 1;

-- 10. HAVING: Species with average age greater than 2 years
SELECT s.name AS species_name, AVG(a.age) AS avg_age
FROM Species s
JOIN Animals a ON s.species_id = a.species_id
GROUP BY s.name
HAVING AVG(a.age) > 2;
