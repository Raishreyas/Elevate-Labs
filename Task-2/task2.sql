USE animal_shelter;

-- INSERT: Species
INSERT INTO Species (name, breed) VALUES
('Dog', 'Labrador'),
('Dog', 'Beagle'),
('Cat', 'Persian'),
('Cat', 'Siamese');

-- INSERT: Animals
INSERT INTO Animals (name, age, gender, intake_date, species_id, status) VALUES
('Buddy', 3, 'Male', '2025-07-01', 1, 'Available'),
('Luna', 2, 'Female', '2025-07-03', 3, 'Available'),
('Charlie', 4, 'Male', '2025-07-05', 2, 'Under Treatment'),
('Milo', NULL, 'Male', '2025-07-07', 4, 'Available'), -- Age unknown (NULL)
('Bella', 1, 'Female', '2025-07-09', 1, 'Adopted');

-- INSERT: Adopters
INSERT INTO Adopters (name, phone, email, address) VALUES
('Alice Singh', '9876543210', 'alice@example.com', '22 Green St'),
('Ravi Kumar', '9998887777', 'ravi@example.com', '19 Blue Rd');

-- INSERT: Employees
INSERT INTO Employees (name, role) VALUES
('Dr. Sharma', 'Veterinarian'),
('Neha Das', 'Adoption Officer');

-- INSERT: Adoptions
INSERT INTO Adoptions (animal_id, adopter_id, employee_id, adoption_date) VALUES
(5, 1, 2, '2025-08-01'); -- Bella adopted by Alice

-- INSERT: Vaccines
INSERT INTO Vaccines (name, description) VALUES
('Rabies', 'Rabies vaccination'),
('Distemper', 'Canine distemper vaccine'),
('Parvovirus', 'Canine parvo vaccine');

-- INSERT: Vet Visits
INSERT INTO Vet_Visits (animal_id, visit_date, notes) VALUES
(3, '2025-08-01', 'High fever and vomiting'),
(1, '2025-08-03', 'Routine checkup');

-- INSERT: Visit Vaccines (junction table)
INSERT INTO Visit_Vaccines (visit_id, vaccine_id) VALUES
(1, 1),  -- Charlie received Rabies
(1, 3),  -- Charlie received Parvovirus
(2, 2);  -- Buddy received Distemper

-- UPDATE: Fix missing age for Milo
UPDATE Animals
SET age = 2
WHERE name = 'Milo';

-- UPDATE: Mark Buddy as Adopted
UPDATE Animals
SET status = 'Adopted'
WHERE name = 'Buddy';

-- DELETE: Remove an adopter who withdrew application
DELETE FROM Adopters
WHERE name = 'Ravi Kumar';

-- DELETE: Delete vet visit by mistake (soft error)
DELETE FROM Vet_Visits
WHERE visit_id = 2;
