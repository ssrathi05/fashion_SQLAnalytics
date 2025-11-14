import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import psycopg2
from psycopg2 import sql

# Set seaborn theme
sns.set_style("whitegrid")

# Page configuration
st.set_page_config(page_title="Retail Analytics Dashboard", layout="wide")

# Database connection function
@st.cache_resource
def init_connection():
    """Initialize database connection"""
    return psycopg2.connect(
        dbname="retail_db",
        user="postgres",
        password="Ruchit11",  # Replace with your password
        host="localhost",
        port="5432"
    )

def run_sql(query):
    """Execute SQL query and return DataFrame"""
    # Create a fresh connection each time to avoid closed connection issues
    conn = psycopg2.connect(
        dbname="retail_db",
        user="postgres",
        password="Ruchit11",
        host="localhost",
        port="5432"
    )
    try:
        df = pd.read_sql(query, conn)
    finally:
        conn.close()
    return df

# Load all SQL views
@st.cache_data
def load_all_views():
    """Load all SQL views into DataFrames"""
    # Create a fresh connection for loading views
    conn = psycopg2.connect(
        dbname="retail_db",
        user="postgres",
        password="Ruchit11",
        host="localhost",
        port="5432"
    )
    
    try:
        views = {
            'category_performance': pd.read_sql("SELECT * FROM category_performance;", conn),
            'store_performance': pd.read_sql("SELECT * FROM store_performance;", conn),
            'top_sellers': pd.read_sql("SELECT * FROM top_sellers;", conn),
            'top_revenue_products': pd.read_sql("SELECT * FROM top_revenue_products;", conn),
            'cluster_summary': pd.read_sql("SELECT * FROM cluster_summary;", conn),
            'stock_risk_dashboard': pd.read_sql("SELECT * FROM stock_risk_dashboard;", conn),
            'revenue_curve': pd.read_sql("SELECT * FROM revenue_curve;", conn),
            'performance_ranked': pd.read_sql("SELECT * FROM performance_ranked;", conn)
        }
    finally:
        conn.close()
    
    return views

# Main app
st.title("📊 Retail Analytics Dashboard (SQL + Python)")

# Load data
with st.spinner("Loading data from PostgreSQL..."):
    views = load_all_views()

# Sidebar navigation
st.sidebar.title("Navigation")
dashboard_section = st.sidebar.selectbox(
    "Select Dashboard Section",
    [
        "Category Analytics",
        "Store Analytics",
        "Product Performance",
        "Seasonal Growth Analysis",
        "Pareto Analysis",
        "Performance Ranking"
    ]
)

# Category Analytics Section
if dashboard_section == "Category Analytics":
    st.header("Category Performance - Which Categories Drive Revenue?")
    st.markdown("**Business Question:** Which product categories are the biggest revenue drivers, and how do they compare?")
    
    df = views['category_performance']
    
    # Calculate market share
    category_sorted = df.sort_values('total_revenue', ascending=False).copy()
    total_revenue_all = category_sorted['total_revenue'].sum()
    category_sorted['market_share_pct'] = (category_sorted['total_revenue'] / total_revenue_all) * 100
    
    # Charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Revenue by Category (with Market Share)")
        fig, ax = plt.subplots(figsize=(10, 6))
        bars = ax.bar(category_sorted['category'], category_sorted['total_revenue'],
                     color=['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6'][:len(category_sorted)])
        ax.set_title('Revenue by Category (with Market Share)', fontweight='bold')
        ax.set_xlabel('Category')
        ax.set_ylabel('Total Revenue ($)')
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e6:.1f}M'))
        plt.xticks(rotation=45, ha='right')
        
        # Add value and market share labels
        for i, (cat, rev, share) in enumerate(zip(category_sorted['category'], 
                                                  category_sorted['total_revenue'],
                                                  category_sorted['market_share_pct'])):
            ax.text(i, rev, f'${rev/1e6:.1f}M\n({share:.1f}%)', 
                   ha='center', va='bottom', fontsize=9, fontweight='bold')
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Revenue vs Units Sold (Efficiency Analysis)")
        fig, ax = plt.subplots(figsize=(10, 6))
        scatter = ax.scatter(category_sorted['total_units_sold'], category_sorted['total_revenue'],
                           s=300, alpha=0.6, c=['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6'][:len(category_sorted)])
        ax.set_title('Revenue vs Units Sold (Efficiency Analysis)', fontweight='bold')
        ax.set_xlabel('Total Units Sold')
        ax.set_ylabel('Total Revenue ($)')
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e6:.1f}M'))
        ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'{x/1e6:.1f}M'))
        
        # Add category labels
        for i, cat in enumerate(category_sorted['category']):
            ax.annotate(cat, 
                       (category_sorted.iloc[i]['total_units_sold'], 
                        category_sorted.iloc[i]['total_revenue']),
                       xytext=(5, 5), textcoords='offset points', fontsize=9)
        plt.tight_layout()
        st.pyplot(fig)
    
    # Key Insights
    st.subheader("Key Insights")
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Top Revenue Category", category_sorted.iloc[0]['category'], 
                 f"${category_sorted.iloc[0]['total_revenue']/1e6:.2f}M")
    with col2:
        st.metric("Market Share Leader", f"{category_sorted.iloc[0]['market_share_pct']:.1f}%", 
                 category_sorted.iloc[0]['category'])
    with col3:
        st.metric("Avg Revenue/Category", f"${category_sorted['total_revenue'].mean()/1e6:.2f}M")
    with col4:
        st.metric("Revenue Range", 
                 f"${category_sorted['total_revenue'].min()/1e6:.2f}M - ${category_sorted['total_revenue'].max()/1e6:.2f}M")

