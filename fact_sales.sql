<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 750" width="1200" height="750" font-family="Arial, sans-serif">
  <!-- Background -->
  <rect width="1200" height="750" fill="#F8F9FA" rx="10"/>
  
  <!-- Title -->
  <text x="600" y="38" text-anchor="middle" font-size="22" font-weight="bold" fill="#1A1A2E">Retail Sales Analytics Pipeline — Architecture Overview</text>
  <text x="600" y="58" text-anchor="middle" font-size="12" fill="#555">eCloud Optimum Corp | Data Engineer: Ashish Peddineni | Azure Data Factory + Snowflake + Python + DBT</text>
  <line x1="60" y1="68" x2="1140" y2="68" stroke="#2563EB" stroke-width="2"/>

  <!-- LAYER 1: Data Sources -->
  <rect x="30" y="85" width="180" height="560" fill="#EFF6FF" rx="8" stroke="#93C5FD" stroke-width="1.5"/>
  <text x="120" y="108" text-anchor="middle" font-size="13" font-weight="bold" fill="#1D4ED8">DATA SOURCES</text>
  
  <rect x="50" y="120" width="140" height="60" fill="#DBEAFE" rx="6" stroke="#3B82F6" stroke-width="1.5"/>
  <text x="120" y="143" text-anchor="middle" font-size="11" font-weight="bold" fill="#1E40AF">Azure Blob Storage</text>
  <text x="120" y="160" text-anchor="middle" font-size="10" fill="#374151">Sales CSV Files</text>

  <rect x="50" y="195" width="140" height="60" fill="#DBEAFE" rx="6" stroke="#3B82F6" stroke-width="1.5"/>
  <text x="120" y="218" text-anchor="middle" font-size="11" font-weight="bold" fill="#1E40AF">AWS S3</text>
  <text x="120" y="235" text-anchor="middle" font-size="10" fill="#374151">Product Catalog</text>

  <rect x="50" y="270" width="140" height="60" fill="#DBEAFE" rx="6" stroke="#3B82F6" stroke-width="1.5"/>
  <text x="120" y="293" text-anchor="middle" font-size="11" font-weight="bold" fill="#1E40AF">On-Premise DB</text>
  <text x="120" y="310" text-anchor="middle" font-size="10" fill="#374151">Customer Records</text>

  <rect x="50" y="345" width="140" height="60" fill="#DBEAFE" rx="6" stroke="#3B82F6" stroke-width="1.5"/>
  <text x="120" y="368" text-anchor="middle" font-size="11" font-weight="bold" fill="#1E40AF">REST APIs</text>
  <text x="120" y="385" text-anchor="middle" font-size="10" fill="#374151">External Feeds</text>

  <!-- LAYER 2: ADF Orchestration -->
  <rect x="230" y="85" width="200" height="560" fill="#F0FDF4" rx="8" stroke="#86EFAC" stroke-width="1.5"/>
  <text x="330" y="108" text-anchor="middle" font-size="13" font-weight="bold" fill="#15803D">ADF ORCHESTRATION</text>

  <rect x="248" y="120" width="164" height="70" fill="#DCFCE7" rx="6" stroke="#22C55E" stroke-width="1.5"/>
  <text x="330" y="143" text-anchor="middle" font-size="11" font-weight="bold" fill="#166534">Copy Activity</text>
  <text x="330" y="159" text-anchor="middle" font-size="10" fill="#374151">Source → Blob/ADLS</text>
  <text x="330" y="174" text-anchor="middle" font-size="10" fill="#374151">Linked Services</text>

  <rect x="248" y="205" width="164" height="70" fill="#DCFCE7" rx="6" stroke="#22C55E" stroke-width="1.5"/>
  <text x="330" y="228" text-anchor="middle" font-size="11" font-weight="bold" fill="#166534">Data Flow</text>
  <text x="330" y="244" text-anchor="middle" font-size="10" fill="#374151">Mapping &amp; Transform</text>
  <text x="330" y="259" text-anchor="middle" font-size="10" fill="#374151">Schema Enforcement</text>

  <rect x="248" y="290" width="164" height="70" fill="#DCFCE7" rx="6" stroke="#22C55E" stroke-width="1.5"/>
  <text x="330" y="313" text-anchor="middle" font-size="11" font-weight="bold" fill="#166534">Trigger Management</text>
  <text x="330" y="329" text-anchor="middle" font-size="10" fill="#374151">Schedule / Event</text>
  <text x="330" y="344" text-anchor="middle" font-size="10" fill="#374151">Tumbling Window</text>

  <rect x="248" y="375" width="164" height="70" fill="#DCFCE7" rx="6" stroke="#22C55E" stroke-width="1.5"/>
  <text x="330" y="398" text-anchor="middle" font-size="11" font-weight="bold" fill="#166534">Pipeline Monitor</text>
  <text x="330" y="414" text-anchor="middle" font-size="10" fill="#374151">Error Handling</text>
  <text x="330" y="429" text-anchor="middle" font-size="10" fill="#374151">Alerts &amp; Logging</text>

  <!-- LAYER 3: Python ETL -->
  <rect x="450" y="85" width="200" height="560" fill="#FFFBEB" rx="8" stroke="#FCD34D" stroke-width="1.5"/>
  <text x="550" y="108" text-anchor="middle" font-size="13" font-weight="bold" fill="#92400E">PYTHON ETL LAYER</text>

  <rect x="468" y="120" width="164" height="70" fill="#FEF3C7" rx="6" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="550" y="143" text-anchor="middle" font-size="11" font-weight="bold" fill="#78350F">Data Ingestion</text>
  <text x="550" y="159" text-anchor="middle" font-size="10" fill="#374151">pandas / PySpark</text>
  <text x="550" y="174" text-anchor="middle" font-size="10" fill="#374151">Schema Validation</text>

  <rect x="468" y="205" width="164" height="70" fill="#FEF3C7" rx="6" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="550" y="228" text-anchor="middle" font-size="11" font-weight="bold" fill="#78350F">Data Cleansing</text>
  <text x="550" y="244" text-anchor="middle" font-size="10" fill="#374151">Deduplication</text>
  <text x="550" y="259" text-anchor="middle" font-size="10" fill="#374151">Null Handling</text>

  <rect x="468" y="290" width="164" height="70" fill="#FEF3C7" rx="6" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="550" y="313" text-anchor="middle" font-size="11" font-weight="bold" fill="#78350F">Airflow DAGs</text>
  <text x="550" y="329" text-anchor="middle" font-size="10" fill="#374151">Task Orchestration</text>
  <text x="550" y="344" text-anchor="middle" font-size="10" fill="#374151">Dependency Mgmt</text>

  <rect x="468" y="375" width="164" height="70" fill="#FEF3C7" rx="6" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="550" y="398" text-anchor="middle" font-size="11" font-weight="bold" fill="#78350F">Snowflake Loader</text>
  <text x="550" y="414" text-anchor="middle" font-size="10" fill="#374151">Bulk COPY INTO</text>
  <text x="550" y="429" text-anchor="middle" font-size="10" fill="#374151">Merge / Upsert</text>

  <!-- LAYER 4: Snowflake DWH -->
  <rect x="670" y="85" width="210" height="560" fill="#F5F3FF" rx="8" stroke="#C4B5FD" stroke-width="1.5"/>
  <text x="775" y="108" text-anchor="middle" font-size="13" font-weight="bold" fill="#6D28D9">SNOWFLAKE DWH</text>

  <rect x="688" y="120" width="174" height="70" fill="#EDE9FE" rx="6" stroke="#7C3AED" stroke-width="1.5"/>
  <text x="775" y="140" text-anchor="middle" font-size="11" font-weight="bold" fill="#4C1D95">RAW Schema</text>
  <text x="775" y="156" text-anchor="middle" font-size="10" fill="#374151">SALES_ORDERS</text>
  <text x="775" y="171" text-anchor="middle" font-size="10" fill="#374151">PRODUCTS | CUSTOMERS</text>

  <rect x="688" y="205" width="174" height="70" fill="#EDE9FE" rx="6" stroke="#7C3AED" stroke-width="1.5"/>
  <text x="775" y="225" text-anchor="middle" font-size="11" font-weight="bold" fill="#4C1D95">STAGING Schema</text>
  <text x="775" y="241" text-anchor="middle" font-size="10" fill="#374151">STG_SALES_ORDERS</text>
  <text x="775" y="256" text-anchor="middle" font-size="10" fill="#374151">STG_CUSTOMERS | STG_PRODUCTS</text>

  <rect x="688" y="290" width="174" height="70" fill="#EDE9FE" rx="6" stroke="#7C3AED" stroke-width="1.5"/>
  <text x="775" y="310" text-anchor="middle" font-size="11" font-weight="bold" fill="#4C1D95">ANALYTICS Schema</text>
  <text x="775" y="326" text-anchor="middle" font-size="10" fill="#374151">FACT_SALES</text>
  <text x="775" y="341" text-anchor="middle" font-size="10" fill="#374151">DIM_CUSTOMERS | DIM_PRODUCTS</text>

  <rect x="688" y="375" width="174" height="70" fill="#EDE9FE" rx="6" stroke="#7C3AED" stroke-width="1.5"/>
  <text x="775" y="395" text-anchor="middle" font-size="11" font-weight="bold" fill="#4C1D95">DBT Transformations</text>
  <text x="775" y="411" text-anchor="middle" font-size="10" fill="#374151">Data Models &amp; Tests</text>
  <text x="775" y="426" text-anchor="middle" font-size="10" fill="#374151">Incremental Loads</text>

  <!-- LAYER 5: Analytics/BI -->
  <rect x="900" y="85" width="270" height="560" fill="#FFF1F2" rx="8" stroke="#FDA4AF" stroke-width="1.5"/>
  <text x="1035" y="108" text-anchor="middle" font-size="13" font-weight="bold" fill="#BE123C">ANALYTICS &amp; BI</text>

  <rect x="918" y="120" width="234" height="70" fill="#FFE4E6" rx="6" stroke="#F43F5E" stroke-width="1.5"/>
  <text x="1035" y="143" text-anchor="middle" font-size="11" font-weight="bold" fill="#9F1239">Power BI Dashboard</text>
  <text x="1035" y="159" text-anchor="middle" font-size="10" fill="#374151">Sales KPIs &amp; Revenue Trends</text>
  <text x="1035" y="174" text-anchor="middle" font-size="10" fill="#374151">Direct Snowflake Connect</text>

  <rect x="918" y="205" width="234" height="70" fill="#FFE4E6" rx="6" stroke="#F43F5E" stroke-width="1.5"/>
  <text x="1035" y="228" text-anchor="middle" font-size="11" font-weight="bold" fill="#9F1239">Tableau Reports</text>
  <text x="1035" y="244" text-anchor="middle" font-size="10" fill="#374151">Regional Sales Analysis</text>
  <text x="1035" y="259" text-anchor="middle" font-size="10" fill="#374151">Customer Segmentation</text>

  <rect x="918" y="290" width="234" height="70" fill="#FFE4E6" rx="6" stroke="#F43F5E" stroke-width="1.5"/>
  <text x="1035" y="313" text-anchor="middle" font-size="11" font-weight="bold" fill="#9F1239">Datadog Monitoring</text>
  <text x="1035" y="329" text-anchor="middle" font-size="10" fill="#374151">Pipeline Health Metrics</text>
  <text x="1035" y="344" text-anchor="middle" font-size="10" fill="#374151">Alerting &amp; SLA Tracking</text>

  <rect x="918" y="375" width="234" height="70" fill="#FFE4E6" rx="6" stroke="#F43F5E" stroke-width="1.5"/>
  <text x="1035" y="398" text-anchor="middle" font-size="11" font-weight="bold" fill="#9F1239">CI/CD — Git + Jenkins</text>
  <text x="1035" y="414" text-anchor="middle" font-size="10" fill="#374151">DBT Test Automation</text>
  <text x="1035" y="429" text-anchor="middle" font-size="10" fill="#374151">Docker Containerization</text>

  <!-- Arrows between layers -->
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#2563EB"/>
    </marker>
  </defs>
  <line x1="210" y1="300" x2="228" y2="300" stroke="#2563EB" stroke-width="2" marker-end="url(#arrow)"/>
  <line x1="430" y1="300" x2="448" y2="300" stroke="#2563EB" stroke-width="2" marker-end="url(#arrow)"/>
  <line x1="650" y1="300" x2="668" y2="300" stroke="#2563EB" stroke-width="2" marker-end="url(#arrow)"/>
  <line x1="880" y1="300" x2="898" y2="300" stroke="#2563EB" stroke-width="2" marker-end="url(#arrow)"/>

  <!-- Legend/Footer -->
  <rect x="30" y="670" width="1140" height="60" fill="#E0E7FF" rx="6" stroke="#818CF8" stroke-width="1"/>
  <text x="600" y="691" text-anchor="middle" font-size="12" font-weight="bold" fill="#3730A3">Project: Retail Sales Analytics Pipeline | Technologies: Azure Data Factory · Snowflake · Python · DBT · Airflow · AWS S3 · Power BI · Tableau · Datadog · Git · Jenkins · Docker</text>
  <text x="600" y="712" text-anchor="middle" font-size="11" fill="#4338CA">Designed by: Ashish Peddineni, Data Engineer | eCloud Optimum Corp | This pipeline demonstrates degree-level specialization in cloud data engineering</text>
  <text x="600" y="730" text-anchor="middle" font-size="10" fill="#6366F1">Data flows: Source Systems → ADF Ingestion → Python ETL → Snowflake (RAW → STAGING → ANALYTICS) → BI Dashboards | Fully monitored via Datadog | Deployed via CI/CD</text>
</svg>
