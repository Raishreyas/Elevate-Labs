-- ======================================================
-- Task 8: Stored Procedures and Functions
-- ======================================================

-- 1. Stored Procedure: Register a new animal
DELIMITER //
CREATE PROCEDURE RegisterAnimal(
    IN p_name VARCHAR(100),
    IN p_age INT,
    IN p_gender VARCHAR(10),
    IN p_species_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Animals (name, age, gender, species_id, status)
    VALUES (p_name, p_age, p_gender, p_species_id, p_status);
END //
DELIMITER ;

-- Usage:
CALL RegisterAnimal('Charlie', 2, 'Male', 1, 'Available');


-- 2. Stored Procedure: Record Adoption
DELIMITER //
CREATE PROCEDURE RecordAdoption(
    IN p_animal_id INT,
    IN p_adopter_id INT,
    IN p_employee_id INT,
    IN p_adoption_date DATE
)
BEGIN
    -- Insert into Adoptions
    INSERT INTO Adoptions (animal_id, adopter_id, employee_id, adoption_date)
    VALUES (p_animal_id, p_adopter_id, p_employee_id, p_adoption_date);

    -- Update animal status
    UPDATE Animals
    SET status = 'Adopted'
    WHERE animal_id = p_animal_id;
END //
DELIMITER ;

-- Usage:
CALL RecordAdoption(1, 2, 1, CURDATE());


-- 3. Function: Calculate animal age category
DELIMITER //
CREATE FUNCTION GetAgeCategory(p_age INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE category VARCHAR(20);
    IF p_age < 1 THEN
        SET category = 'Infant';
    ELSEIF p_age BETWEEN 1 AND 3 THEN
        SET category = 'Young';
    ELSEIF p_age BETWEEN 4 AND 7 THEN
        SET category = 'Adult';
    ELSE
        SET category = 'Senior';
    END IF;
    RETURN category;
END //
DELIMITER ;

-- Usage in query:
SELECT name, age, GetAgeCategory(age) AS age_group
FROM Animals;


-- 4. Function: Count total adoptions by adopter
DELIMITER //
CREATE FUNCTION AdoptionCount(p_adopter_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Adoptions
    WHERE adopter_id = p_adopter_id;
    RETURN total;
END //
DELIMITER ;

-- Usage:
SELECT name, AdoptionCount(adopter_id) AS total_adoptions
FROM Adopters;