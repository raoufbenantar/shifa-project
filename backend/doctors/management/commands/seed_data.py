#!/usr/bin/env python3
"""
Seed the database with realistic demo data for the Shifa presentation.

Usage:
    python manage.py seed_data
    python manage.py seed_data --flush     # wipe existing data first
"""

from django.core.management.base import BaseCommand
from django.contrib.auth.hashers import make_password
from django.utils import timezone
from datetime import time, timedelta, date, datetime
from users.models import User, Role
from doctors.models import DoctorProfile, Clinic, DoctorClinic, DoctorAvailability
from patients.models import PatientProfile
from appointments.models import Appointment, Review, AppointmentMessage


DOCTORS = [
    {
        "full_name": "Amine Benali",
        "specialization": "Cardiology",
        "experience_years": 18,
        "consultation_fee": 3500.00,
        "bio": "Dr. Benali is a senior cardiologist with 18 years of experience in interventional cardiology. He specializes in coronary artery disease, heart failure management, and preventive cardiology. He has performed over 2,000 successful cardiac procedures and is passionate about patient education.",
        "license_number": "LIC-CRD-001",
    },
    {
        "full_name": "Fatima Zohra Mansouri",
        "specialization": "Dermatology",
        "experience_years": 12,
        "consultation_fee": 2800.00,
        "bio": "Dr. Mansouri is a board-certified dermatologist specializing in medical, surgical, and cosmetic dermatology. She has extensive experience in treating skin cancer, acne, eczema, psoriasis, and offers advanced laser treatments for various skin conditions.",
        "license_number": "LIC-DRM-002",
    },
    {
        "full_name": "Rachid Bouchama",
        "specialization": "Neurology",
        "experience_years": 22,
        "consultation_fee": 4200.00,
        "bio": "Professor Bouchama is a renowned neurologist specializing in stroke management, epilepsy, multiple sclerosis, and movement disorders. He has published over 50 research papers and is a founding member of the Algerian Neurological Society.",
        "license_number": "LIC-NRL-003",
    },
    {
        "full_name": "Nadia Khemiri",
        "specialization": "Pediatrics",
        "experience_years": 14,
        "consultation_fee": 2500.00,
        "bio": "Dr. Khemiri is a compassionate pediatrician dedicated to children's health from infancy through adolescence. She specializes in childhood development, vaccination programs, respiratory infections, and pediatric nutrition counseling.",
        "license_number": "LIC-PED-004",
    },
    {
        "full_name": "Youcef Amiri",
        "specialization": "Orthopedics",
        "experience_years": 16,
        "consultation_fee": 3200.00,
        "bio": "Dr. Amiri is an orthopedic surgeon specializing in sports medicine, joint replacement, and trauma surgery. He has trained in France and Switzerland, and has helped hundreds of athletes return to their sport after injury.",
        "license_number": "LIC-ORT-005",
    },
    {
        "full_name": "Samia Bensaïd",
        "specialization": "Ophthalmology",
        "experience_years": 11,
        "consultation_fee": 3000.00,
        "bio": "Dr. Bensaïd is an ophthalmologist specializing in cataract surgery, glaucoma management, and refractive surgery (LASIK). She is committed to providing the highest standard of eye care using the latest diagnostic and surgical technologies.",
        "license_number": "LIC-OPT-006",
    },
    {
        "full_name": "Karim Oussedik",
        "specialization": "Psychiatry",
        "experience_years": 15,
        "consultation_fee": 3500.00,
        "bio": "Dr. Oussedik is a consultant psychiatrist specializing in anxiety disorders, depression, PTSD, and addiction medicine. He offers both medication management and psychotherapy, believing in a holistic approach to mental health.",
        "license_number": "LIC-PSY-007",
    },
    {
        "full_name": "Leila Hamdi",
        "specialization": "General Practice",
        "experience_years": 20,
        "consultation_fee": 1800.00,
        "bio": "Dr. Hamdi is an experienced general practitioner providing comprehensive primary healthcare for the whole family. She focuses on preventive medicine, chronic disease management, and coordinating specialist referrals when needed.",
        "license_number": "LIC-GEN-008",
    },
    {
        "full_name": "Mohamed Reda Chaouche",
        "specialization": "Radiology",
        "experience_years": 13,
        "consultation_fee": 2800.00,
        "bio": "Dr. Chaouche is a diagnostic radiologist with expertise in MRI, CT scans, ultrasound, and interventional radiology. He works closely with referring physicians to ensure accurate diagnosis and optimal treatment planning.",
        "license_number": "LIC-RAD-009",
    },
    {
        "full_name": "Aïcha Tedjini",
        "specialization": "Dentistry",
        "experience_years": 9,
        "consultation_fee": 2200.00,
        "bio": "Dr. Tedjini is a skilled dentist specializing in preventive dentistry, cosmetic dentistry, and orthodontics. She provides gentle, patient-centered care and specializes in smile makeovers and Invisalign treatments.",
        "license_number": "LIC-DNT-010",
    },
    {
        "full_name": "Hicham Boulahdour",
        "specialization": "Gastroenterology",
        "experience_years": 17,
        "consultation_fee": 3800.00,
        "bio": "Dr. Boulahdour is a gastroenterologist specializing in digestive diseases, colon cancer screening, endoscopy, and IBS management. He is known for his thorough approach and excellent patient communication.",
        "license_number": "LIC-GST-011",
    },
    {
        "full_name": "Wassila Taieb",
        "specialization": "Endocrinology",
        "experience_years": 10,
        "consultation_fee": 3000.00,
        "bio": "Dr. Taieb is an endocrinologist specializing in diabetes management, thyroid disorders, and hormonal imbalances. She is passionate about helping patients achieve metabolic health through personalized treatment plans and lifestyle modifications.",
        "license_number": "LIC-END-012",
    },
]

