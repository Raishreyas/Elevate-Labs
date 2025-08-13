-- ==============================================
-- Task 6: Subqueries and Nested Queries
-- Objective: Practice scalar, IN, EXISTS, FROM, and nested aggregation subqueries
-- ==============================================

-- 1. Scalar Subquery in SELECT: Count vet visits for each animal
SELECT
    a.animal_id,
    a.name AS animal_name,
    (SELECT COUNT(*)
     FROM Vet_Visits vv
     WHERE vv.animal_id = a.animal_id) AS total_visits
FROM Animals a;

-- 2. Subquery in WHERE with IN: Animals that received "Rabies" vaccine
SELECT
    a.animal_id,
    a.name AS animal_name
FROM Animals a
WHERE a.animal_id IN (
    SELECT vv.animal_id
    FROM Vet_Visits vv
    JOIN Visit_Vaccines vvc ON vv.visit_id = vvc.visit_id
    JOIN Vaccines v ON vvc.vaccine_id = v.vaccine_id
    WHERE v.name = 'Rabies'
);

-- 3. Correlated Subquery with NOT EXISTS: Animals never adopted
SELECT
    a.animal_id,
    a.name AS animal_name
FROM Animals a
WHERE NOT EXISTS (
    SELECT 1
    FROM Adoptions ad
    WHERE ad.animal_id = a.animal_id
);

-- 4. Subquery in FROM (Derived Table): Vaccine usage count
SELECT
    v.name AS vaccine_name,
    counts.times_given
FROM Vaccines v
JOIN (
    SELECT
        vvc.vaccine_id,
        COUNT(*) AS times_given
    FROM Visit_Vaccines vvc
    GROUP BY vvc.vaccine_id
) counts ON v.vaccine_id = counts.vaccine_id;

-- 5. Nested Subquery with Aggregation: Most recently adopted animal
SELECT
    a.name AS animal_name,
    ad.adoption_date
FROM Animals a
JOIN Adoptions ad ON a.animal_id = ad.animal_id
WHERE ad.adoption_date = (
    SELECT MAX(adoption_date)
    FROM Adoptions
);
