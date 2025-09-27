
# 🏭 Adventure Works — Pipeline, Analytics & Predictive Modeling 

## 📌 1. Project Overview

The goal is to implement an **end-to-end data engineering and data science solution** — from ingestion to demand forecasting — delivering strategic business value.

The journey included:

- **Ingestion:** Data ingestion pipeline from multiple sources (MSSQL + REST API) with **Meltano** and **Docker**.  
- **Transformation:** Building a **Data Warehouse** on **Databricks** with **dbt dimensional modeling**.  
- **Dashboard:** Developing an interactive **Power BI** dashboard with sales, team, and customer KPIs.  
- **Predictive Modeling:** Demand forecasting with regression models, seasonality analysis, regional growth estimation, and resource planning.  

---

## 🏗️ 2. Solution Architecture

The architecture was designed to be **modular, scalable, and business-oriented**:

1. **Ingestion:**  
   - **Meltano + Docker** → Extract data from MSSQL and REST API.  
   - **Target-Parquet** → Store data locally in columnar format.  
   - **Databricks CLI** → Upload Parquet files into DBFS.  

2. **Transformation & Modeling:**  
   - **Databricks Notebooks** → Convert raw data into **Delta Lake Bronze tables**.  
   - **dbt** → Transform into **Silver (staging)** and **Gold (marts)** layers.  
   - **Testing & Documentation** → Built-in data quality checks and interactive docs.  

3. **Visualization:**  
   - **Power BI** connected to DW (8 core tables: 2 facts + 6 dimensions).  
   - Dashboards for **Sales Overview** and **Sales Team Performance** with KPIs, filters, and benchmarks.  

4. **Predictive Modeling:**  
   - Regression models for demand forecasting.  
   - Baseline with **moving averages**.  
   - Model comparison using MAE, RMSE, and MAPE.  
   - Strategic business questions answered:  
     - 3-month demand forecasts.  
     - Seasonality analysis.  
     - Distribution center growth (US vs. Rest of World).  
     - Resource planning (e.g., zippers for gloves).  

---

## ⚙️ 3. Setup & Execution

### 3.1 Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (v4+)  
- [Python 3.10 or 3.11](https://www.python.org/)  
- [Git](https://git-scm.com/)  
- **Databricks workspace** (Free Edition or higher)  
- **Power BI Desktop** (for visualization)  
- Credentials for MSSQL and REST API  

### 3.2 Clone Repository

```bash
git clone https://github.com/alerodriguessf/adventureworks_final_checkpoint
cd adventureworks_final_checkpoint
````

### 3.3 Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

### 3.4 Install Dependencies

```bash
pip install -r requirements.txt
```

### 3.5 Configure Credentials

Create a `.env` file (based on `.env.save`) with your credentials:

```env
# MSSQL
TAP_MSSQL_HOST=...
TAP_MSSQL_USER=...
TAP_MSSQL_PASSWORD=...
TAP_MSSQL_DATABASE=AdventureWorks2022

# API
API_HOST=...
API_USER=...
API_PASSWORD=...

# Databricks
DATABRICKS_HOST=https://<your-instance>.cloud.databricks.com
DATABRICKS_TOKEN=<your-pat-token>
```

Also configure `~/.dbt/profiles.yml` for dbt to connect to Databricks.

### 3.6 Running the Pipeline

**1. Ingestion (Docker + Meltano):**

```bash
docker build -t lighthouse-ingestion .
docker run --env-file .env lighthouse-ingestion
```

**2. Transformation (dbt + Databricks):**

```bash
dbt deps
dbt run
dbt test
```

**3. Dashboard (Power BI):**

* Open `.pbix` file and connect to the DW.
* Daily refresh scheduled at 21:10 UTC.

**4. Predictive Modeling:**

* Run `Checkpoint5_Modelo_Predição_20250906_Adventure Works_LH` notebook.
* It generates demand forecasts, seasonality analysis, and resource estimates.

### 3.7 Orchestration in Databricks (YAML — **import & run**)

Full orchestration is declared in `databricks_pipeline.yml`.

Steps to deploy:

1. Open **Workflows** (Jobs & Pipelines) in Databricks → **Create Job**.
2. Select **Import from YAML**.
3. Paste contents of `databricks_pipeline.yml`.
4. Configure required parameters (warehouse, schema, catalog).
5. Ensure Parquet files are available in DBFS.
6. Click **Run now** — dependencies (Parquet → Delta → dbt) are already modeled.

---

## 📊 4. Deliverables

| Deliverable                     | Description                                        | Status |
| ------------------------------- | -------------------------------------------------- | ------ |
| Ingestion (Docker + Meltano)    | MSSQL + API → Parquet ingestion pipeline           | ✅      |
| Transformation (Databricks/dbt) | Bronze, Silver, Gold models with tests             | ✅      |
| Dashboard (Power BI)            | Sales, team, and customer insights                 | ✅      |
| Predictive Modeling (Python)    | Demand forecasting, seasonality, growth, resources | ✅      |
| Orchestration (Databricks YAML) | Declarative job in `databricks_pipeline.yml`       | ✅      |
| Final Report (PDF)              | Consolidated analysis & predictions                | ✅      |
| README.md                       | Full project documentation                         | ✅      |

---

## 📚 5. Repository Structure

```
├── Dockerfile
├── entrypoint.sh
├── meltano.yml
├── databricks_pipeline.yml
├── aux_scripts/                       # Auxiliary notebooks (conversion, exploration)
├── models/                            # dbt models (staging + marts)
├── dbt_project.yml
├── requirements.txt
├── profiles.yml
├── demand prediction files (CP5)/     # Predictive modeling artifacts
├── dashboards/                        # Power BI (.pbix)
└── README.md
```

---

## 📈 6. Business Results

* **Demand Forecasting:** 3-month projections per product/store.
* **Seasonality:** Identified in selected SKUs.
* **Regional Growth:** US projected to outpace global growth.
* **Resource Planning (Zippers):** Forecasted material needs for glove production, supporting procurement decisions.

These insights enable **optimized inventory management, cost reduction, and aligned commercial strategy**.

---

## 👨‍💻 7. Credits

Developed by **Alexandre R. Silva Filho**
* **LinkedIn:** [linkedin.com/in/alerodriguessf](https://www.linkedin.com/in/alexandrersf/)
* **GitHub:** [github.com/alerodriguessf](https://github.com/alerodriguessf)
* **Email:** [alerodriguessf@gmail.com](mailto:alerodriguessf@gmail.com)