CLINICS = [
    {
        "name": "Clinique El Djazair",
        "address_text": "42 Rue Didouche Mourad, Alger Centre",
        "city": "Alger",
        "latitude": 36.7538,
        "longitude": 3.0588,
        "phone_number": "+21321632211",
        "opening_hours": "7 days / week, 8:00 AM - 8:00 PM",
        "type": "center",
    },
    {
        "name": "Polyclinique des Oliviers",
        "address_text": "15 Boulevard de l'ALN, Hydra",
        "city": "Alger",
        "latitude": 36.7450,
        "longitude": 3.0433,
        "phone_number": "+21321483322",
        "opening_hours": "Sat - Thu, 8:30 AM - 7:00 PM",
        "type": "center",
    },
    {
        "name": "Centre Médical Ibn Sina",
        "address_text": "Rue des Frères Arbaoui, Bab Ezzouar",
        "city": "Alger",
        "latitude": 36.7220,
        "longitude": 3.1820,
        "phone_number": "+21323921133",
        "opening_hours": "Sat - Wed, 9:00 AM - 6:00 PM",
        "type": "private",
    },
    {
        "name": "Clinique Chifa Chéraga",
        "address_text": "RN 41, Chéraga, Ouest d'Alger",
        "city": "Alger",
        "latitude": 36.7680,
        "longitude": 2.9150,
        "phone_number": "+21321375544",
        "opening_hours": "7 days / week, 24 hours",
        "type": "hospital",
    },
    {
        "name": "Espace Santé El Biar",
        "address_text": "3 Rue Mohamed Belouizdad, El Biar",
        "city": "Alger",
        "latitude": 36.7390,
        "longitude": 3.0290,
        "phone_number": "+21321446655",
        "opening_hours": "Sat - Thu, 8:30 AM - 6:30 PM",
        "type": "private",
    },
]

