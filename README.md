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
* **Core**: InterSystems IRIS (Vector Search & FHIR Server)
* **AI**: Python, ONNX Runtime, HuggingFace Transformers
* **Frontend**: Angular 18+, Tailwind CSS
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

* **URL:** [http://localhost:8080](https://www.google.com/search?q=http://localhost:8080/)
* **What it is:** This is the user-facing dashboard.
* **What you can do here:** * Search for patients using natural language.
* View clinical similarity scores (e.g., "Patient A is a 95% match").
* Interact with the FHIR data visualized in a clean, modern UI.


#### **2. Backend Management (InterSystems IRIS)**

* **URL:** [http://localhost:52773/csp/sys/UtilHome.csp](https://www.google.com/search?q=http://localhost:52773/csp/sys/UtilHome.csp)
* **What it is:** The **Management Portal** for the InterSystems IRIS database.

<img width="1342" height="973" alt="image" src="https://github.com/user-attachments/assets/2199138d-431b-4711-bfef-5c909e2a114c" />
