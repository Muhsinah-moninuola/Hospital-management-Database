/*
Hospital group Database management system with multiple branches (clinics). 
Patients can book appointments in any branch, and sometimes be referred across branches 
if a specialty is not available locally.
*/

-- Create Database
CREATE DATABASE IF NOT EXISTS hospital_network
	CHARACTER SET utf8mb4
	COLLATE utf8mb4_unicode_ci;

USE hospital_network;

-- Clinics; Branches of the hospital group
CREATE TABLE IF NOT EXISTS clinics (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
	address TEXT NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- specialities table; medical fields, reusable across clinics/doctors)
CREATE TABLE IF NOT EXISTS specialties (
    id INT AUTO_INCREMENT PRIMARY KEY,      -- unique ID for each specialty
    name VARCHAR(100) NOT NULL UNIQUE,      -- e.g. "Cardiology", "Dermatology"
    description TEXT
) ENGINE=InnoDB;

-- Doctors; attached to a clinic, but can have multiple specialties(health care providers)
CREATE TABLE IF NOT EXISTS doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_id INT NOT NULL,                 -- doctor works mainly at this clinic
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Doctor's specialities; many-many relationship between doctors and specialities
CREATE TABLE IF NOT EXISTS doctor_specialties (
    doctor_id INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Patients who can visit any clinic in the hospital group (people booking appointments)
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100) UNIQUE,
    date_of_birth DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Appointments (patients book at clinics, linked to doctors)
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    clinic_id INT NOT NULL,                 -- clinic where appointment takes place
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Services, clinic-specific activity that describes what each clinic offers
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL DEFAULT 30,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Add service_id column to appointments table
ALTER TABLE appointments
ADD COLUMN service_id INT NOT NULL COMMENT 'Service booked for this appointment (e.g., consultation, vaccination)',
ADD CONSTRAINT fk_appointment_service
    FOREIGN KEY (service_id) REFERENCES services(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

--  Payments (multiple per appointment allowed)
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    method ENUM('Cash','Card','Transfer','Insurance') NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Prescriptions; records issued after appointments
CREATE TABLE IF NOT EXISTS prescriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medication VARCHAR(200) NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Medical Records (general notes/history per patient). This creates a Long-term health history per patient
CREATE TABLE IF NOT EXISTS medical_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NULL,
    record_date DATE NOT NULL,
    notes TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-------- Sample Data -------
-- Insert Clinics
INSERT INTO clinics (name, address, phone, email) VALUES
('Lagos Central Clinic', '12 Adeola Odeku St, Victoria Island, Lagos', '+2348012345678', 'lagos@hospitalgroup.com'),
('Abuja Specialist Clinic', '45 Aminu Kano Cres, Wuse II, Abuja', '+2348023456789', 'abuja@hospitalgroup.com'),
('Ibadan General Clinic', '30 Dugbe Market Rd, Ibadan, Oyo', '+2348034567890', 'ibadan@hospitalgroup.com');

-- Insert Specialties
INSERT INTO specialties (name, description) VALUES
('Cardiology', 'Heart and blood vessel specialists'),
('Pediatrics', 'Child health and medical care'),
('Dermatology', 'Skin, hair, and nail care'),
('Orthopedics', 'Bone, joint, and muscle care'),
('General Medicine', 'Primary care and general health');

-- Insert Doctors
INSERT INTO doctors (clinic_id, first_name, last_name, phone, email) VALUES
(1, 'Chinedu', 'Okafor', '+2348101111111', 'cokafor@hospitalgroup.com'),
(1, 'Aisha', 'Bello', '+2348102222222', 'abello@hospitalgroup.com'),
(2, 'Emeka', 'Umeh', '+2348103333333', 'eumeh@hospitalgroup.com'),
(2, 'Fatima', 'Suleiman', '+2348104444444', 'fsuleiman@hospitalgroup.com'),
(3, 'Babatunde', 'Adeyemi', '+2348105555555', 'badeyemi@hospitalgroup.com');

-- Doctor Specialities
INSERT INTO doctor_specialties (doctor_id, specialty_id) VALUES
(1, 1),
(2, 2),
(3, 3 ), (3, 5),
(4, 4),
(5, 5);

-- Insert Services (clinic-specific)
INSERT INTO services (clinic_id, name, description, duration_minutes, price) VALUES
(1, 'General Consultation', 'Basic health check with doctor', 30, 10000.00),
(1, 'Pediatric Checkup', 'Child medical check', 30, 12000.00),
(2, 'Dermatology Consultation', 'Skin care and treatment', 40, 15000.00),
(2, 'Orthopedic Consultation', 'Bone & joint care', 45, 18000.00),
(3, 'General Medicine', 'Routine health consultation', 30, 8000.00),
(3, 'Vaccination', 'Routine immunizations', 20, 3500.00);

-- Insert Patients
INSERT INTO patients (first_name, last_name, phone, email, date_of_birth) VALUES
('Oluwaseun', 'Adekunle', '+2347011111111', 'seun.adekunle@outlook.com', '1990-05-14'),
('Ngozi', 'Eze', '+2347022222222', 'ngozi.eze@gmail.com', '1985-08-20'),
('Ibrahim', 'Lawal', '+2347033333333', 'ibrahim.lawal@yahoo.com', '2000-12-02'),
('Funke', 'Olatunji', '+2347044444444', 'funke.olatunji@outlook.com', '1995-03-25'),
('Samuel', 'Okon', '+2347055567455', 'samuel.okon@gmail.com', '1988-07-10');

-- Insert Appointments
INSERT INTO appointments (patient_id, doctor_id, clinic_id, appointment_date, status, notes, service_id) VALUES
(1, 1, 1, '2025-09-25 10:00:00', 'Scheduled', 'Chest pain consultation', 1),
(2, 2, 1,  '2025-09-26 09:30:00', 'Completed', 'Child fever follow-up', 2),
(3, 3, 2,  '2025-09-26 14:00:00', 'Scheduled', 'Skin rash diagnosis', 3),
(4, 4, 2,  '2025-09-27 11:00:00', 'Scheduled', 'Knee pain check', 4),
(5, 5, 3,  '2025-09-27 15:00:00', 'Completed', 'General health screening', 5);

-- Insert Payments (multiple per appointment allowed)
INSERT INTO payments (appointment_id, amount, method) VALUES
(1, 5000.00, 'Transfer'), 
(1, 5000.00, 'Cash'), -- Seun split his ₦10,000 bill
(2, 12000.00, 'Insurance'), -- Ngozi fully covered
(3, 7500.00, 'Card'), 
(3, 7500.00, 'Cash'), -- Ibrahim paid in two parts
(5, 8000.00, 'Cash');

-- Insert Medical Records
INSERT INTO medical_records (patient_id, appointment_id, record_date, notes) VALUES
(1, 1, '2025-09-25', 'Patient reported chest pain. ECG scheduled.'),
(2, 2, '2025-09-26', 'Child had mild fever, responded to paracetamol.'),
(3, 3, '2025-09-26', 'Skin rash under review, possible eczema.'),
(5, 5, '2025-09-27', 'Routine health screening completed. Normal results.');

-- querying the db
SELECT a.id, p.first_name, p.last_name, d.first_name AS doctor, s.name AS service, a.appointment_date
FROM appointments a
JOIN patients p ON a.patient_id = p.id
JOIN doctors d ON a.doctor_id = d.id
JOIN services s ON a.service_id = s.id
WHERE a.clinic_id = 1
ORDER BY a.appointment_date;


 
