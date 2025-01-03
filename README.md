# End-to-End Guide with Diagram: Deploying Resources Across Dev, UAT, and Prod Environments with Slots Using Bicep, Azure DevOps, with a Web Service Example

## Overview

This process includes the following steps:

1. **Deploy Web Service** to **Dev-Resource-Group**.
2. **Promote Web Service** to **UAT-Resource-Group** using a **staging slot**.
3. **Promote Web Service** to **Prod-Resource-Group** after manual approval, using **slot swapping** for zero-downtime deployment.
4. **Manual Approvals**:
   - From **Dev** to **UAT**.
   - From **UAT** to **Prod**.

---

## Key Concepts

- **Deployment Slots**: Used to stage and test applications before promoting to a higher environment.
- **Resource Groups**:
  - **Dev-Resource-Group**: For development testing.
  - **UAT-Resource-Group**: For user acceptance testing.
  - **Prod-Resource-Group**: For live production use.
- **Manual Approvals**: Ensures proper review before promoting changes to critical environments.

---

## Deployment Steps

### Step 1: Deploy Web Service to Dev-Resource-Group

1. **Deploy the Web Service**:
   - Create the **App Service Plan** and **Web App** in the **Dev-Resource-Group** using a Bicep template.

2. **Verify the Web Service**:
   - Access the web app's URL to confirm it is running correctly in the development environment.

---

### Step 2: Promote Web Service to UAT-Resource-Group

1. **Create a Staging Slot** in **Dev-Resource-Group**:
   - Deploy a **staging slot** to test changes before promoting them to **UAT**.

2. **Deploy to UAT**:
   - After testing, deploy the staged application to the **UAT-Resource-Group**.

3. **Manual Approval**:
   - Before deploying to **UAT**, require a **manual review and approval**.

---

### Step 3: Promote Web Service to Prod-Resource-Group

1. **Create a Staging Slot** in **UAT-Resource-Group**:
   - Deploy a **staging slot** in the **UAT** environment for testing before promoting to production.

2. **Promote to Prod**:
   - Once the application passes UAT testing, promote it to the **Prod-Resource-Group**.

3. **Slot Swap for Zero Downtime**:
   - Use **slot swapping** to promote the staging slot to the production environment without downtime.

4. **Manual Approval**:
   - Require **manual approval** before deploying to **Prod**.

---

## Role Definitions

1. **Developer Group**:
   - Builds and manages the **Bicep templates** and **pipeline configurations**.
   - Deploys resources to the **Dev-Resource-Group**.

2. **Reviewer Group**:
   - Approves deployments from **Dev** to **UAT** and from **UAT** to **Prod**.
   - Ensures quality and readiness of the web service.

3. **Admin Group**:
   - Manages overall pipeline security and RBAC policies.
   - Handles critical interventions if necessary.

---

## Pipeline Overview

### Stages in Azure DevOps Pipeline

1. **Dev Stage**:
   - Deploy the web service to **Dev-Resource-Group**.
   - Create a **staging slot** for testing.

2. **Approval Stage (Dev to UAT)**:
   - Manual review by the **Reviewer Group**.

3. **UAT Stage**:
   - Deploy the web service to **UAT-Resource-Group**.
   - Create a **staging slot** for testing.

4. **Approval Stage (UAT to Prod)**:
   - Manual review by the **Reviewer Group**.

5. **Prod Stage**:
   - Deploy the web service to **Prod-Resource-Group**.
   - Perform **slot swapping** for zero-downtime deployment.

---

## Workflow Diagram

### Text-Based Diagram

```
+------------------------+                     +------------------------+                     +------------------------+
|   Dev-Resource-Group   |  Deploy Web App     |   UAT-Resource-Group   |  Deploy to Staging  |   Prod-Resource-Group  |
|   - App Service Plan   | ------------------> |   - App Service Plan   | ------------------> |   - App Service Plan   |
|   - Web App + Slot     |   Manual Approval   |   - Web App + Slot     |   Manual Approval   |   - Web App + Slot     |
+------------------------+                     +------------------------+                     +------------------------+
         |                                                                                              |
         | <----------------------------------- Promote Changes ---------------------------------------> |
         |                                                                                              |
         |                                     Slot Swap for Zero Downtime                              |
         |--------------------------------------------------------------------------------------------->|
```

---

## Detailed Steps

### Deployment Commands

1. **Deploy to Dev**:
   ```bash
   az deployment group create \
     --resource-group Dev-Resource-Group \
     --template-file webapp.bicep \
     --parameters \
       appServiceName=WebApp-Dev \
       appServicePlanName=AppPlan-Dev \
       location=EastUS
   ```

2. **Promote to UAT**:
   ```bash
   az deployment group create \
     --resource-group UAT-Resource-Group \
     --template-file webapp.bicep \
     --parameters \
       appServiceName=WebApp-UAT \
       appServicePlanName=AppPlan-UAT \
       location=EastUS
   ```

3. **Promote to Prod (Slot Swap)**:
   ```bash
   az webapp deployment slot swap \
     --name WebApp-Prod \
     --resource-group Prod-Resource-Group \
     --slot staging \
     --target-slot production
   ```

---

## Best Practices

1. **Environment Isolation**:
   - Use distinct resource groups for **Dev**, **UAT**, and **Prod**.

2. **Approval Process**:
   - Require manual approval to promote changes between environments.

3. **Monitoring**:
   - Enable **Application Insights** for all environments to track performance.

4. **Access Control**:
   - Use **RBAC** to ensure only authorized users can deploy or approve changes.

5. **Automation**:
   - Automate slot creation, deployment, and swapping in the pipeline to minimize manual errors.

---

## Conclusion

This setup provides a robust and scalable process for deploying web services across environments while ensuring proper testing and approval processes. By using deployment slots and manual approvals, the solution minimizes downtime and risks during deployment.
