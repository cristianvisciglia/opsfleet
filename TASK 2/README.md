# Innovate Inc. Cloud Architecture Design Document

## Executive Summary

This document presents a comprehensive cloud architecture design for Innovate Inc.'s web application deployment. The solution leverages AWS services to provide a robust, scalable, secure, and cost-effective infrastructure that can grow from hundreds to thousands of concurrent users while maintaining high security standards for sensitive user data.

## 1. Cloud Environment Structure

### Recommended AWS Account Structure

We recommend a **multi-account strategy** using AWS Organizations with the following structure:

#### Account Layout:
1. **Management Account** (Root)
   - AWS Organizations management
   - Consolidated billing
   - Cross-account IAM roles
   - Security policies (SCPs)

2. **Development Account**
   - Development environment
   - Testing and experimentation
   - Developer sandboxes

3. **Staging Account**
   - Pre-production environment
   - Integration testing
   - Regression Tests 
   - Performance testing
   - User acceptance testing

4. **Production Account**
   - Live production environment
   - Production data and workloads
   - Backup resources and High Availabilty
   - Strict access controls

5. **OPTIONAL: Sandbox Account**
   - Experimentation 
   - POC projects

#### Justification:
This multi-account strategy provides several critical benefits. The isolation created by clear boundaries between environments prevents accidental changes from affecting production systems. From a security perspective, production isolation significantly reduces the blast radius of security incidents by containing potential threats within specific environments. For billing purposes, this structure enables granular cost tracking per environment, making it easier to understand and optimize spending across different stages of the development lifecycle. The separated environments also make it much easier to meet compliance and regulatory requirements by providing clear audit trails and access controls. Finally, the structure enables access control through environment-specific permissions and policies, ensuring that developers have appropriate access to development resources while maintaining strict controls over production systems.

## 2. Network Design

### VPC Architecture

#### Multi-AZ VPC Design:

**Multi-Region**: Primary region with disaster recovery region
**Availability Zones**: 3 AZs for high availability and fault tolerance
**Network Segmentation**: Layered approach with public, private, and database tiers

#### Subnet Structure:
**Public Subnets (Internet-facing)**:

Distributed across three availability zones
Components: Application Load Balancer, NAT Gateways
Direct internet connectivity for load balancers

**Private Subnets (Application tier)**:

Distributed across three availability zones
Components: EKS worker nodes, application containers
No direct internet access, outbound through NAT Gateways

**Database Subnets (Data tier)**:

Distributed across three availability zones
Components: RDS PostgreSQL instances
Isolated from internet, accessible only from application tier

### Network Security

#### Security Measures:
The network security strategy implements multiple layers of protection to ensure comprehensive coverage. Network ACLs provide subnet-level filtering as the first line of defense, while Security Groups act as instance-level firewall rules for granular access control. A Web Application Firewall (WAF) protects the Application Load Balancer from common web exploits and attacks. VPC Flow Logs enable continuous network traffic monitoring for security analysis and compliance auditing. Private Endpoints are configured for AWS services to keep traffic within the VPC and avoid internet transit. Finally, NAT Gateways provide secure outbound internet access for resources in private subnets while preventing inbound connections from the internet.

#### Traffic Flow:
```
Internet → ALB (Public) → EKS Nodes (Private) → RDS (Private DB Subnets)
```

## 3. Compute Platform

### Frontend Hosting:

- **Service**: Amazon S3 + CloudFront CDN
- **Static Assets**: React SPA hosted on S3 with static website hosting
- **Content Delivery**: CloudFront distribution for global performance
- **Benefits**: Cost-effective, highly scalable, automatic scaling, global edge caching

### Amazon EKS (Elastic Kubernetes Service) - BACKEND

#### Cluster Configuration:
- **Cluster Version**: Latest stable Kubernetes EKS version
- **Control Plane**: Managed by AWS across multiple AZs
- **API Server**: Private endpoint with limited public ips access
- **Add-ons**: AWS Load Balancer Controller, EBS CSI Driver, VPC CNI, Nginx

#### Node Groups Strategy:

**Karpenter-Managed Nodes (Recommended Approach)**:
Karpenter provides intelligent, just-in-time node provisioning that significantly improves upon traditional node groups. Unlike static node groups, Karpenter automatically selects the optimal instance types based on pod requirements, provisioning nodes within seconds rather than minutes. This approach offers several key benefits: cost optimization through intelligent instance selection and automatic consolidation of underutilized nodes, improved scheduling efficiency by selecting instances that best fit workload requirements, reduced waste by avoiding over-provisioning, and enhanced availability through automatic diversification across instance types and availability zones. Karpenter also supports spot instances seamlessly, automatically handling interruptions and re-scheduling workloads, which can provide up to 90% cost savings for fault-tolerant workloads.

**Fallback Node Group** (Baseline):