# Store Analytics Section
elif dashboard_section == "Store Analytics":
    st.header("Store Performance - Which Stores Need Attention?")
    st.markdown("**Business Question:** Which stores are underperforming? Which stores are most efficient?")
    
    df = views['store_performance']
    store_col = df.columns[0]  # First column is store identifier
    
    # Calculate performance metrics
    store_sorted = df.sort_values('total_revenue', ascending=False).copy()
    avg_revenue = store_sorted['total_revenue'].mean()
    store_sorted['vs_avg_pct'] = ((store_sorted['total_revenue'] - avg_revenue) / avg_revenue) * 100
    
    # Charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Store Revenue Performance vs Average")
        fig, ax = plt.subplots(figsize=(10, 6))
        colors = ['#2ecc71' if x >= avg_revenue else '#e74c3c' for x in store_sorted['total_revenue']]
        bars = ax.bar(store_sorted[store_col], store_sorted['total_revenue'], color=colors)
        
        # Add average line
        ax.axhline(y=avg_revenue, color='orange', linestyle='--', linewidth=2, 
                  label=f'Average: ${avg_revenue/1e6:.2f}M')
        
        ax.set_title('Store Revenue Performance vs Average', fontweight='bold')
        ax.set_xlabel('Store ID')
        ax.set_ylabel('Total Revenue ($)')
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e6:.1f}M'))
        ax.legend()
        plt.xticks(rotation=45, ha='right')
        
        # Add labels
        for i, (store, rev, pct) in enumerate(zip(store_sorted[store_col], 
                                                  store_sorted['total_revenue'],
                                                  store_sorted['vs_avg_pct'])):
            ax.text(i, rev, f'${rev/1e6:.1f}M\n({pct:+.1f}%)', 
                   ha='center', va='bottom', fontsize=9, fontweight='bold')
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Revenue vs Units Sold (Efficiency)")
        fig, ax = plt.subplots(figsize=(10, 6))
        scatter = ax.scatter(store_sorted['total_units_sold'], store_sorted['total_revenue'],
                           s=300, alpha=0.6, c=colors)
        ax.set_title('Revenue vs Units Sold (Efficiency)', fontweight='bold')
        ax.set_xlabel('Total Units Sold')
        ax.set_ylabel('Total Revenue ($)')
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e6:.1f}M'))
        ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'{x/1e6:.1f}M'))
        
        # Add store labels
        for i, store in enumerate(store_sorted[store_col]):
            ax.annotate(store, 
                       (store_sorted.iloc[i]['total_units_sold'], 
                        store_sorted.iloc[i]['total_revenue']),
                       xytext=(5, 5), textcoords='offset points', fontsize=9)
        plt.tight_layout()
        st.pyplot(fig)
    
    # Key Insights
    st.subheader("Key Insights")
    top_store = store_sorted.iloc[0]
    bottom_store = store_sorted.iloc[-1]
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Top Performer", top_store[store_col], 
                 f"${top_store['total_revenue']/1e6:.2f}M ({top_store['vs_avg_pct']:+.1f}% vs avg)")
    with col2:
        st.metric("Needs Attention", bottom_store[store_col], 
                 f"${bottom_store['total_revenue']/1e6:.2f}M ({bottom_store['vs_avg_pct']:+.1f}% vs avg)")
    with col3:
        st.metric("Average Store Revenue", f"${avg_revenue/1e6:.2f}M")
    
    st.info(f"💡 **Action:** Investigate why {bottom_store[store_col]} is underperforming")

