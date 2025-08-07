USE animal_shelter;

-- 1. SELECT all columns from the Animals table
SELECT * FROM Animals;

-- 2. SELECT specific columns (name, age, status)
SELECT name, age, status FROM Animals;

-- 3. SELECT all animals that are still available for adoption
SELECT name, age FROM Animals
WHERE status = 'Available';

-- 4. SELECT all animals between 2 and 4 years old
SELECT name, age FROM Animals
WHERE age BETWEEN 2 AND 4;

-- 5. SELECT animals with name starting with 'B'
SELECT * FROM Animals
WHERE name LIKE 'B%';

-- 6. SELECT all male animals older than 2 years
SELECT name, gender, age FROM Animals
WHERE gender = 'Male' AND age > 2;

-- 7. SELECT all animals of species 'Dog'
SELECT a.name, s.name AS species_name, s.breed
FROM Animals a
JOIN Species s ON a.species_id = s.species_id
WHERE s.name = 'Dog';

-- 8. SELECT all adoptions with animal and adopter names
SELECT adop.adoption_date, ani.name AS animal_name, adp.name AS adopter_name
FROM Adoptions adop
JOIN Animals ani ON adop.animal_id = ani.animal_id
JOIN Adopters adp ON adop.adopter_id = adp.adopter_id;

-- 9. SELECT all vet visits for animal named 'Charlie'
SELECT v.visit_date, v.notes
FROM Vet_Visits v
JOIN Animals a ON v.animal_id = a.animal_id
WHERE a.name = 'Charlie';

-- 10. List top 2 youngest animals available for adoption
SELECT name, age FROM Animals
WHERE status = 'Available'
ORDER BY age ASC
LIMIT 2;

-- 11. SELECT animals who have never been adopted
SELECT name FROM Animals
WHERE animal_id NOT IN (
    SELECT animal_id FROM Adoptions
);

-- 12. SELECT all animals and their vaccine names (if any)
SELECT a.name AS animal_name, v.visit_date, vac.name AS vaccine_name
FROM Animals a
JOIN Vet_Visits v ON a.animal_id = v.animal_id
JOIN Visit_Vaccines vv ON v.visit_id = vv.visit_id
JOIN Vaccines vac ON vv.vaccine_id = vac.vaccine_id
ORDER BY a.name;
