# Hospital Network Database (MySQL)

## Overview
This project implements a **relational database** for managing hospital operations across multiple clinics/branches.  

The database supports:  
- **Patients** → demographics & contact info  
- **Doctors** → staff info, linked to multiple clinics and specialties  
- **Clinics** → hospital branches with services offered  
- **Services** → medical services offered (consultations, vaccinations, etc.)  
- **Appointments** → booking system linking patients, doctors, clinics, and services  
- **Payments** → financial tracking per appointment (supports partial/multiple payments)  
- **Prescriptions** → medicines issued after appointments  
- **Medical Records** → historical clinical notes per patient  

This design allows **scalability** (multiple branches), **data integrity** (constraints), and **realistic hospital workflows**.

---

## Database Details

### Database
```sql
CREATE DATABASE hospital_network;
```

## Core Tables & Relationships

1. patients
Stores patient demographic info.
Related to: appointments, medical_records.

2. doctors
Stores doctor info.
Linked to clinics (many-to-many via doctor_clinics)
Linked to specialties (many-to-many via doctor_specialties).

3. clinics
Represents hospital branches.
Related to: doctors, services, appointments.

4. services
Lists medical services (consultation, vaccination, etc.).
Each appointment must reference one service.

5. appointments
Core entity of the system.
Links patient, doctor, clinic, and service.
Related to: payments, prescriptions.

6. payments
Tracks payments for appointments.
Supports partial payments → multiple rows per appointment.

7. prescriptions
Issued after appointments.
Tied to both doctor and patient.

8. medical_records
Stores general clinical notes/history for patients.

## Relationships Summary
**One-to-Many**
- clinic → doctor_clinics
- doctor → appointments
- patient → appointments
- appointment → payments
- patient → medical_records

**Many-to-Many**
- doctors ↔ clinics via doctor_clinics
- doctors ↔ specialties via doctor_specialties

## Referential Integrity

ON DELETE RESTRICT → prevents deleting critical parents if children exist (e.g., can’t delete a service used in appointments).

ON DELETE CASCADE → automatically deletes dependent mappings (e.g., doctor is removed → their clinic associations vanish).

ON UPDATE CASCADE → keeps foreign keys in sync when parent IDs change.

## Setup Instructions

1. Clone Repository
```bash
git clone https://github.com/Muhsinah-moninuola/Hospital-management-Database/tree/main
cd hospital-management-Database
```

2. Run SQL Script
```bash
mysql -u root -p < hospital-management-DBMS.sql
```

3. Verify Database

```sql
SHOW DATABASES;
USE hospital_network;
SHOW TABLES;
```

4. Insert Sample Data
```sql
INSERT INTO patients (first_name, last_name, dob, gender, phone)
VALUES ('Chinonso', 'Okafor', '1990-03-14', 'M', '08031234567');
```

5. Example Query

```sql
Retrieve all upcoming appointments for a clinic:

SELECT a.id, p.first_name, p.last_name, d.first_name AS doctor, s.name AS service, a.appointment_date
FROM appointments a
JOIN patients p ON a.patient_id = p.id
JOIN doctors d ON a.doctor_id = d.id
JOIN services s ON a.service_id = s.id
WHERE a.clinic_id = 1
ORDER BY a.appointment_date;
```

## Features
- Normalized schema with constraints (PK, FK, NOT NULL, UNIQUE).
- Supports multi-branch hospital operations.
- Scalable design for future entities (lab tests, referrals, insurance).
- Built on MySQL (InnoDB, utf8mb4).