# Product Performance Section
elif dashboard_section == "Product Performance":
    st.header("Product Performance - Price Elasticity & Top Performers")
    st.markdown("**Business Question:** What's the relationship between price and sales? Which products should we focus on?")
    
    top_sellers_df = views['top_sellers']
    top_revenue_df = views['top_revenue_products']
    
    # Get data for analysis
    price_data = run_sql("""
        SELECT price, units_sold, category, revenue 
        FROM inventory 
        WHERE price IS NOT NULL AND units_sold IS NOT NULL 
        LIMIT 2000
    """)
    
    revenue_risk_data = run_sql("""
        SELECT revenue, stock_risk, category, product_id
        FROM inventory 
        WHERE revenue IS NOT NULL AND stock_risk IS NOT NULL 
        LIMIT 2000
    """)
    
    # Top products
    top_sellers_sorted = top_sellers_df.sort_values('units_sold', ascending=True).head(15)
    top_revenue_sorted = top_revenue_df.sort_values('revenue', ascending=True).head(15)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Top 15 Products by Units Sold")
        fig, ax = plt.subplots(figsize=(10, 8))
        bars1 = ax.barh(range(len(top_sellers_sorted)), top_sellers_sorted['units_sold'],
                       color='#3498db')
        ax.set_yticks(range(len(top_sellers_sorted)))
        ax.set_yticklabels(top_sellers_sorted['product_name'], fontsize=8)
        ax.set_title('Top 15 Products by Units Sold', fontweight='bold')
        ax.set_xlabel('Units Sold')
        ax.invert_yaxis()
        
        # Add value labels
        for i, val in enumerate(top_sellers_sorted['units_sold']):
            ax.text(val, i, f' {int(val):,}', va='center', fontsize=8)
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Top 15 Products by Revenue")
        fig, ax = plt.subplots(figsize=(10, 8))
        bars2 = ax.barh(range(len(top_revenue_sorted)), top_revenue_sorted['revenue'],
                       color='#2ecc71')
        ax.set_yticks(range(len(top_revenue_sorted)))
        ax.set_yticklabels(top_revenue_sorted['product_name'], fontsize=8)
        ax.set_title('Top 15 Products by Revenue', fontweight='bold')
        ax.set_xlabel('Revenue ($)')
        ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e3:.0f}K'))
        ax.invert_yaxis()
        
        # Add value labels
        for i, val in enumerate(top_revenue_sorted['revenue']):
            ax.text(val, i, f' ${val/1e3:.0f}K', va='center', fontsize=8)
        plt.tight_layout()
        st.pyplot(fig)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Price Elasticity: Price vs Units Sold")
        fig, ax = plt.subplots(figsize=(10, 6))
        scatter = ax.scatter(price_data['price'], price_data['units_sold'], 
                           c=price_data['category'].astype('category').cat.codes,
                           alpha=0.5, cmap='tab10', s=30)
        ax.set_title('Price Elasticity: Price vs Units Sold', fontweight='bold')
        ax.set_xlabel('Price ($)')
        ax.set_ylabel('Units Sold')
        ax.grid(True, alpha=0.3)
        
        # Add trend line
        z = np.polyfit(price_data['price'], price_data['units_sold'], 1)
        p = np.poly1d(z)
        ax.plot(price_data['price'].sort_values(), p(price_data['price'].sort_values()), 
               "r--", alpha=0.8, linewidth=2, label='Trend Line')
        ax.legend()
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Revenue vs Stock Risk (Action Required: Top Right)")
        fig, ax = plt.subplots(figsize=(10, 6))
        
        # Identify high-risk, high-revenue products
        median_revenue = revenue_risk_data['revenue'].median()
        median_risk = revenue_risk_data['stock_risk'].median()
        
        scatter = ax.scatter(revenue_risk_data['revenue'], revenue_risk_data['stock_risk'],
                           alpha=0.5, s=30, c='#9b59b6')
        ax.axvline(x=median_revenue, color='orange', linestyle='--', alpha=0.7, label='Median Revenue')
        ax.axhline(y=median_risk, color='orange', linestyle='--', alpha=0.7, label='Median Risk')
        ax.set_title('Revenue vs Stock Risk (Action Required: Top Right)', fontweight='bold')
        ax.set_xlabel('Revenue ($)')
        ax.set_ylabel('Stock Risk')
        ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e3:.0f}K'))
        ax.legend()
        ax.grid(True, alpha=0.3)
        
        # Highlight high-risk, high-revenue products
        high_risk_high_rev = revenue_risk_data[
            (revenue_risk_data['revenue'] > median_revenue) & 
            (revenue_risk_data['stock_risk'] > median_risk)
        ]
        if len(high_risk_high_rev) > 0:
            ax.scatter(high_risk_high_rev['revenue'], high_risk_high_rev['stock_risk'],
                     s=100, c='red', alpha=0.8, marker='X', label='High Risk + High Revenue')
        plt.tight_layout()
        st.pyplot(fig)
    
    # Key Insights
    st.subheader("Key Insights")
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Top Seller", top_sellers_sorted.iloc[-1]['product_name'], 
                 f"{int(top_sellers_sorted.iloc[-1]['units_sold']):,} units")
    with col2:
        st.metric("Top Revenue Generator", top_revenue_sorted.iloc[-1]['product_name'], 
                 f"${top_revenue_sorted.iloc[-1]['revenue']/1e3:.0f}K")
    with col3:
        st.metric("High-Risk Products", f"{len(high_risk_high_rev)} products", 
                 "Need immediate attention")
    
    st.info(f"💡 **Action:** {len(high_risk_high_rev)} products with high revenue AND high stock risk need immediate attention")

