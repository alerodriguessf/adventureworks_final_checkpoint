
# 🏭 Adventure Works — Pipeline, Analytics & Predictive Modeling (Lighthouse Checkpoints 2–5)

## 📌 1. Visão Geral do Projeto

Este repositório reúne as entregas dos **Checkpoints 2, 3, 4 e 5** do programa **Lighthouse**, aplicados sobre o dataset **Adventure Works**.  
O objetivo é implementar uma solução de **engenharia e ciência de dados ponta a ponta**, desde a ingestão até a previsão de demanda, garantindo valor estratégico para o negócio.

A jornada incluiu:

- **Checkpoint 2 – Ingestão:** Construção de pipeline de ingestão de dados de múltiplas fontes (MSSQL + API REST) com **Meltano** e **Docker**.  
- **Checkpoint 3 – Transformação:** Criação de um **Data Warehouse** com **Databricks** e **modelagem dimensional com dbt**.  
- **Checkpoint 4 – Dashboard:** Desenvolvimento de um dashboard interativo em **Power BI**, trazendo indicadores de vendas, equipe e clientes.  
- **Checkpoint 5 – Modelagem Preditiva:** Implementação de modelos de previsão de demanda, análise de sazonalidade, crescimento regional e estimativas de insumos.  

---

## 🏗️ 2. Arquitetura da Solução

A arquitetura foi desenhada para ser **modular, escalável e orientada a negócios**:

1. **Ingestão (Checkpoint 2):**
   - **Meltano + Docker** → Extração de dados de MSSQL e API REST.  
   - **Target-Parquet** → Materialização local em formato colunar.  
   - **Databricks CLI** → Upload dos dados para o DBFS.

2. **Transformação e Modelagem (Checkpoint 3):**
   - **Databricks Notebooks** → Conversão dos dados em tabelas **Delta Lake (Bronze)**.  
   - **dbt** → Transformações em camadas **Silver (staging)** e **Gold (marts)**.  
   - **Testes de qualidade e documentação interativa**.

3. **Visualização (Checkpoint 4):**
   - **Power BI** conectado ao DW (8 tabelas principais: 2 fatos e 6 dimensões).  
   - Painéis de **Visão Geral de Vendas** e **Desempenho da Equipe de Vendas** com KPIs, filtros e comparativos.

4. **Modelagem Preditiva (Checkpoint 5):**
   - Modelos de regressão para previsão de demanda.
   - Baseline com **médias móveis**.
   - Comparação entre diferentes modelos com métricas (MAE, RMSE, MAPE).
   - Respostas a perguntas estratégicas de negócio:
     - Previsão de demanda (3 meses).
     - Análise de sazonalidade.
     - Crescimento de centros de distribuição (EUA x Resto do Mundo).
     - Estimativa de insumos (zíperes para luvas).  

---

## ⚙️ 3. Configuração e Execução

