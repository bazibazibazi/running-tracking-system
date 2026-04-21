# Running Tracking System

A portfolio-ready SQL project focused on designing and populating a running analytics database.  
It models runners, activities, routes, telemetry, achievements, goals, and gear to support performance analysis and reporting use cases.

---

## Features

- Track running sessions and related activity metadata
- Store route information (distance, elevation, surface, difficulty)
- Capture per-activity telemetry (heart rate, pace, running power, footsteps, GPS)
- Manage athlete profiles, shoes, and training goals
- Record runner achievements and achievement types
- Generate realistic synthetic data at scale for testing and analysis (`generate_data.py`)

---

## Tech Stack

- **Primary:** SQL (schema design, constraints, relations, analytical querying)
- **Database style:** Relational model with PK/FK constraints (Oracle-style DDL in `Schema.sql`)
- **Integration:** Python script for deterministic data generation (`generate_data.py`)

---

## Database Schema (Overview)

The schema contains 8 main entities:

- **RUNNERS** – athlete profile and demographics
- **ROUTES** – route metadata such as distance and terrain
- **ACTIVITIES** – individual running sessions linked to runners and routes
- **TELEMETRY_DATA** – time-series-like activity measurements (heart rate, pace, power, GPS)
- **TRAINING_GOALS** – athlete goals and progress
- **SHOES** – shoe lifecycle and usage tracking
- **ACHIEVEMENTS_TYPES** – achievement definitions and conditions
- **RUNNER_ACHIEVEMENTS** – earned achievements linked to activities

Refer to [`Schema.sql`](./Schema.sql) for full DDL, keys, and foreign key relationships.

---

## Project Structure

```text
running-tracking-system/
├── Schema.sql          # Database schema (tables, PKs, FKs)
├── generate_data.py    # Synthetic data generator (outputs generated_data.sql)
├── Raport_01.bat       # Opens external report link
├── ADB Project.pdf     # Project documentation (PDF)
├── ADB Lecture.pdf     # Supporting material (PDF)
└── README.md           # Project overview and usage guide
```

---

## Getting Started

### 1) Clone the repository

```bash
git clone https://github.com/bazibazibazi/running-tracking-system.git
cd running-tracking-system
```

### 2) Create database objects

Run the schema in your SQL environment:

```sql
-- Example
@Schema.sql
```

### 3) Generate sample data

```bash
python3 generate_data.py
```

This creates `generated_data.sql` with insert statements and cleanup commands.

### 4) Load generated data

Execute `generated_data.sql` in your database client after schema creation.

---

## Usage Examples

### Example: list latest activities with runner names

```sql
SELECT a.activity_id,
       r.full_name,
       a.activity_type,
       a.duration_min,
       a.activity_date
FROM activities a
JOIN runners r ON r.runner_id = a.runner_id
ORDER BY a.activity_date DESC;
```

### Example: average pace by activity type

```sql
SELECT a.activity_type,
       ROUND(AVG(t.pace), 2) AS avg_pace
FROM activities a
JOIN telemetry_data t ON t.activity_id = a.activity_id
GROUP BY a.activity_type
ORDER BY avg_pace;
```

### Example: generate fresh dataset

```bash
python3 generate_data.py
```

---

## Learning Outcomes

This project demonstrates:

- Relational database design and entity relationship modeling
- Primary/foreign key design and referential integrity
- Data normalization and structured domain modeling
- Writing analytical SQL queries for performance insights
- Synthetic data generation for large dataset testing
- Practical SQL + Python workflow integration

---

## Author / Contact

**Author:** [@bazibazibazi](https://github.com/bazibazibazi)  
**Repository:** https://github.com/bazibazibazi/running-tracking-system  
**Project report (SharePoint):**  
https://politechnikawroclawska-my.sharepoint.com/:w:/g/personal/268856_student_pwr_edu_pl/IQD3z9OCRYbHR4TdWH_KQRiFAfVfMZqcgEtP7O8HYxmH-Hc?e=ZZpd0G&fbclid=IwY2xjawQgogFleHRuA2FlbQIxMQBzcnRjBmFwcF9pZAEwAAEe4WWzYpeHxDg5vU3d53TaDEdboH5eC-MyuLmWUxVOPrfjNabbApEEhNTNNvo_aem_lB5f-CejMwTnp1DzG-qe3w