PATIENTS = [
    {
        "full_name": "Ahmed Toumi",
        "phone_number": "+213555100101",
        "national_id": "ALG-1985-123456",
        "date_of_birth": date(1985, 6, 15),
        "gender": "M",
        "email": "ahmed.toumi@email.com",
        "password": "patient123",
    },
    {
        "full_name": "Farida Belkacem",
        "phone_number": "+213555100202",
        "national_id": "ALG-1992-789012",
        "date_of_birth": date(1992, 3, 28),
        "gender": "F",
        "email": "farida.belkacem@email.com",
        "password": "patient123",
    },
    {
        "full_name": "Tahar Meziane",
        "phone_number": "+213555100303",
        "national_id": "ALG-1978-345678",
        "date_of_birth": date(1978, 11, 8),
        "gender": "M",
        "email": "tahar.meziane@email.com",
        "password": "patient123",
    },
]

# Doctor ↔ Clinic assignments with availability schedules
DOCTOR_CLINIC_ASSIGNMENTS = [
    # (doctor_index, clinic_index, day_of_week, start_hour, end_hour, slot_minutes)
    # Dr. Amine Benali (Cardiology) - Clinique El Djazair & Polyclinique des Oliviers
    (0, 0, "Sun", 8, 12, 30),
    (0, 0, "Mon", 9, 13, 30),
    (0, 0, "Tue", 14, 18, 30),
    (0, 1, "Wed", 9, 13, 30),
    (0, 1, "Thu", 9, 12, 30),

    # Dr. Fatima Mansouri (Dermatology) - Clinique El Djazair & Espace Santé
    (1, 0, "Sun", 9, 13, 30),
    (1, 0, "Mon", 14, 18, 30),
    (1, 0, "Tue", 9, 12, 30),
    (1, 4, "Wed", 10, 14, 30),
    (1, 4, "Thu", 10, 15, 30),

    # Dr. Rachid Bouchama (Neurology) - Polyclinique des Oliviers & Ibn Sina
    (2, 1, "Sun", 9, 13, 45),
    (2, 1, "Mon", 9, 13, 45),
    (2, 1, "Tue", 9, 13, 45),
    (2, 2, "Wed", 10, 15, 45),
    (2, 2, "Thu", 10, 14, 45),

    # Dr. Nadia Khemiri (Pediatrics) - Clinique Chéraga & El Djazair
    (3, 3, "Sun", 8, 14, 20),
    (3, 3, "Mon", 8, 14, 20),
    (3, 3, "Tue", 8, 12, 20),
    (3, 0, "Wed", 9, 13, 20),
    (3, 0, "Thu", 9, 13, 20),

    # Dr. Youcef Amiri (Orthopedics) - Ibn Sina & Clinique Chéraga
    (4, 2, "Sun", 9, 13, 30),
    (4, 2, "Mon", 14, 18, 30),
    (4, 2, "Tue", 9, 13, 30),
    (4, 3, "Wed", 9, 14, 30),
    (4, 3, "Thu", 9, 12, 30),

    # Dr. Samia Bensaïd (Ophthalmology) - Polyclinique des Oliviers & Espace Santé
    (5, 1, "Mon", 9, 13, 30),
    (5, 1, "Tue", 9, 13, 30),
    (5, 1, "Wed", 9, 13, 30),
    (5, 4, "Thu", 9, 14, 30),
    (5, 4, "Sat", 9, 13, 30),

    # Dr. Karim Oussedik (Psychiatry) - Espace Santé & Ibn Sina
    (6, 4, "Sun", 10, 14, 60),
    (6, 4, "Mon", 10, 14, 60),
    (6, 4, "Tue", 10, 14, 60),
    (6, 2, "Wed", 10, 15, 60),
    (6, 2, "Thu", 10, 14, 60),

    # Dr. Leila Hamdi (General Practice) - All 5 clinics (1 day each)
    (7, 0, "Sun", 8, 16, 30),
    (7, 1, "Mon", 8, 16, 30),
    (7, 2, "Tue", 8, 16, 30),
    (7, 3, "Wed", 8, 16, 30),
    (7, 4, "Thu", 8, 16, 30),

    # Dr. Mohamed Chaouche (Radiology) - Clinique Chéraga & El Djazair
    (8, 3, "Sun", 9, 13, 30),
    (8, 3, "Mon", 9, 13, 30),
    (8, 3, "Tue", 14, 18, 30),
    (8, 0, "Wed", 9, 13, 30),
    (8, 0, "Thu", 9, 13, 30),

    # Dr. Aïcha Tedjini (Dentistry) - El Djazair & Espace Santé
    (9, 0, "Sun", 8, 13, 30),
    (9, 0, "Mon", 8, 13, 30),
    (9, 0, "Tue", 14, 18, 30),
    (9, 4, "Wed", 9, 14, 30),
    (9, 4, "Thu", 9, 14, 30),

    # Dr. Hicham Boulahdour (Gastroenterology) - Ibn Sina & Clinique Chéraga
    (10, 2, "Sun", 9, 13, 30),
    (10, 2, "Mon", 9, 13, 30),
    (10, 2, "Tue", 14, 18, 30),
    (10, 3, "Wed", 9, 14, 30),
    (10, 3, "Thu", 9, 13, 30),

    # Dr. Wassila Taieb (Endocrinology) - Polyclinique & Ibn Sina
    (11, 1, "Sun", 9, 13, 30),
    (11, 1, "Mon", 14, 18, 30),
    (11, 2, "Tue", 9, 13, 30),
    (11, 2, "Wed", 9, 13, 30),
    (11, 3, "Thu", 9, 13, 30),
]


