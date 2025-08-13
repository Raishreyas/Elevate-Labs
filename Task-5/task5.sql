USE animal_shelter;

-- 1) INNER JOIN: Animals with their species info
SELECT a.name AS animal_name, s.name AS species_name, s.breed
FROM Animals a
INNER JOIN Species s ON a.species_id = s.species_id;

-- 2) INNER JOIN: Adoptions with animal and adopter names
SELECT ad.adoption_id, ani.name AS animal_name, adopt.name AS adopter_name, ad.adoption_date
FROM Adoptions ad
INNER JOIN Animals ani ON ad.animal_id = ani.animal_id
INNER JOIN Adopters adopt ON ad.adopter_id = adopt.adopter_id;

-- 3) LEFT JOIN: All animals and adoption details (including not adopted)
SELECT a.name AS animal_name, ad.adoption_date, adopt.name AS adopter_name
FROM Animals a
LEFT JOIN Adoptions ad ON a.animal_id = ad.animal_id
LEFT JOIN Adopters adopt ON ad.adopter_id = adopt.adopter_id
ORDER BY a.name;

-- 4) RIGHT JOIN: All adopters and the animals they adopted (include adopters with no adoptions)
SELECT adopt.name AS adopter_name, ani.name AS animal_name, ad.adoption_date
FROM Adoptions ad
RIGHT JOIN Adopters adopt ON ad.adopter_id = adopt.adopter_id
LEFT JOIN Animals ani ON ad.animal_id = ani.animal_id
ORDER BY adopt.name;

-- 5) FULL OUTER JOIN (emulated with LEFT + RIGHT JOIN and UNION)
SELECT a.name AS animal_name, ad.adoption_date
FROM Animals a
LEFT JOIN Adoptions ad ON a.animal_id = ad.animal_id
UNION
SELECT a.name AS animal_name, ad.adoption_date
FROM Animals a
RIGHT JOIN Adoptions ad ON a.animal_id = ad.animal_id;

-- 6) LEFT JOIN: Vet visits with animal details (include animals without visits)
SELECT a.name AS animal_name, v.visit_date, v.notes
FROM Animals a
LEFT JOIN Vet_Visits v ON a.animal_id = v.animal_id
ORDER BY a.name, v.visit_date;

-- 7) INNER JOIN: Vaccines given in each visit
SELECT a.name AS animal_name, v.visit_date, vac.name AS vaccine_name
FROM Animals a
INNER JOIN Vet_Visits v ON a.animal_id = v.animal_id
INNER JOIN Visit_Vaccines vv ON v.visit_id = vv.visit_id
INNER JOIN Vaccines vac ON vv.vaccine_id = vac.vaccine_id
ORDER BY a.name, v.visit_date, vaccine_name;