### 3.1 Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (v4+)
- [Python 3.10 ou 3.11](https://www.python.org/)
- [Git](https://git-scm.com/)
- Workspace **Databricks** (Free Edition ou superior)
- **Power BI Desktop** (para visualização)
- Credenciais de acesso ao MSSQL e API REST

### 3.2 Clonar o Repositório

```bash
git clone https://github.com/alerodriguessf/adventureworks_final_checkpoint
cd adventureworks_final_checkpoint
````

### 3.3 Criar Ambiente Virtual

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

### 3.4 Instalar Dependências

```bash
pip install -r requirements.txt
```

### 3.5 Configurar Credenciais

Crie um arquivo `.env` (baseado em `.env.save`) com as credenciais:

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

Configure também o arquivo `~/.dbt/profiles.yml` com as credenciais do Databricks para rodar o dbt.

### 3.6 Executando a Pipeline

**1. Ingestão (Docker + Meltano):**

```bash
docker build -t lighthouse-ingestion .
docker run --env-file .env lighthouse-ingestion
```

**2. Transformação (dbt + Databricks):**

```bash
dbt deps
dbt run
dbt test
```

**3. Dashboard (Power BI):**

* Abrir o arquivo `.pbix` e conectar ao DW.
* Atualizações diárias agendadas em 21:10 UTC.

**4. Modelagem Preditiva (Checkpoint 5):**

* Executar o notebook `Checkpoint5_Modelo_Predição_20250906_Adventure Works_LH`.
* Ele gera previsões, análises de sazonalidade e estimativas de insumos.

### 3.7 Orquestração no Databricks (YAML — **import & run**)

Toda a orquestração está **declarada** no arquivo `databricks_pipeline.yml` na raiz do repositório.
Para criar o Job e rodar a pipeline completa diretamente no Databricks:

1. Acesse **Workflows** (Jobs & Pipelines) no seu workspace Databricks e clique em **Create Job**.
2. Na tela do Job, clique em **⋯ > Import from YAML** (ou **Edit YAML** se já existir um job).
3. Abra o arquivo `databricks_pipeline.yml` deste repositório e **copie o conteúdo**.
4. **Cole** no editor YAML do Databricks e **salve**.
5. Preencha/valide os parâmetros exigidos pelo YAML (ex.: `warehouse`, `catalog`, `schema`, `cluster` ou `job_cluster` quando aplicável).
6. Garanta que o **DBFS** já contém os dados em Parquet (saída da ingestão) e que o **cluster/warehouse** tem permissão de acesso ao catálogo.
7. Clique em **Run now** para executar. As dependências entre tarefas (conversões para Delta → `dbt run`) já estão **modeladas no YAML**, então a execução segue a sequência correta automaticamente.

**Requisitos/Observações:**

* Configure um **SQL Warehouse** válido (ou job cluster) e permissões no catálogo/schema.
* As variáveis sensíveis devem estar via **Secrets** ou `.env` (nunca versionar credenciais).
* Em caso de erro, verifique:

  * Caminhos no DBFS (arquivos Parquet disponíveis);
  * `http_path`/`token`/`host` do Databricks (no `profiles.yml` do dbt);
  * Permissões de catálogo/schema e política de acesso ao Warehouse.

---

## 📊 4. Entregáveis

| Entregável                       | Descrição                                                | Status |
| -------------------------------- | -------------------------------------------------------- | ------ |
| Ingestão (Docker + Meltano)      | Pipeline de ingestão de MSSQL e API → Parquet            | ✅      |
| Transformação (Databricks + dbt) | Modelos Bronze, Silver e Gold com testes                 | ✅      |
| Dashboard (Power BI)             | Visão de vendas, equipe e clientes                       | ✅      |
| Modelagem preditiva (Python)     | Previsão de demanda, sazonalidade, crescimento e insumos | ✅      |
| Orquestração (Databricks YAML)   | Job declarativo via `databricks_pipeline.yml`            | ✅      |
| Relatório Final (PDF)            | Consolidado de análises e previsões                      | ✅      |
| README.md                        | Documentação completa do projeto                         | ✅      |

---

## 📚 5. Estrutura do Repositório

```
├── Dockerfile
├── entrypoint.sh
├── meltano.yml
├── databricks_pipeline.yml
├── aux_scripts/                       # Notebooks auxiliares (conversão, exploração)
├── models/                            # dbt models (staging + marts)
├── dbt_project.yml
├── requirements.txt
├── profiles.yml
├── demand prediction files (CP5)/     # Documentos da Modelagem Preditiva
├── dashboards/                        # Power BI (.pbix)
└── README.md
```

---

## 📈 6. Resultados de Negócio (Checkpoint 5)

* **Previsão de Demanda:** projeções para cada produto e loja nos próximos 3 meses.
* **Sazonalidade:** identificada em produtos específicos.
* **Crescimento Regional:** maior crescimento projetado para **EUA** em comparação ao resto do mundo.
* **Insumos (Zíperes):** estimada a quantidade necessária para a produção de luvas nos próximos meses, suportando decisões de compra de matéria-prima.

Esses insights permitem **otimizar estoques, planejar compras, reduzir custos e alinhar estratégias comerciais**.

---

## 👨‍💻 7. Créditos

Desenvolvido por **Alexandre R. Silva Filho** no programa **Lighthouse** – Indicium.

* **LinkedIn:** [linkedin.com/in/alerodriguessf](https://www.linkedin.com/in/alerodriguessf)
* **GitHub:** [github.com/alerodriguessf](https://github.com/alerodriguessf)
* **Email:** [alexandre.filho@indicium.tech](mailto:alexandre.filho@indicium.tech)

---