SAMPLE_NOTES = [
    "Feeling pain in the lower back for the past week.",
    "Regular check-up and blood pressure monitoring.",
    "Follow-up after previous treatment, need to renew prescription.",
    "Persistent headache for the last 3 days, accompanied by dizziness.",
    "Routine dental cleaning and oral examination.",
    "Annual physical examination and blood work.",
    "Consultation for skin rash that appeared after sun exposure.",
    "Eye strain and blurred vision when using computer for long periods.",
]


class Command(BaseCommand):
    help = "Seed the database with realistic demo data for the Shifa presentation."

    def add_arguments(self, parser):
        parser.add_argument(
            "--flush",
            action="store_true",
            help="Delete all existing data before seeding.",
        )

    def handle(self, *args, **options):
        if options["flush"]:
            self.stdout.write(self.style.WARNING("Flushing existing data..."))
            AppointmentMessage.objects.all().delete()
            Review.objects.all().delete()
            Appointment.objects.all().delete()
            DoctorClinic.objects.all().delete()
            DoctorAvailability.objects.all().delete()
            DoctorProfile.objects.all().delete()
            PatientProfile.objects.all().delete()
            Clinic.objects.all().delete()
            User.objects.exclude(id__in=[]).delete()
            Role.objects.all().delete()
            self.stdout.write(self.style.SUCCESS("  Done."))

        self.stdout.write(self.style.NOTICE("\n🌿 Shifa Demo Data Seeder\n"))

        # ── Roles ────────────────────────────────────────────────────
        role_patient, _ = Role.objects.get_or_create(name="patient")
        role_doctor, _ = Role.objects.get_or_create(name="doctor")
        role_admin, _ = Role.objects.get_or_create(name="admin")
        self.stdout.write(self.style.SUCCESS("✔ Roles created"))

        # ── Admin ────────────────────────────────────────────────────
        admin_email = "admin@shifa.dz"
        admin_user, _ = User.objects.get_or_create(
            email=admin_email,
            defaults={
                "password_hash": make_password("admin123"),
                "role": role_admin,
            },
        )
        self.stdout.write(
            self.style.SUCCESS(f"✔ Admin: {admin_email} / admin123")
        )

        # ── Clinics ──────────────────────────────────────────────────
        created_clinics = []
        for c in CLINICS:
            clinic, _ = Clinic.objects.get_or_create(
                name=c["name"],
                defaults={
                    "address_text": c["address_text"],
                    "city": c["city"],
                    "latitude": c["latitude"],
                    "longitude": c["longitude"],
                    "phone_number": c["phone_number"],
                    "opening_hours": c["opening_hours"],
                    "type": c["type"],
                },
            )
            created_clinics.append(clinic)
        self.stdout.write(self.style.SUCCESS(f"✔ {len(created_clinics)} clinics created"))

        # ── Doctors ──────────────────────────────────────────────────
        created_doctors = []
        for i, d in enumerate(DOCTORS):
            email = f"dr.{d['full_name'].lower().replace(' ', '.')}@shifa.dz"

            user, _ = User.objects.get_or_create(
                email=email,
                defaults={
                    "password_hash": make_password("doctor123"),
                    "role": role_doctor,
                },
            )

            doctor, _ = DoctorProfile.objects.get_or_create(
                user=user,
                defaults={
                    "full_name": d["full_name"],
                    "phone_number": f"+213555{100 + i:03d}",
                    "specialization": d["specialization"],
                    "experience_years": d["experience_years"],
                    "consultation_fee": d["consultation_fee"],
                    "bio": d["bio"],
                    "license_number": d["license_number"],
                    "is_active": True,
                    "is_verified": True,
                    "verification_status": "approved",
                },
            )
            created_doctors.append(doctor)
        self.stdout.write(
            self.style.SUCCESS(f"✔ {len(created_doctors)} doctors created")
        )
        self.stdout.write("   " + ", ".join(f"Dr. {d['full_name']} ({d['specialization']})" for d in DOCTORS))

        # ── Doctor–Clinic assignments + Availability ─────────────────
        assignment_count = 0
        availability_count = 0
        for (
            doc_idx,
            clinic_idx,
            day_of_week,
            start_hour,
            end_hour,
            slot_minutes,
        ) in DOCTOR_CLINIC_ASSIGNMENTS:
            doctor = created_doctors[doc_idx]
            clinic = created_clinics[clinic_idx]

            dc, created = DoctorClinic.objects.get_or_create(
                doctor=doctor,
                clinic=clinic,
                defaults={
                    "start_date": date(2024, 1, 1),
                },
            )
            if created:
                assignment_count += 1

            # Create availability for this assignment
            _, created_av = DoctorAvailability.objects.get_or_create(
                doctor=doctor,
                clinic=clinic,
                day_of_week=day_of_week,
                defaults={
                    "start_time": time(start_hour, 0),
                    "end_time": time(end_hour, 0),
                    "slot_duration_minutes": slot_minutes,
                },
            )
            if created_av:
                availability_count += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"✔ {assignment_count} clinic assignments, "
                f"{availability_count} availability slots created"
            )
        )

        # ── Patients ─────────────────────────────────────────────────
        created_patients = []
        for i, p in enumerate(PATIENTS):
            user, _ = User.objects.get_or_create(
                email=p["email"],
                defaults={
                    "password_hash": make_password(p["password"]),
                    "role": role_patient,
                },
            )
            patient, _ = PatientProfile.objects.get_or_create(
                user=user,
                defaults={
                    "full_name": p["full_name"],
                    "phone_number": p["phone_number"],
                    "national_id": p["national_id"],
                    "date_of_birth": p["date_of_birth"],
                    "gender": p["gender"],
                },
            )
            created_patients.append(patient)
        self.stdout.write(
            self.style.SUCCESS(f"✔ {len(created_patients)} patients created")
        )
        for p in PATIENTS:
            self.stdout.write(
                self.style.SUCCESS(
                    f"   {p['full_name']}: {p['email']} / {p['password']}"
                )
            )

        # ── Sample Appointments ──────────────────────────────────────
        now = timezone.now()
        start_of_today = now.replace(hour=0, minute=0, second=0, microsecond=0)

        appointments_to_create = [
            # (patient_idx, doctor_idx, days_from_now, hour, minute, type, status)
            (0, 0, 1, 9, 0, "in_person", "pending"),
            (0, 4, 2, 10, 0, "in_person", "confirmed"),
            (1, 1, 1, 14, 30, "in_person", "confirmed"),
            (1, 6, 3, 11, 0, "teleconsultation", "pending"),
            (2, 3, 2, 9, 0, "in_person", "confirmed"),
            (2, 7, 0, 15, 0, "in_person", "pending"),
            (0, 9, -2, 10, 0, "in_person", "completed"),
            (1, 2, -5, 9, 30, "in_person", "completed"),
            (2, 5, -7, 11, 0, "in_person", "completed"),
            (0, 8, -10, 14, 0, "teleconsultation", "completed"),
            (1, 10, -3, 9, 0, "in_person", "completed"),
            (2, 11, -1, 10, 30, "in_person", "completed"),
        ]

        created_appointments = []
        for (
            p_idx,
            d_idx,
            days_offset,
            hour,
            minute,
            ctype,
            status,
        ) in appointments_to_create:
            patient = created_patients[p_idx]
            doctor = created_doctors[d_idx]

            # Find the first clinic assignment for this doctor
            dc = DoctorClinic.objects.filter(doctor=doctor).first()
            if not dc:
                continue

            appt_datetime = start_of_today + timedelta(days=days_offset, hours=hour, minutes=minute)

            appointment, created = Appointment.objects.get_or_create(
                patient=patient,
                doctor=doctor,
                clinic=dc.clinic,
                scheduled_datetime=appt_datetime,
                defaults={
                    "consultation_type": ctype,
                    "status": status,
                    "notes": SAMPLE_NOTES[
                        len(created_appointments) % len(SAMPLE_NOTES)
                    ],
                },
            )
            if created:
                created_appointments.append(appointment)

        self.stdout.write(
            self.style.SUCCESS(
                f"✔ {len(created_appointments)} sample appointments created"
            )
        )

        # ── Reviews for completed appointments ───────────────────────
        completed_appts = Appointment.objects.filter(status="completed")
        review_count = 0
        for appt in completed_appts:
            _, created = Review.objects.get_or_create(
                appointment=appt,
                defaults={
                    "rating_waiting": 4,
                    "rating_hygiene": 5,
                    "rating_attentiveness": 4,
                    "comment": "Excellent consultation. The doctor was thorough and professional. Highly recommended.",
                },
            )
            if created:
                review_count += 1
        self.stdout.write(
            self.style.SUCCESS(f"✔ {review_count} reviews created")
        )

        # ── Appointment Messages ─────────────────────────────────────
        messages_created = 0
        for appt in completed_appts[:3]:
            msg_texts = [
                ("patient", "Thank you Doctor for the consultation. I have a quick follow-up question about the medication prescribed."),
                ("doctor", "Of course, please let me know what you'd like to ask."),
                ("patient", "The medication you prescribed, should I take it before or after meals?"),
                ("doctor", "Please take it after meals to avoid stomach discomfort. Continue for 7 days and come back if symptoms persist."),
            ]
            for sender_type, text in msg_texts:
                sender_user = (
                    appt.patient.user
                    if sender_type == "patient"
                    else appt.doctor.user
                )
                _, msg_created = AppointmentMessage.objects.get_or_create(
                    appointment=appt,
                    sender=sender_user,
                    message=text,
                )
                if msg_created:
                    messages_created += 1
        self.stdout.write(
            self.style.SUCCESS(f"✔ {messages_created} appointment messages created")
        )

        # ── Summary ──────────────────────────────────────────────────
        self.stdout.write(self.style.NOTICE("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"))
        self.stdout.write(self.style.NOTICE("🎯 Presentation Demo Ready!"))
        self.stdout.write(self.style.NOTICE("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"))
        self.stdout.write(f"  👤 Admin:           {admin_email} / admin123")
        self.stdout.write(f"  🩺 Doctors:          {len(created_doctors)} across {len({d['specialization'] for d in DOCTORS})} specialities")
        self.stdout.write(f"  🏥 Clinics:          {len(created_clinics)} locations (Alger)")
        self.stdout.write(f"  👥 Patients:         {len(created_patients)}")
        for p in PATIENTS:
            self.stdout.write(f"     - {p['full_name']}: {p['email']} / {p['password']}")
        self.stdout.write(f"  📅 Appointments:     {len(created_appointments)} (mixed statuses)")
        self.stdout.write(f"  ⭐ Reviews:           {review_count}")
        self.stdout.write(f"  💬 Messages:          {messages_created}")
        self.stdout.write(self.style.NOTICE("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"))
