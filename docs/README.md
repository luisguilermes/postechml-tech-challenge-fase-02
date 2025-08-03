# B3 Financial Data Pipeline - Architecture Documentation

This directory contains C4 model architecture diagrams for the B3 Financial Data Pipeline project using PlantUML.

## Diagrams Overview

### 1. Container Diagram (`architecture.puml`)
Shows the high-level architecture with all major containers (applications and data stores) and their relationships. This provides an overview of the system's major building blocks.

**Key Components:**
- Data Ingestion Layer (S3 Raw, Lambda Trigger)
- Data Processing Layer (Glue Job, S3 Refined, Glue Catalog)
- Data Analytics Layer (Athena, Named Queries)
- Visualization Layer (Jupyter Notebook)
- Infrastructure Layer (Terraform, IAM)

### 2. Component Diagram (`components.puml`)
Detailed view of the internal components within each container, focusing on the data processing pipeline implementation.

**Focus Areas:**
- Lambda function components (event parser, Glue client)
- Glue ETL job components (data reader, transformer, writer)
- Athena query engine components (workgroup, partition pruning)
- Storage layer organization

### 3. Sequence Diagram (`sequence.puml`)
Shows the complete data flow from ingestion to analytics, illustrating the interaction between components over time.

**Process Flow:**
1. Data ingestion (External → S3 → Lambda → Glue)
2. Data processing (transformation and cataloging)
3. Data analytics (Athena queries)
4. Visualization (Jupyter notebooks)

### 4. Deployment Diagram (`deployment.puml`)
Illustrates the deployment architecture showing how the system is deployed across AWS services and managed by Terraform.

**Infrastructure:**
- AWS services organization
- Terraform module structure
- IAM roles and policies
- Development environment setup

## How to Use

### Prerequisites
- PlantUML extension for VS Code or
- PlantUML CLI tool or
- Online PlantUML editor

### Viewing Diagrams

#### In VS Code:
1. Install the PlantUML extension
2. Open any `.puml` file
3. Press `Alt+D` to preview the diagram

#### Online:
1. Copy the content of any `.puml` file
2. Go to http://www.plantuml.com/plantuml/uml/
3. Paste the content and view the generated diagram

#### CLI:
```bash
# Generate PNG images
java -jar plantuml.jar *.puml

# Generate SVG images  
java -jar plantuml.jar -tsvg *.puml
```

## Architecture Highlights

### Requirements Fulfillment
- **Requisito 7**: Glue Catalog automatically catalogs data ✅
- **Requisito 8**: Data available in Athena for SQL queries ✅
- **Requisito 9**: Jupyter notebook for data visualization ✅

### Key Technical Decisions
1. **Event-Driven Architecture**: S3 events trigger Lambda functions
2. **Partition Strategy**: Data partitioned by year/month/day/ticker for query optimization
3. **Serverless Processing**: AWS Glue for scalable ETL operations
4. **Infrastructure as Code**: Terraform for reproducible deployments
5. **Modular Design**: Separated concerns across Terraform modules

### Data Flow Summary
```
B3 API → S3 Raw → Lambda → Glue ETL → S3 Refined + Glue Catalog → Athena → Analysis
```

### Scalability Features
- Automatic partition pruning in Athena
- Serverless compute (Lambda + Glue)
- S3 for unlimited storage
- Modular Terraform for environment replication

## File Structure
```
docs/
├── README.md              # This file
├── architecture.puml      # C4 Container diagram
├── components.puml        # C4 Component diagram  
├── sequence.puml          # Sequence diagram
└── deployment.puml        # Deployment diagram
```

## Updating Diagrams

When making changes to the infrastructure:
1. Update the relevant `.puml` files
2. Regenerate the diagrams
3. Update this README if new components are added
4. Commit changes to version control

## Additional Resources

- [C4 Model Documentation](https://c4model.com/)
- [PlantUML Documentation](https://plantuml.com/)
- [AWS Architecture Icons](https://aws.amazon.com/architecture/icons/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
