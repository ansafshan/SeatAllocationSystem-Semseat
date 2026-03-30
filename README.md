# SeatAllocationSystem-Semseat

A full-stack web application designed to automate and optimize the process of exam seat allocation in educational institutions. The system eliminates manual errors, enforces anti-collusion rules, and provides real-time visibility for administrators, invigilators, and students.

🚀 Overview

Managing exam seating manually is time-consuming, error-prone, and difficult to scale. This system introduces a rule-based automated allocation engine that ensures fair distribution of students across exam halls while preventing subject-wise clustering.

It also integrates invigilator assignment, hall visualization, and role-based access, making it a complete solution for exam management.

✨ Key Features
🧠 Smart Seat Allocation
Rule-based algorithm for automatic seat assignment
Prevents students with the same subject sitting on the same bench
Supports multi-hall allocation with structured distribution
Handles edge cases like insufficient capacity


👨‍🏫 Invigilator Allocation
Assigns invigilators only to active halls
Avoids subject conflicts during assignment
Dynamically allocates based on hall size


📊 Admin Dashboard
Overview of students, teachers, halls, and exams
Malpractice monitoring system
Centralized control for all operations


🪑 Hall Visualization
Real-time graphical layout of seating arrangement
Bench-level seat visibility (Left, Middle, Right)
Occupied vs empty seat indicators


🔐 Role-Based Access
Admin: Full system control
Invigilator: View duty & report malpractice
Student: View seat allocation


🏗️ Tech Stack
Frontend: Flutter (Web + Android)
Backend: Node.js, Express.js
Database: MySQL


⚙️ How It Works
Admin uploads student, exam, and hall data
System processes constraints and runs seat allocation algorithm
Students are assigned seats while avoiding subject conflicts
Invigilators are allocated based on hall usage
Results are displayed via dashboard and hall view
⚠️ Limitations
No digital attendance system
No intelligent resource optimization (currently rule-based)
🔮 Future Improvements
📱 Digital attendance via mobile interface
🤖 AI-based hall optimization for efficient resource usage
📊 Advanced analytics & malpractice detection