# Seasonal Growth Analysis Section
elif dashboard_section == "Seasonal Growth Analysis":
    st.header("Seasonal Growth Analysis - Which Seasons Drive Growth by Category?")
    st.markdown("**Business Question:** Which seasons show the most growth for different product categories? When should we stock up?")
    
    # Get seasonal data by category
    seasonal_data = run_sql("""
        SELECT seasonality, category, 
               SUM(units_sold) as total_units_sold,
               SUM(price * units_sold) as total_revenue,
               AVG(units_sold) as avg_units_sold,
               COUNT(*) as transaction_count
        FROM inventory 
        WHERE seasonality IS NOT NULL AND category IS NOT NULL 
          AND price IS NOT NULL AND units_sold IS NOT NULL
        GROUP BY seasonality, category
        ORDER BY seasonality, category
    """)
    
    # Calculate growth metrics
    overall_avg_units = seasonal_data['avg_units_sold'].mean()
    seasonal_data['growth_vs_avg'] = ((seasonal_data['avg_units_sold'] - overall_avg_units) / overall_avg_units) * 100
    
    # Pivot for heatmap
    pivot_units = seasonal_data.pivot(index='category', columns='seasonality', values='avg_units_sold')
    pivot_growth = seasonal_data.pivot(index='category', columns='seasonality', values='growth_vs_avg')
    pivot_revenue = seasonal_data.pivot(index='category', columns='seasonality', values='total_revenue')
    
    # Create comprehensive seasonal analysis
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Average Units Sold: Season × Category")
        fig, ax = plt.subplots(figsize=(10, 6))
        im1 = ax.imshow(pivot_units.values, cmap='YlOrRd', aspect='auto')
        ax.set_xticks(range(len(pivot_units.columns)))
        ax.set_xticklabels(pivot_units.columns, rotation=45, ha='right')
        ax.set_yticks(range(len(pivot_units.index)))
        ax.set_yticklabels(pivot_units.index)
        ax.set_title('Average Units Sold: Season × Category', fontweight='bold')
        plt.colorbar(im1, ax=ax, label='Avg Units Sold')
        
        # Add text annotations
        for i in range(len(pivot_units.index)):
            for j in range(len(pivot_units.columns)):
                text = ax.text(j, i, f'{pivot_units.iloc[i, j]:.0f}',
                             ha="center", va="center", color="black", fontsize=8)
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Growth % vs Average: Season × Category")
        fig, ax = plt.subplots(figsize=(10, 6))
        im2 = ax.imshow(pivot_growth.values, cmap='RdYlGn', aspect='auto', vmin=-20, vmax=20)
        ax.set_xticks(range(len(pivot_growth.columns)))
        ax.set_xticklabels(pivot_growth.columns, rotation=45, ha='right')
        ax.set_yticks(range(len(pivot_growth.index)))
        ax.set_yticklabels(pivot_growth.index)
        ax.set_title('Growth % vs Average: Season × Category', fontweight='bold')
        plt.colorbar(im2, ax=ax, label='Growth %')
        
        # Add text annotations
        for i in range(len(pivot_growth.index)):
            for j in range(len(pivot_growth.columns)):
                val = pivot_growth.iloc[i, j]
                color = 'white' if abs(val) > 10 else 'black'
                text = ax.text(j, i, f'{val:+.1f}%',
                             ha="center", va="center", color=color, fontsize=8, fontweight='bold')
        plt.tight_layout()
        st.pyplot(fig)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Total Revenue by Category Across Seasons")
        fig, ax = plt.subplots(figsize=(10, 6))
        pivot_revenue.plot(kind='bar', stacked=True, ax=ax, 
                         color=['#3498db', '#2ecc71', '#e74c3c', '#f39c12'])
        ax.set_title('Total Revenue by Category Across Seasons', fontweight='bold')
        ax.set_xlabel('Category')
        ax.set_ylabel('Total Revenue ($)')
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e6:.1f}M'))
        ax.legend(title='Season', bbox_to_anchor=(1.05, 1), loc='upper left')
        plt.xticks(rotation=45, ha='right')
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Peak Season for Each Category")
        fig, ax = plt.subplots(figsize=(10, 6))
        best_seasons = seasonal_data.loc[seasonal_data.groupby('category')['avg_units_sold'].idxmax()]
        best_seasons_sorted = best_seasons.sort_values('avg_units_sold', ascending=True)
        
        bars = ax.barh(range(len(best_seasons_sorted)), best_seasons_sorted['avg_units_sold'],
                     color=['#3498db', '#2ecc71', '#e74c3c', '#f39c12', '#9b59b6'][:len(best_seasons_sorted)])
        ax.set_yticks(range(len(best_seasons_sorted)))
        ax.set_yticklabels([f"{row['category']} ({row['seasonality']})" 
                           for _, row in best_seasons_sorted.iterrows()], fontsize=10)
        ax.set_title('Peak Season for Each Category', fontweight='bold')
        ax.set_xlabel('Average Units Sold')
        ax.invert_yaxis()
        
        # Add value labels
        for i, (units, growth) in enumerate(zip(best_seasons_sorted['avg_units_sold'], 
                                                best_seasons_sorted['growth_vs_avg'])):
            ax.text(units, i, f' {units:.0f} units ({growth:+.1f}%)', 
                  va='center', fontsize=9, fontweight='bold')
        plt.tight_layout()
        st.pyplot(fig)
    
    # Key Insights
    st.subheader("Key Insights")
    strong_seasonal = []
    for category in seasonal_data['category'].unique():
        cat_data = seasonal_data[seasonal_data['category'] == category]
        if len(cat_data) > 1:
            max_units = cat_data['avg_units_sold'].max()
            min_units = cat_data['avg_units_sold'].min()
            if max_units > 0:
                variation = ((max_units - min_units) / max_units) * 100
                if variation > 15:
                    best_season = cat_data.loc[cat_data['avg_units_sold'].idxmax(), 'seasonality']
                    worst_season = cat_data.loc[cat_data['avg_units_sold'].idxmin(), 'seasonality']
                    strong_seasonal.append((category, best_season, worst_season, variation))
    
    if strong_seasonal:
        for cat, best_season, worst_season, var in strong_seasonal[:5]:
            st.info(f"📈 **{cat}**: Peak in {best_season}, Low in {worst_season} ({var:.1f}% variation) - Stock up before {best_season}, reduce inventory in {worst_season}")
    
    st.success("💡 **Strategic Recommendation:** Plan inventory and marketing campaigns around peak seasons for each category")

