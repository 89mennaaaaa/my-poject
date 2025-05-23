
DROP DATABASE IF EXISTS clinic_management;


CREATE DATABASE clinic_management;
USE clinic_management;

CREATE TABLE DEPARTMENT (
    Department_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE PATIENT (
    Patient_ID INT PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Gender CHAR(1),
    Date_of_Birth DATE,
    Address VARCHAR(255),
    Job VARCHAR(100)
);

CREATE TABLE DOCTOR (
    Doctor_ID INT PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Specialty VARCHAR(100),
    Phone VARCHAR(15),
    Address VARCHAR(255),
    Department_ID INT,
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID)
);

CREATE TABLE CLINIC (
    Clinic_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(255),
    Department_ID INT,
    FOREIGN KEY (Department_ID) REFERENCES DEPARTMENT(Department_ID)
);

CREATE TABLE CLINIC_DOCTOR (
    Clinic_ID INT,
    Doctor_ID INT,
    PRIMARY KEY (Clinic_ID, Doctor_ID),
    FOREIGN KEY (Clinic_ID) REFERENCES CLINIC(Clinic_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES DOCTOR(Doctor_ID)
);

CREATE TABLE APPOINTMENT (
    Appointment_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_ID INT,
    Clinic_ID INT,
    Appointment_Date DATE,
    Start_Time TIME,
    End_Time TIME,
    Status VARCHAR(20),
    Diagnosis VARCHAR(255),
    Cost DECIMAL(10,2),
    FOREIGN KEY (Patient_ID) REFERENCES PATIENT(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES DOCTOR(Doctor_ID),
    FOREIGN KEY (Clinic_ID) REFERENCES CLINIC(Clinic_ID)
);

CREATE TABLE MEDICAL_RECORD (
    Record_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_ID INT,
    Diagnosis VARCHAR(255),
    Treatment TEXT,
    Record_Date DATE,
    FOREIGN KEY (Patient_ID) REFERENCES PATIENT(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES DOCTOR(Doctor_ID)
);


DELIMITER //
CREATE TRIGGER trg_set_record_date
BEFORE INSERT ON MEDICAL_RECORD
FOR EACH ROW
BEGIN
    SET NEW.Record_Date = CURRENT_DATE;
END;
//
DELIMITER ;


INSERT INTO DEPARTMENT (Department_ID, Name) VALUES
(1, 'Cardiology'),
(2, 'Dermatology'),
(3, 'Neurology'),
(4, 'Orthopedics'),
(5, 'Pediatrics'),
(6, 'Oncology'),
(7, 'Ophthalmology'),
(8, 'ENT'),
(9, 'Psychiatry'),
(10, 'Gastroenterology');


INSERT INTO PATIENT (Patient_ID, First_Name, Last_Name, Gender, Date_of_Birth, Address, Job) VALUES
(12527, 'Ali', 'Ahmed', 'M', '1990-05-10', 'Cairo', 'Engineer'),
(12528, 'Sara', 'Mohamed', 'F', '1985-09-15', 'Giza', 'Teacher'),
(12529, 'Mohamed', 'Ibrahim', 'M', '1975-11-22', 'Alex', 'Driver'),
(12530, 'Nour', 'Samir', 'F', '1992-08-01', 'Tanta', 'Nurse'),
(12531, 'Hossam', 'Tarek', 'M', '1988-06-19', 'Fayoum', 'Designer'),
(12532, 'Fatma', 'Younis', 'F', '1995-03-25', 'Aswan', 'Pharmacist'),
(12533, 'Omar', 'Fathy', 'M', '1999-12-02', 'Luxor', 'Student'),
(12534, 'Mariam', 'Saleh', 'F', '1993-04-14', 'Zagazig', 'Accountant'),
(12535, 'Khaled', 'Nabil', 'M', '1987-07-17', 'Ismailia', 'Plumber'),
(12536, 'Laila', 'Hassan', 'F', '2000-01-30', 'Mansoura', 'HR Specialist');


INSERT INTO DOCTOR (Doctor_ID, First_Name, Last_Name, Specialty, Phone, Address, Department_ID) VALUES
(2001, 'Hany', 'Said', 'Cardiology', '0100000001', 'Heliopolis', 1),
(2002, 'Mona', 'Youssef', 'Dermatology', '0100000002', 'Dokki', 2),
(2003, 'Yasser', 'Ali', 'Neurology', '0100000003', 'Nasr City', 3),
(2004, 'Dina', 'Kamal', 'Orthopedics', '0100000004', 'Zamalek', 4),
(2005, 'Tamer', 'Fathy', 'Pediatrics', '0100000005', 'Giza', 5),
(2006, 'Aya', 'Magdy', 'Oncology', '0100000006', 'October', 6),
(2007, 'Khaled', 'Omar', 'Ophthalmology', '0100000007', 'Helwan', 7),
(2008, 'Sherif', 'Mahmoud', 'ENT', '0100000008', 'Ain Shams', 8),
(2009, 'Heba', 'Lotfy', 'Psychiatry', '0100000009', 'Tagamoa', 9),
(2010, 'Samir', 'Hassan', 'Gastroenterology', '0100000010', 'Abbassia', 10);


INSERT INTO CLINIC (Clinic_ID, Name, Location, Department_ID) VALUES
(3001, 'Heart Center', 'Nasr City', 1),
(3002, 'Skin Clinic', 'Maadi', 2),
(3003, 'Brain Care', 'Zamalek', 3),
(3004, 'Bone Clinic', '6 October', 4),
(3005, 'Kids Clinic', 'Tagamoa', 5),
(3006, 'Cancer Center', 'Heliopolis', 6),
(3007, 'Eye Care', 'Giza', 7),
(3008, 'ENT Unit', 'Nasr City', 8),
(3009, 'Mind Health', 'Mokattam', 9),
(3010, 'Digestive Center', 'Hadayek El Kobba', 10);


INSERT INTO CLINIC_DOCTOR (Clinic_ID, Doctor_ID) VALUES
(3001, 2001),
(3002, 2002),
(3003, 2003),
(3004, 2004),
(3005, 2005),
(3006, 2006),
(3007, 2007),
(3008, 2008),
(3009, 2009),
(3010, 2010);


INSERT INTO APPOINTMENT (Appointment_ID, Patient_ID, Doctor_ID, Clinic_ID, Appointment_Date, Start_Time, End_Time, Status, Diagnosis, Cost) VALUES
(4001, 12527, 2001, 3001, '2025-04-20', '10:00:00', '10:30:00', 'scheduled', 'fatty liver', 500),
(4002, 12528, 2002, 3002, '2025-04-22', '11:00:00', '11:45:00', 'in progress', 'skin allergy', 400),
(4003, 12529, 2003, 3003, '2025-04-23', '09:00:00', '09:30:00', 'scheduled', 'migraine', 450),
(4004, 12530, 2004, 3004, '2025-04-24', '12:00:00', '12:45:00', 'postponed', 'fracture', 600),
(4005, 12531, 2005, 3005, '2025-04-25', '13:00:00', '13:30:00', 'scheduled', 'flu', 300),
(4006, 12532, 2006, 3006, '2025-04-26', '14:00:00', '14:30:00', 'in progress', 'leukemia', 1000),
(4007, 12533, 2007, 3007, '2025-04-27', '15:00:00', '15:30:00', 'scheduled', 'blurred vision', 350),
(4008, 12534, 2008, 3008, '2025-04-28', '16:00:00', '16:30:00', 'scheduled', 'sinusitis', 320),
(4009, 12535, 2009, 3009, '2025-04-29', '17:00:00', '17:45:00', 'postponed', 'depression', 700),
(4010, 12536, 2010, 3010, '2025-04-30', '18:00:00', '18:30:00', 'scheduled', 'ulcer', 480);


INSERT INTO MEDICAL_RECORD (Record_ID, Patient_ID, Doctor_ID, Diagnosis, Treatment) VALUES
(5001, 12527, 2001, 'fatty liver', 'diet & exercise'),
(5002, 12528, 2002, 'skin allergy', 'antihistamines'),
(5003, 12529, 2003, 'migraine', 'painkillers & rest'),
(5004, 12530, 2004, 'fracture', 'cast for 6 weeks'),
(5005, 12531, 2005, 'flu', 'rest & fluids'),
(5006, 12532, 2006, 'leukemia', 'chemotherapy'),
(5007, 12533, 2007, 'blurred vision', 'glasses'),
(5008, 12534, 2008, 'sinusitis', 'nasal spray'),
(5009, 12535, 2009, 'depression', 'therapy & medication'),
(5010, 12536, 2010, 'ulcer', 'PPI & diet change');

UPDATE PATIENT
SET Address = 'New Cairo'
WHERE Patient_ID = 12527;

UPDATE DOCTOR
SET Phone = '01112345678'
WHERE Doctor_ID = 2001;


UPDATE APPOINTMENT
SET Status = 'completed'
WHERE Appointment_ID = 4001;


UPDATE APPOINTMENT
SET Diagnosis = 'hypertension', Cost = 550.00
WHERE Appointment_ID = 4003;


UPDATE DOCTOR
SET Specialty = 'Internal Medicine'
WHERE Doctor_ID = 2010;


UPDATE MEDICAL_RECORD
SET Treatment = 'new medication & rest'
WHERE Record_ID = 5003;


UPDATE CLINIC
SET Name = 'Advanced Heart Center'
WHERE Clinic_ID = 3001;


UPDATE PATIENT
SET Job = 'Software Developer'
WHERE Patient_ID = 12533;


UPDATE PATIENT
SET Date_of_Birth = '1991-01-01'
WHERE Patient_ID = 12529;


UPDATE CLINIC
SET Location = 'New Downtown'
WHERE Clinic_ID = 3005;


SELECT * FROM PATIENT;
SELECT D.Doctor_ID, D.First_Name, D.Last_Name, D.Specialty, D.Phone, D.Address, Dept.Name AS Department_Name
FROM DOCTOR D
JOIN DEPARTMENT Dept ON D.Department_ID = Dept.Department_ID;
SELECT C.Clinic_ID, C.Name, C.Location, Dept.Name AS Department_Name
FROM CLINIC C
JOIN DEPARTMENT Dept ON C.Department_ID = Dept.Department_ID;

SELECT A.Appointment_ID, P.First_Name AS Patient_First_Name, P.Last_Name AS Patient_Last_Name,
       Doc.First_Name AS Doctor_First_Name, Doc.Last_Name AS Doctor_Last_Name,
       C.Name AS Clinic_Name, A.Appointment_Date, A.Start_Time, A.End_Time,
       A.Status, A.Diagnosis, A.Cost
FROM APPOINTMENT A
JOIN PATIENT P ON A.Patient_ID = P.Patient_ID
JOIN DOCTOR Doc ON A.Doctor_ID = Doc.Doctor_ID
JOIN CLINIC C ON A.Clinic_ID = C.Clinic_ID;

SELECT MR.Record_ID, P.First_Name AS Patient_First_Name, P.Last_Name AS Patient_Last_Name,
       Doc.First_Name AS Doctor_First_Name, Doc.Last_Name AS Doctor_Last_Name,
       MR.Diagnosis, MR.Treatment, MR.Record_Date
FROM MEDICAL_RECORD MR
JOIN PATIENT P ON MR.Patient_ID = P.Patient_ID
JOIN DOCTOR Doc ON MR.Doctor_ID = Doc.Doctor_ID;




CREATE VIEW vw_AppointmentDetails AS
SELECT A.Appointment_ID, P.First_Name AS Patient_First_Name, P.Last_Name AS Patient_Last_Name,
       Doc.First_Name AS Doctor_First_Name, Doc.Last_Name AS Doctor_Last_Name,
       C.Name AS Clinic_Name, A.Appointment_Date, A.Start_Time, A.End_Time,
       A.Status, A.Diagnosis, A.Cost
FROM APPOINTMENT A
JOIN PATIENT P ON A.Patient_ID = P.Patient_ID
JOIN DOCTOR Doc ON A.Doctor_ID = Doc.Doctor_ID
JOIN CLINIC C ON A.Clinic_ID = C.Clinic_ID;

CREATE VIEW vw_MedicalRecords AS
SELECT MR.Record_ID, P.First_Name AS Patient_First_Name, P.Last_Name AS Patient_Last_Name,
       Doc.First_Name AS Doctor_First_Name, Doc.Last_Name AS Doctor_Last_Name,
       MR.Diagnosis, MR.Treatment, MR.Record_Date
FROM MEDICAL_RECORD MR
JOIN PATIENT P ON MR.Patient_ID = P.Patient_ID
JOIN DOCTOR Doc ON MR.Doctor_ID = Doc.Doctor_ID;


CREATE VIEW vw_DoctorDetails AS
SELECT D.Doctor_ID, D.First_Name, D.Last_Name, D.Specialty, D.Phone, D.Address,
       Dept.Name AS Department_Name,
       GROUP_CONCAT(C.Name SEPARATOR ', ') AS Clinics
FROM DOCTOR D
JOIN DEPARTMENT Dept ON D.Department_ID = Dept.Department_ID
LEFT JOIN CLINIC_DOCTOR CD ON D.Doctor_ID = CD.Doctor_ID
LEFT JOIN CLINIC C ON CD.Clinic_ID = C.Clinic_ID
GROUP BY D.Doctor_ID;
 
 
 CREATE VIEW vw_PatientDetails AS
SELECT Patient_ID, First_Name, Last_Name, Gender, Date_of_Birth, Address, Job
FROM PATIENT;

