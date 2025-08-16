-- ==============================================
-- Task 7: Creating Views
-- Objective: Learn to create and use views
-- ==============================================

-- 1. View: Animals with their Species
CREATE VIEW AnimalSpecies AS
SELECT
    a.animal_id,
    a.name AS animal_name,
    a.age,
    a.gender,
    a.status,
    s.name AS species_name,
    s.breed
FROM Animals a
JOIN Species s ON a.species_id = s.species_id;

-- Usage:
SELECT * FROM AnimalSpecies WHERE status = 'Available';


-- 2. View: Adoption details with adopter and employee info
CREATE VIEW AdoptionDetails AS
SELECT
    ad.adoption_id,
    a.name AS animal_name,
    ap.name AS adopter_name,
    e.name AS employee_name,
    ad.adoption_date
FROM Adoptions ad
JOIN Animals a ON ad.animal_id = a.animal_id
JOIN Adopters ap ON ad.adopter_id = ap.adopter_id
JOIN Employees e ON ad.employee_id = e.employee_id;

-- Usage:
SELECT * FROM AdoptionDetails ORDER BY adoption_date DESC;


-- 3. View: Vet visits with vaccines given
CREATE VIEW VisitDetails AS
SELECT
    vv.visit_id,
    a.name AS animal_name,
    vv.visit_date,
    v.name AS vaccine_name,
    v.description AS vaccine_info,
    vv.notes
FROM Vet_Visits vv
JOIN Animals a ON vv.animal_id = a.animal_id
LEFT JOIN Visit_Vaccines vvc ON vv.visit_id = vvc.visit_id
LEFT JOIN Vaccines v ON vvc.vaccine_id = v.vaccine_id;

-- Usage:
SELECT * FROM VisitDetails WHERE vaccine_name IS NOT NULL;


-- 4. View: Available animals ready for adoption (abstracted filter)
CREATE VIEW AvailableAnimals AS
SELECT
    animal_id,
    name AS animal_name,
    age,
    gender,
    status
FROM Animals
WHERE status = 'Available';

-- Usage:
SELECT * FROM AvailableAnimals;


-- 5. View: Vaccination summary (count how many times each vaccine was used)
CREATE VIEW VaccineUsage AS
SELECT
    v.name AS vaccine_name,
    COUNT(vvc.vaccine_id) AS times_given
FROM Vaccines v
LEFT JOIN Visit_Vaccines vvc ON v.vaccine_id = vvc.vaccine_id
GROUP BY v.vaccine_id;

-- Usage:
SELECT * FROM VaccineUsage ORDER BY times_given DESC;