# Pareto Analysis Section
elif dashboard_section == "Pareto Analysis":
    st.header("Pareto Analysis - The 80/20 Rule")
    st.markdown("**Business Question:** Do 20% of products drive 80% of revenue? Which products should we focus on?")
    
    df = views['revenue_curve']
    
    # Calculate Pareto metrics
    twenty_percent_point = int(len(df) * 0.2)
    revenue_at_20pct = df.iloc[twenty_percent_point]['cumulative_percentage'] if twenty_percent_point < len(df) else 0
    top_20pct_products = df.head(twenty_percent_point + 1)
    
    # Display metrics
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Total Products", len(df))
    with col2:
        st.metric("Top 20% Products", twenty_percent_point)
    with col3:
        st.metric("Revenue from Top 20%", f"{revenue_at_20pct:.1f}%")
    
    # Charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Pareto Curve: 80/20 Rule Analysis")
        fig, ax = plt.subplots(figsize=(10, 6))
        ax.plot(range(len(df)), df['cumulative_percentage'], 
               linewidth=3, color='#3498db', label='Cumulative Revenue %')
        ax.axhline(y=80, color='r', linestyle='--', linewidth=2, label='80% Threshold', alpha=0.7)
        ax.axvline(x=twenty_percent_point, color='g', linestyle='--', linewidth=2, 
                  label='20% of Products', alpha=0.7)
        
        if revenue_at_20pct > 0:
            ax.plot(twenty_percent_point, revenue_at_20pct, 'ro', markersize=12, 
                   label=f'Actual: {revenue_at_20pct:.1f}%')
            ax.annotate(
                f"{revenue_at_20pct:.1f}% revenue\nfrom top 20%",
                xy=(twenty_percent_point, revenue_at_20pct),
                xytext=(twenty_percent_point + len(df)*0.15, revenue_at_20pct + 10),
                arrowprops=dict(arrowstyle='->', color='black', lw=2),
                fontsize=11,
                fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.5', facecolor='yellow', alpha=0.7)
            )
        
        ax.set_title('Pareto Curve: 80/20 Rule Analysis', fontweight='bold')
        ax.set_xlabel('Product Rank (by Revenue)')
        ax.set_ylabel('Cumulative Revenue Percentage')
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(0, 105)
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("Top 20% Products Driving Revenue")
        fig, ax = plt.subplots(figsize=(10, 8))
        if len(top_20pct_products) > 0:
            top_20_sorted = top_20pct_products.sort_values('revenue', ascending=True).head(30)
            bars = ax.barh(range(len(top_20_sorted)), top_20_sorted['revenue'],
                          color='#2ecc71')
            ax.set_yticks(range(len(top_20_sorted)))
            ax.set_yticklabels([f"{row['product_name']}" for _, row in top_20_sorted.iterrows()], 
                             fontsize=7)
            ax.set_title('Top 20% Products Driving Revenue', fontweight='bold')
            ax.set_xlabel('Revenue ($)')
            ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x/1e3:.0f}K'))
            ax.invert_yaxis()
            
            # Add cumulative percentage labels
            for i, (rev, cum_pct) in enumerate(zip(top_20_sorted['revenue'], 
                                                   top_20_sorted['cumulative_percentage'])):
                ax.text(rev, i, f' ${rev/1e3:.0f}K ({cum_pct:.1f}%)', 
                      va='center', fontsize=7)
        plt.tight_layout()
        st.pyplot(fig)
    
    # Key Insights
    st.subheader("Key Insights")
    if revenue_at_20pct >= 75:
        st.success(f"✅ **STRONG PARETO EFFECT:** Top 20% of products generate {revenue_at_20pct:.1f}% of revenue - This confirms the 80/20 rule - focus resources on these {twenty_percent_point} products")
    elif revenue_at_20pct >= 60:
        st.warning(f"⚠️ **MODERATE PARETO EFFECT:** Top 20% of products generate {revenue_at_20pct:.1f}% of revenue - Revenue is more distributed - consider broader product strategy")
    else:
        st.info(f"📊 **WEAK PARETO EFFECT:** Top 20% of products generate {revenue_at_20pct:.1f}% of revenue - Revenue is evenly distributed across products")
    
    st.info(f"💡 **Strategic Recommendation:** Focus inventory management on top {twenty_percent_point} products. These products should never stock out. Consider discontinuing bottom 20% if they're not strategic.")

