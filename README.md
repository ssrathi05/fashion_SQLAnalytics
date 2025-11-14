# 📊 Retail Analytics SQL Project

A comprehensive data science project using PostgreSQL, SQL, and Python for retail inventory analytics. This project demonstrates end-to-end data pipeline from raw data to interactive dashboards with advanced analytics and visualizations.

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue.svg)
![Streamlit](https://img.shields.io/badge/Streamlit-1.0+-red.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 Project Overview

This project provides a complete analytics solution for retail inventory management, featuring:

- **SQL-based data pipeline**: From raw CSV to cleaned, analyzed data
- **Feature engineering**: Advanced metrics and performance scores
- **Interactive dashboard**: Real-time analytics with Streamlit
- **Data visualizations**: Comprehensive Jupyter notebook with insights
- **Advanced analytics**: Pareto analysis, seasonal patterns, performance rankings

## 📁 Project Structure

```
fashion_SQLAnalytics/
├── sql/                          # SQL scripts (run in order)
│   ├── schema.sql               # Database schema creation
│   ├── load_data.sql            # Data loading from CSV
│   ├── cleaning.sql             # Data cleaning transformations
│   ├── eda.sql                  # Exploratory data analysis queries
│   ├── feature_engineering.sql  # Feature engineering (new columns)
│   ├── analysis.sql             # Advanced analytics queries
│   └── views.sql                # SQL views for reporting
├── data/                         # Data files
│   └── retail_store_inventory.csv
├── notebooks/                    # Jupyter notebooks
│   └── visualizations.ipynb     # Data visualizations & insights
├── outputs/                      # Output files
│   └── eda_results.txt          # EDA results (if generated)
├── dashboard.py                  # Streamlit dashboard application
├── requirements.txt              # Python dependencies
└── README.md                     # This file
```

## 🚀 Quick Start

### Prerequisites

- PostgreSQL 12+ installed and running
- Python 3.8+
- pip package manager

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd fashion_SQLAnalytics
   ```

2. **Set up PostgreSQL database**
   ```bash
   createdb retail_db
   ```

3. **Run SQL scripts in order** (from project root)
   ```bash
   psql -U postgres -d retail_db -f sql/schema.sql
   psql -U postgres -d retail_db -f sql/load_data.sql
   psql -U postgres -d retail_db -f sql/cleaning.sql
   psql -U postgres -d retail_db -f sql/eda.sql
   psql -U postgres -d retail_db -f sql/feature_engineering.sql
   psql -U postgres -d retail_db -f sql/analysis.sql
   psql -U postgres -d retail_db -f sql/views.sql
   ```

4. **Set up Python environment**
   ```bash
   # Create virtual environment
   python -m venv venv
   
   # Activate virtual environment
   # Windows:
   venv\Scripts\activate
   # Mac/Linux:
   source venv/bin/activate
   
   # Install dependencies
   pip install -r requirements.txt
   ```

5. **Configure database credentials**
   
   Update the database password in:
   - `dashboard.py` (around line 30-35)
   - `notebooks/visualizations.ipynb` (connection settings)

6. **Run the dashboard**
   ```bash
   streamlit run dashboard.py
   ```
   
   The dashboard will open at `http://localhost:8501`

## 📊 Features

### 1. Category Analytics
- Revenue drivers and market share analysis
- Efficiency metrics (revenue vs units sold)
- Category performance comparisons

### 2. Store Performance
- Store benchmarking against average
- Revenue efficiency analysis
- Underperformer identification

### 3. Product Performance
- Price elasticity analysis
- Top sellers and revenue generators
- Stock risk assessment for high-revenue products

### 4. Seasonal Growth Analysis
- Growth patterns by season and category
- Peak season identification
- Inventory planning recommendations

### 5. Pareto Analysis
- 80/20 rule insights
- Top 20% product identification
- Revenue concentration analysis

### 6. Performance Ranking
- Star products identification
- Underperformer analysis
- Actionable recommendations

## 🔄 Project Workflow

The project follows a structured data pipeline:

1. **Schema & Data Loading** → Create tables and load CSV data
2. **Data Cleaning** → Handle missing values, standardize, remove duplicates
3. **Exploratory Data Analysis** → Basic statistics and insights
4. **Feature Engineering** → Add calculated metrics and scores
5. **Advanced Analytics** → Deep dive analysis and patterns
6. **Views Creation** → Pre-defined views for dashboards
7. **Visualizations** → Jupyter notebook with comprehensive charts
8. **Interactive Dashboard** → Streamlit web application

## 🛠️ Technologies Used

- **Database**: PostgreSQL
- **Languages**: SQL, Python
- **Libraries**: 
  - pandas, numpy (data manipulation)
  - matplotlib, seaborn (visualization)
  - psycopg2 (PostgreSQL adapter)
  - streamlit (web dashboard)
- **Tools**: Jupyter Notebook, Streamlit

## 📈 Usage Examples

### Running SQL Queries
```sql
-- Example: View category performance
SELECT * FROM category_performance
ORDER BY total_revenue DESC;
```

### Using the Dashboard
1. Launch: `streamlit run dashboard.py`
2. Navigate through sections using the sidebar
3. Explore interactive visualizations
4. Review key insights and recommendations

### Jupyter Notebook
```bash
jupyter lab notebooks/visualizations.ipynb
```

## 📝 Key Insights

The project provides actionable insights such as:
- Which categories drive the most revenue
- Which stores need attention
- Products at risk of stockout
- Seasonal inventory planning recommendations
- Pareto distribution of product revenue
- Star products vs underperformers

## 🔧 Configuration

### Database Connection
Update connection parameters in:
- `dashboard.py`: Lines 30-35
- `notebooks/visualizations.ipynb`: Connection settings

### CSV Path
If moving the project, update the absolute path in:
- `sql/load_data.sql`: Line 7

## 📦 Dependencies

See `requirements.txt` for full list. Key dependencies:
- streamlit
- pandas
- numpy
- matplotlib
- seaborn
- psycopg2-binary
- jupyter

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

Your Name - [Your GitHub Profile](https://github.com/yourusername)

## 🙏 Acknowledgments

- PostgreSQL community for excellent documentation
- Streamlit team for the amazing dashboard framework
- Data science community for best practices

## 📞 Support

If you have any questions or run into issues:
1. Check the [Issues](../../issues) page
2. Create a new issue with detailed description
3. Include error messages and steps to reproduce

---

⭐ If you found this project helpful, please give it a star!