- **Instance Type**: t3.medium (initial baseline)
- **Scaling**: 1-3 nodes (minimal baseline capacity)
- **Subnet**: Private subnets across 3 AZs
- **Purpose**: System workloads, critical services requiring guaranteed capacity

**Spot Instance Node Pool** (Cost Optimization):
- **Instance Types**: Mixed / Graviton Instances
- **Scaling**: 0-20 nodes
- **Purpose**: Non-critical workloads, batch processing

#### Resource Allocation:
- **CPU Requests**: 100m-500m per container
- **Memory Requests**: 128Mi-1Gi per container
- **Resource Limits**: 2x requests for burstable workloads
- **Horizontal Pod Autoscaler**: CPU and memory-based scaling

### Containerization Strategy

#### Container Registry:
- **Service**: Amazon ECR (Elastic Container Registry)
- **Image Scanning**: Vulnerability scanning enabled
- **Lifecycle Policies**: Automatic cleanup of old images
- **Encryption**: Images encrypted at rest

#### CI/CD Pipeline:
```
GitHub → GitHub Actions → ECR → GitHub Actions EKS Deployment
```

#### Deployment Process:
1. **Source Control**: GitHub repository
2. **Frontend Build Stage**: GitHub Actions
    - Build React SPA
    - Run frontend tests
    - Deploy to S3 bucket
    - Invalidate CloudFront cache
2. **Backend Build Stage**: GitHub Actions
   - Run tests / Lint
   - Build Docker images
   - Security scanning
   - Push to ECR
3. **Backend Deploy Stage**: 
   - Kubernetes manifests
   - Rolling updates
   - Health checks
   - Monitoring dashboards
   - Monitoring Alerts
   - Rollback capability

#### Container Images:
- **Base Images**: Official Python images
- **Multi-stage Builds**: Optimized image sizes
- **Security**: Non-root user, minimal packages
- **Tagging Strategy**: Git commit SHA + semantic versioning

## 4. Database

### Amazon RDS for PostgreSQL

#### Service Recommendation:
**Amazon RDS Multi-AZ PostgreSQL** is recommended for the following reasons:
- **Managed Service**: Automated patching, backups, and maintenance
- **High Availability**: Multi-AZ deployment with automatic failover
- **Security**: Encryption at rest and in transit
- **Scalability**: Read replicas for read scaling
- **Monitoring**: CloudWatch integration and Performance Insights

#### Database Configuration:
- **Engine**: PostgreSQL 15.x
- **Instance Class**: db.t3.micro (initial) → db.r5.xlarge (growth)
- **Storage**: GP3 SSD with imcremental auto-scaling (100GB initial, up to 1TB)
- **Multi-AZ**: Enabled for high availability
- **Encryption**: Enabled with AWS KMS
- **RDS Proxy**: Enabled for connection pooling and management

**RDS Proxy Benefits**:
Amazon RDS Proxy provides significant advantages for application scalability and reliability. The proxy maintains a pool of established connections to the database, reducing the overhead of frequently opening and closing connections. This is particularly beneficial for serverless and containerized applications that may create many short-lived connections. Connection multiplexing allows hundreds of application connections to share a smaller number of database connections, improving resource utilization. The proxy also provides automatic failover capabilities, seamlessly redirecting connections during database failover events without application changes. Enhanced security is achieved through IAM authentication integration and automatic credential management, eliminating the need to embed database credentials in application code. Additionally, the proxy provides improved observability with detailed connection and query metrics through CloudWatch.

#### Backup Strategy:
1. **Automated Backups**:
   - Retention period: 7 days (development), 30 days (production)
   - Backup window: Low-traffic hours
   - Point-in-time recovery enabled

2. **Manual Snapshots**:
   - Pre-deployment snapshots
   - Monthly long-term retention snapshots
   - Cross-region snapshots for disaster recovery

#### High Availability:
- **Multi-AZ Deployment**: Automatic failover to standby
- **Read Replicas**: Up to 5 read replicas for read scaling
- **RDS Proxy**: Intelligent connection routing and automatic failover handling
- **Monitoring**: CloudWatch alarms for database metrics

#### Disaster Recovery:
- **Cross-Region Backups**: Automated snapshots to DR Region
- **DR Testing**: Quarterly disaster recovery drills
- **Data Consistency Tests**

## High-Level Architecture Diagram

![image](https://github.com/user-attachments/assets/fa576a87-cbf4-4044-815e-d2774403e8bf)


## Conclusion

This architecture provides Innovate Inc. with a solid foundation for their web application that can scale from hundreds to millions of users. The multi-account strategy ensures proper isolation and security, while the EKS-based compute platform provides flexibility and scalability. The managed PostgreSQL database ensures high availability and automated maintenance, while the comprehensive security measures protect sensitive user data.

The solution follows AWS Well-Architected Framework principles and incorporates best practices for cost optimization, security, reliability, performance efficiency, and operational excellence.