# Performance Ranking Section
elif dashboard_section == "Performance Ranking":
    st.header("Performance Score - Star Products & Underperformers")
    st.markdown("**Business Question:** Which products are stars? Which should be discontinued?")
    
    df = views['performance_ranked']
    
    # Analyze performance scores
    perf_sorted = df.sort_values('performance_score', ascending=False)
    
    # Categorize products
    top_quartile = perf_sorted['performance_score'].quantile(0.75)
    bottom_quartile = perf_sorted['performance_score'].quantile(0.25)
    
    stars = perf_sorted[perf_sorted['performance_score'] >= top_quartile].head(20)
    underperformers = perf_sorted[perf_sorted['performance_score'] <= bottom_quartile].tail(20)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("STAR PRODUCTS: Top 20 Performers")
        fig, ax = plt.subplots(figsize=(10, 8))
        stars_sorted = stars.sort_values('performance_score', ascending=True)
        bars1 = ax.barh(range(len(stars_sorted)), stars_sorted['performance_score'],
                       color='#2ecc71')
        ax.set_yticks(range(len(stars_sorted)))
        ax.set_yticklabels([f"{row['product_name']} ({row['category']})" 
                           for _, row in stars_sorted.iterrows()], fontsize=8)
        ax.set_title('STAR PRODUCTS: Top 20 Performers', fontweight='bold')
        ax.set_xlabel('Performance Score')
        ax.invert_yaxis()
        
        # Add revenue labels
        for i, (score, rev) in enumerate(zip(stars_sorted['performance_score'], 
                                             stars_sorted['revenue'])):
            ax.text(score, i, f' Score: {score:.0f} | ${rev/1e3:.0f}K', 
                  va='center', fontsize=7, fontweight='bold')
        plt.tight_layout()
        st.pyplot(fig)
    
    with col2:
        st.subheader("UNDERPERFORMERS: Bottom 20 Products")
        fig, ax = plt.subplots(figsize=(10, 8))
        underperformers_sorted = underperformers.sort_values('performance_score', ascending=True)
        bars2 = ax.barh(range(len(underperformers_sorted)), underperformers_sorted['performance_score'],
                       color='#e74c3c')
        ax.set_yticks(range(len(underperformers_sorted)))
        ax.set_yticklabels([f"{row['product_name']} ({row['category']})" 
                           for _, row in underperformers_sorted.iterrows()], fontsize=8)
        ax.set_title('UNDERPERFORMERS: Bottom 20 Products', fontweight='bold')
        ax.set_xlabel('Performance Score')
        ax.invert_yaxis()
        
        # Add revenue labels
        for i, (score, rev) in enumerate(zip(underperformers_sorted['performance_score'], 
                                             underperformers_sorted['revenue'])):
            ax.text(score, i, f' Score: {score:.0f} | ${rev/1e3:.0f}K', 
                  va='center', fontsize=7, fontweight='bold')
        plt.tight_layout()
        st.pyplot(fig)
    
    # Key Insights
    st.subheader("Key Insights")
    col1, col2 = st.columns(2)
    with col1:
        st.success(f"⭐ **STAR PRODUCTS ({len(stars)} products):**\n- Average Performance Score: {stars['performance_score'].mean():.0f}\n- Average Revenue: ${stars['revenue'].mean()/1e3:.0f}K\n\n💡 **ACTION:** Increase inventory, marketing, and shelf space for these products")
    with col2:
        st.error(f"⚠️ **UNDERPERFORMERS ({len(underperformers)} products):**\n- Average Performance Score: {underperformers['performance_score'].mean():.0f}\n- Average Revenue: ${underperformers['revenue'].mean()/1e3:.0f}K\n\n💡 **ACTION:** Consider discontinuing, discounting, or repositioning these products")

# Footer
st.sidebar.markdown("---")
st.sidebar.markdown("**Data Source:** PostgreSQL Database")
st.sidebar.markdown("**Last Updated:** Real-time")

# Run with:
# streamlit run dashboard.py

