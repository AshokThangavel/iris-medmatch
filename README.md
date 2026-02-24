# iris-medmatch 🏥🤖

An AI-powered patient matching engine built on **InterSystems IRIS**, utilizing **Vector Search** and **Natural Language Processing (NLP)** to find clinically similar patients across FHIR repositories.

## 🚀 Overview
`iris-medmatch` bridges the gap between traditional healthcare data and modern AI. While standard searches look for exact words, this engine understands **clinical intent**. 

> **Example:** It can match a patient with "Hypertension" to a search for "High Blood Pressure" using mathematical vector similarity.

## ✨ Key Features
* **Semantic Search**: Uses `all-MiniLM-L6-v2` embeddings to vectorize clinical conditions.
* **Vector Database**: Leverages the native `VECTOR` data type in InterSystems IRIS 2024.1+.
* **FHIR R4 Ready**: Fully compatible with standard Patient and Condition resources.
* **Embedded Python**: Runs AI models directly inside the database for zero-latency inference.
* **Modern UI**: Angular-based dashboard to visualize similarity scores and patient data.

## 🛠️ Tech Stack
* **Core**: InterSystems IRIS , Embedded Python, InterSystems FHIR Server, Vector search
* **AI**: Python, ONNX Runtime, HuggingFace Transformers
* **Frontend**: Angular 18+
* **DevOps**: Docker & Docker Compose

## 📦 Getting Started

### Prerequisites
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* InterSystems IRIS for Health 2024.1+ (Community Edition works great)

## ⚙️ Installation

### Clone the Repository
```bash
git clone https://github.com/AshokThangavel/iris-medmatch.git
cd iris-medmatch
````

### Running the Application with Docker

Build and start the app using Docker Compose:

```bash
docker-compose up --build
```

### Stopping the Application

To stop and remove the running containers:

```bash
docker-compose down
```
In your **README.md**, the "Usage" section explains how a developer actually interacts with the project once the Docker containers are running.

Here is a clear breakdown you can use to explain these two endpoints:

---

### 🖥️ Usage & Access Points

Once the project is started, you can access the different layers of the application via these URLs:

#### **1. Frontend Interface (Angular)**

* **URL:** [http://localhost:8080](http://localhost:8080/)
* **What it is:** This is the user-facing dashboard.
* **What you can do here:** * Search for patients using natural language.
* Interact with the FHIR data visualized in a clean, modern UI.

#### **2. Backend Management (InterSystems IRIS)**

* **URL:** [http://localhost:52773/csp/sys/UtilHome.csp](http://localhost:52773/csp/sys/UtilHome.csp)
* **What it is:** The **Management Portal** for the InterSystems IRIS database.

## 🚀 Application Walkthrough

### 1. Authentication

* **Demo Credentials:** User: `_SYSTEM` | Pass: `SYS`

<img width="1063" height="884" alt="image" src="https://github.com/user-attachments/assets/cd2cef0c-6d45-4fd8-bdd4-c0371f0bafe3" />

### 2. Semantic Similarity Search (The "Wow" Factor)

This module uses **Vector Search** to understand medical synonyms and clinical intent.

* **How it works:** A search for "Cardiac Issues" will mathematically find "Myocardial Infarction" by comparing their vector positions in IRIS.
* **Tech Highlight:** Uses **Embedded Python** to vectorize the search query and **Native IRIS SQL** to calculate similarity scores in sub-seconds.
<img width="1778" height="1011" alt="image" src="https://github.com/user-attachments/assets/cb56826c-ab03-48ba-a40f-c510226bef2f" />

## 3. Patient Directory & Condition Enrichment

This module manages existing FHIR resources. Users can add new diagnoses through a high-performance modal.

* **The Workflow:**
1. Create `Condition` for the particular patient and stored into the **FHIR Server**. **Tech Highlight:** Demonstrates real-time synchronization between standard FHIR data and AI-ready Vector data.
<img width="1866" height="1010" alt="image" src="https://github.com/user-attachments/assets/c99167d1-b13d-4344-a146-b36035c1d52e" />

2. Add condition and save into `InterSystems iris fhir server`
<img width="1168" height="889" alt="image" src="https://github.com/user-attachments/assets/3ef2442f-90e6-4379-a4d7-e90c4fb2fc57" />

### 4. New Patient Registration

A streamlined entry point for creating new `Patient` resources within the InterSystems ecosystem.

* **Tech Highlight:** Direct interaction with the **FHIR R4 Repository** via standard RESTful POST requests, ensuring data is indexed and searchable immediately.
<img width="1760" height="800" alt="image" src="https://github.com/user-attachments/assets/f4e92602-2a6e-4c04-82e9-39e49b39b4a1" />

