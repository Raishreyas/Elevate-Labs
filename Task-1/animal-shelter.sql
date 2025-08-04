CREATE DATABASE IF NOT EXISTS animal_shelter;
USE animal_shelter;

-- Species Table
CREATE TABLE Species (
    species_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    breed VARCHAR(50)
);

-- Animals Table
CREATE TABLE Animals (
    animal_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    age INT,
    gender ENUM('Male', 'Female'),
    intake_date DATE,
    species_id INT,
    status ENUM('Available', 'Adopted', 'Under Treatment') DEFAULT 'Available',
    FOREIGN KEY (species_id) REFERENCES Species(species_id)
);

-- Adopters Table
CREATE TABLE Adopters (
    adopter_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT
);

-- Employees Table
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    role VARCHAR(50)
);

-- Adoptions Table
CREATE TABLE Adoptions (
    adoption_id INT PRIMARY KEY AUTO_INCREMENT,
    animal_id INT,
    adopter_id INT,
    employee_id INT,
    adoption_date DATE,
    FOREIGN KEY (animal_id) REFERENCES Animals(animal_id),
    FOREIGN KEY (adopter_id) REFERENCES Adopters(adopter_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Vaccines Table
CREATE TABLE Vaccines (
    vaccine_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    description TEXT
);

-- Vet Visits Table
CREATE TABLE Vet_Visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    animal_id INT,
    visit_date DATE,
    notes TEXT,
    FOREIGN KEY (animal_id) REFERENCES Animals(animal_id)
);

-- Linking Table: Vaccines Given in Vet Visit
CREATE TABLE Visit_Vaccines (
    visit_id INT,
    vaccine_id INT,
    PRIMARY KEY (visit_id, vaccine_id),
    FOREIGN KEY (visit_id) REFERENCES Vet_Visits(visit_id),
    FOREIGN KEY (vaccine_id) REFERENCES Vaccines(vaccine_id)
);
