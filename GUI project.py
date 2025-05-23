import tkinter as tk
from tkinter import messagebox, simpledialog
from tkinter import ttk
import mysql.connector

class ClinicApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Clinic Management System")
        self.root.geometry("1000x600")

        self.db_config = {
            'host': 'localhost',
            'user': 'root',      
            'password': '2332005',  
            'database': 'clinic_management'
        }

        # Create Notebook for tabs
        self.notebook = ttk.Notebook(root)
        self.notebook.pack(fill='both', expand=True)

        # Create tabs
        self.create_patients_tab()
        self.create_doctors_tab()
        self.create_clinics_tab()
        self.create_appointments_tab()
        self.create_medical_records_tab()

    def connect_db(self):
        try:
            connection = mysql.connector.connect(**self.db_config)
            return connection
        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", f"Error: {err}")
            return None
    def create_patients_tab(self):
        self.patients_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.patients_frame, text="Patients")

        columns = ("Patient_ID", "First_Name", "Last_Name", "Gender", "Date_of_Birth", "Address", "Job")
        self.patient_tree = ttk.Treeview(self.patients_frame, columns=columns, show='headings')
        for col in columns:
            self.patient_tree.heading(col, text=col.replace('_', ' '))
            self.patient_tree.column(col, width=130 if col != 'Patient_ID' else 80, anchor='center')
        self.patient_tree.pack(fill='both', expand=True, padx=10, pady=10)

       
        btn_frame = ttk.Frame(self.patients_frame)
        btn_frame.pack(pady=5)

        btn_load = ttk.Button(btn_frame, text="Load Patients", command=self.load_patients)
        btn_load.grid(row=0, column=0, padx=5)

        btn_add = ttk.Button(btn_frame, text="Add Patient", command=self.add_patient_dialog)
        btn_add.grid(row=0, column=1, padx=5)

        btn_update = ttk.Button(btn_frame, text="Update Selected", command=self.update_patient_dialog)
        btn_update.grid(row=0, column=2, padx=5)

        btn_delete = ttk.Button(btn_frame, text="Delete Selected", command=self.delete_patient)
        btn_delete.grid(row=0, column=3, padx=5)

    def load_patients(self):
        connection = self.connect_db()
        if connection:
            cursor = connection.cursor()
            cursor.execute("SELECT Patient_ID, First_Name, Last_Name, Gender, Date_of_Birth, Address, Job FROM PATIENT ORDER BY Patient_ID")
            rows = cursor.fetchall()

            self.patient_tree.delete(*self.patient_tree.get_children())
            for row in rows:
                self.patient_tree.insert("", "end", values=row)

            cursor.close()
            connection.close()

    def add_patient_dialog(self):
        self.patient_form_dialog(title="Add New Patient")

    def update_patient_dialog(self):
        selected = self.patient_tree.selection()
        if not selected:
            messagebox.showinfo("No Selection", "Please select a patient to update.")
            return
        patient_data = self.patient_tree.item(selected[0])['values']
        self.patient_form_dialog(title="Update Patient", patient_data=patient_data)

    def patient_form_dialog(self, title, patient_data=None):
        dialog = tk.Toplevel(self.root)
        dialog.title(title)
        dialog.geometry("400x350")
        dialog.grab_set()  

        labels = ["Patient ID", "First Name", "Last Name", "Gender (M/F)", "Date of Birth (YYYY-MM-DD)", "Address", "Job"]
        entries = []

        for i, label in enumerate(labels):
            ttk.Label(dialog, text=label).grid(row=i, column=0, pady=5, padx=5, sticky='e')
            entry = ttk.Entry(dialog)
            entry.grid(row=i, column=1, pady=5, padx=5)
            entries.append(entry)

        
        if patient_data:
            for i, val in enumerate(patient_data):
                entries[i].insert(0, str(val))
            entries[0].config(state='disabled')

        def on_submit():
            try:
                patient_id = int(entries[0].get()) if not patient_data else patient_data[0]
                first_name = entries[1].get().strip()
                last_name = entries[2].get().strip()
                gender = entries[3].get().strip().upper()
                dob = entries[4].get().strip()
                address = entries[5].get().strip()
                job = entries[6].get().strip()

                if not first_name or not last_name or gender not in ('M', 'F'):
                    messagebox.showerror("Invalid Data", "Please enter all required fields correctly.")
                    return

                connection = self.connect_db()
                if not connection:
                    return

                cursor = connection.cursor()

                if patient_data:
                    query = """UPDATE PATIENT 
                               SET First_Name=%s, Last_Name=%s, Gender=%s, Date_of_Birth=%s, Address=%s, Job=%s
                               WHERE Patient_ID=%s"""
                    cursor.execute(query, (first_name, last_name, gender, dob or None, address, job, patient_id))
                else:
                    query = """INSERT INTO PATIENT 
                               (Patient_ID, First_Name, Last_Name, Gender, Date_of_Birth, Address, Job)
                               VALUES (%s,%s,%s,%s,%s,%s,%s)"""
                    cursor.execute(query, (patient_id, first_name, last_name, gender, dob or None, address, job))

                connection.commit()
                cursor.close()
                connection.close()

                messagebox.showinfo("Success", f"Patient {'updated' if patient_data else 'added'} successfully!")
                dialog.destroy()
                self.load_patients()

            except ValueError:
                messagebox.showerror("Invalid Input", "Please enter valid values.")
            except mysql.connector.IntegrityError as e:
                messagebox.showerror("Database Error", f"Integrity Error: {e}")
            except Exception as e:
                messagebox.showerror("Error", str(e))

        submit_btn = ttk.Button(dialog, text="Save", command=on_submit)
        submit_btn.grid(row=len(labels), column=0, columnspan=2, pady=10)

    def delete_patient(self):
        selected = self.patient_tree.selection()
        if not selected:
            messagebox.showinfo("No Selection", "Please select a patient to delete.")
            return

        answer = messagebox.askyesno("Confirm Delete", "Are you sure you want to delete the selected patient?")
        if not answer:
            return

        patient_data = self.patient_tree.item(selected[0])['values']
        patient_id = patient_data[0]

        connection = self.connect_db()
        if not connection:
            return
        try:
            cursor = connection.cursor()
            cursor.execute("DELETE FROM PATIENT WHERE Patient_ID = %s", (patient_id,))
            connection.commit()
            cursor.close()
            connection.close()

            messagebox.showinfo("Deleted", "Patient deleted successfully.")
            self.load_patients()
        except mysql.connector.Error as e:
            messagebox.showerror("Database Error", str(e))
    def create_doctors_tab(self):
        self.doctors_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.doctors_frame, text="Doctors")

        columns = ("Doctor_ID", "First_Name", "Last_Name", "Specialty", "Phone", "Address", "Department")
        self.doctor_tree = ttk.Treeview(self.doctors_frame, columns=columns, show='headings')
        for col in columns:
            self.doctor_tree.heading(col, text=col.replace('_', ' '))
            self.doctor_tree.column(col, width=130 if col not in ['Doctor_ID', 'Phone'] else 100, anchor='center')
        self.doctor_tree.pack(fill='both', expand=True, padx=10, pady=10)

        btn_load = ttk.Button(self.doctors_frame, text="Load Doctors", command=self.load_doctors)
        btn_load.pack(pady=(0,10))

    def load_doctors(self):
        connection = self.connect_db()
        if connection:
            cursor = connection.cursor()
            query = """
                SELECT D.Doctor_ID, D.First_Name, D.Last_Name, D.Specialty, D.Phone, D.Address, Dept.Name
                FROM DOCTOR D
                JOIN DEPARTMENT Dept ON D.Department_ID = Dept.Department_ID
                ORDER BY D.Doctor_ID
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            self.doctor_tree.delete(*self.doctor_tree.get_children())
            for row in rows:
                self.doctor_tree.insert("", "end", values=row)

            cursor.close()
            connection.close()

    def create_clinics_tab(self):
        self.clinics_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.clinics_frame, text="Clinics")

        columns = ("Clinic_ID", "Name", "Location", "Department")
        self.clinic_tree = ttk.Treeview(self.clinics_frame, columns=columns, show='headings')
        for col in columns:
            self.clinic_tree.heading(col, text=col.replace('_', ' '))
            self.clinic_tree.column(col, width=200 if col == "Name" else 130, anchor='center')
        self.clinic_tree.pack(fill='both', expand=True, padx=10, pady=10)

        btn_load = ttk.Button(self.clinics_frame, text="Load Clinics", command=self.load_clinics)
        btn_load.pack(pady=(0,10))

    def load_clinics(self):
        connection = self.connect_db()
        if connection:
            cursor = connection.cursor()
            query = """
                SELECT C.Clinic_ID, C.Name, C.Location, Dept.Name
                FROM CLINIC C
                JOIN DEPARTMENT Dept ON C.Department_ID = Dept.Department_ID
                ORDER BY C.Clinic_ID
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            self.clinic_tree.delete(*self.clinic_tree.get_children())
            for row in rows:
                self.clinic_tree.insert("", "end", values=row)

            cursor.close()
            connection.close()

    def create_appointments_tab(self):
        self.appointments_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.appointments_frame, text="Appointments")

        columns = ("Appointment_ID", "Patient_First_Name", "Patient_Last_Name",
                   "Doctor_First_Name", "Doctor_Last_Name", "Clinic_Name",
                   "Appointment_Date", "Start_Time", "End_Time", "Status", "Diagnosis", "Cost")
        self.appointment_tree = ttk.Treeview(self.appointments_frame, columns=columns, show='headings')
        for col in columns:
            self.appointment_tree.heading(col, text=col.replace('_', ' '))
            w = 90
            if "Name" in col:
                w = 120
            elif col in ("Appointment_Date", "Start_Time", "End_Time", "Status", "Diagnosis"):
                w = 110
            elif col == "Cost":
                w = 70
            self.appointment_tree.column(col, width=w, anchor='center')
        self.appointment_tree.pack(fill='both', expand=True, padx=10, pady=10)

        btn_load = ttk.Button(self.appointments_frame, text="Load Appointments", command=self.load_appointments)
        btn_load.pack(pady=(0,10))

    def load_appointments(self):
        connection = self.connect_db()
        if connection:
            cursor = connection.cursor()
            query = """
                SELECT A.Appointment_ID, P.First_Name, P.Last_Name,
                       Doc.First_Name, Doc.Last_Name, C.Name,
                       A.Appointment_Date, A.Start_Time, A.End_Time,
                       A.Status, A.Diagnosis, A.Cost
                FROM APPOINTMENT A
                JOIN PATIENT P ON A.Patient_ID = P.Patient_ID
                JOIN DOCTOR Doc ON A.Doctor_ID = Doc.Doctor_ID
                JOIN CLINIC C ON A.Clinic_ID = C.Clinic_ID
                ORDER BY A.Appointment_Date DESC, A.Start_Time
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            self.appointment_tree.delete(*self.appointment_tree.get_children())
            for row in rows:
                self.appointment_tree.insert("", "end", values=row)

            cursor.close()
            connection.close()

    def create_medical_records_tab(self):
        self.medical_records_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.medical_records_frame, text="Medical Records")

        columns = ("Record_ID", "Patient_First_Name", "Patient_Last_Name",
                   "Doctor_First_Name", "Doctor_Last_Name", "Diagnosis",
                   "Treatment", "Record_Date")
        self.medical_tree = ttk.Treeview(self.medical_records_frame, columns=columns, show='headings')
        for col in columns:
            self.medical_tree.heading(col, text=col.replace('_', ' '))
            w = 100
            if col in ("Treatment", "Diagnosis"):
                w = 200
            elif col in ("Record_Date",):
                w = 110
            self.medical_tree.column(col, width=w, anchor='center')
        self.medical_tree.pack(fill='both', expand=True, padx=10, pady=10)

        btn_load = ttk.Button(self.medical_records_frame, text="Load Medical Records", command=self.load_medical_records)
        btn_load.pack(pady=(0,10))

    def load_medical_records(self):
        connection = self.connect_db()
        if connection:
            cursor = connection.cursor()
            query = """
                SELECT MR.Record_ID, P.First_Name, P.Last_Name,
                       Doc.First_Name, Doc.Last_Name, MR.Diagnosis,
                       MR.Treatment, MR.Record_Date
                FROM MEDICAL_RECORD MR
                JOIN PATIENT P ON MR.Patient_ID = P.Patient_ID
                JOIN DOCTOR Doc ON MR.Doctor_ID = Doc.Doctor_ID
                ORDER BY MR.Record_Date DESC
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            self.medical_tree.delete(*self.medical_tree.get_children())
            for row in rows:
                self.medical_tree.insert("", "end", values=row)

            cursor.close()
            connection.close()


def main():
    root = tk.Tk()
    app = ClinicApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()

