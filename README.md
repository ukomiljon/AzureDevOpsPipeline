﻿# End-to-End Guide with Diagram: Deploying Resources Across Dev, UAT, and Prod Environments with Slots Using Bicep, yml, Azure DevOps, with a Web Service Example

![image](https://github.com/user-attachments/assets/b7e6420b-9872-49cd-a060-977b870e69c4)

## Overview

This guide covers the end-to-end process of deploying a web service across three environments: **Dev**, **UAT**, and **Prod**. It includes creating and using deployment slots, deploying to resource groups, promoting changes, and incorporating manual approval stages for each environment to ensure high-quality deployment standards.

### Key Steps:
1. **Deploy Web Service** to **Dev-Resource-Group**.
2. **Promote Web Service** to **UAT-Resource-Group** using a **staging slot**.
3. **Promote Web Service** to **Prod-Resource-Group** after manual approval, using **slot swapping** for zero-downtime deployment.
4. **Manual Approval Stages**: 
   - From **Dev** to **UAT**.
   - From **UAT** to **Prod**.

---

## Key Concepts

- **Deployment Slots**: Enable staging and testing of applications before promoting them to a higher environment.
- **Resource Groups**:
  - **Dev-Resource-Group**: For development testing.
  - **UAT-Resource-Group**: For user acceptance testing.
  - **Prod-Resource-Group**: For live production use.
- **Manual Approvals**: Ensures that a human review is performed before deployment to higher environments.

---

## Deployment Steps

### Step 1: Deploy Web Service to Dev-Resource-Group

1. **Create and Deploy Web Service**:
   - Deploy the **App Service Plan** and **Web App** in the **Dev-Resource-Group** using a Bicep template.

2. **Verify Deployment**:
   - Access the deployed web app to confirm the web service is functional in the development environment.

---

### Step 2: Promote Web Service to UAT-Resource-Group

1. **Staging Slot Creation in Dev**:
   - Deploy a **staging slot** to test the application before promoting to **UAT**.

2. **Deploy to UAT**:
   - After successful testing in Dev, deploy the web service to the **UAT-Resource-Group**.

3. **Manual Approval for UAT**:
   - Ensure **manual review and approval** from the **Reviewer Group** before deployment to **UAT**.

---

### Step 3: Promote Web Service to Prod-Resource-Group

1. **Create Staging Slot in UAT**:
   - Create a **staging slot** in **UAT** to test the web service before promoting to **Prod**.

2. **Promote to Prod**:
   - After UAT approval, deploy the web service to the **Prod-Resource-Group**.

3. **Zero-Downtime Deployment via Slot Swap**:
   - Use **slot swapping** to move the staged application to production without downtime.

4. **Manual Approval for Prod**:
   - Require **manual approval** from the **Reviewer Group** before promoting changes to **Prod**.

---

## Role Definitions

1. **Developer Group**:
   - Responsible for building and maintaining Bicep templates and pipeline configurations.
   - Deploys resources to the **Dev-Resource-Group**.

2. **Reviewer Group**:
   - Approves deployments between **Dev** and **UAT**, as well as from **UAT** to **Prod**.
   - Ensures quality and readiness for deployment.

3. **Admin Group**:
   - Manages pipeline security and RBAC policies.
   - Steps in for critical interventions if needed.

---

## Pipeline Structure in Azure DevOps

### Pipeline Stages

1. **Dev Stage**:
   - Deploy the web service to **Dev-Resource-Group** and create a **staging slot** for testing.

2. **Approval Stage (Dev to UAT)**:
   - Manual approval required from the **Reviewer Group** before deployment to **UAT**.

3. **UAT Stage**:
   - Deploy the web service to **UAT-Resource-Group** and test in a **staging slot**.

4. **Approval Stage (UAT to Prod)**:
   - Manual approval required before promoting to **Prod**.

5. **Prod Stage**:
   - Deploy to **Prod-Resource-Group** using **slot swapping** for zero-downtime deployment.

---

## Text-Based Workflow Diagram

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

## Detailed Deployment Commands

1. **Deploy to Dev**:
   ```bash
   az deployment group create      --resource-group Dev-Resource-Group      --template-file webapp.bicep      --parameters        appServiceName=WebApp-Dev        appServicePlanName=AppPlan-Dev        location=EastUS
   ```

2. **Promote to UAT**:
   ```bash
   az deployment group create      --resource-group UAT-Resource-Group      --template-file webapp.bicep      --parameters        appServiceName=WebApp-UAT        appServicePlanName=AppPlan-UAT        location=EastUS
   ```

3. **Promote to Prod (Slot Swap)**:
   ```bash
   az webapp deployment slot swap      --name WebApp-Prod      --resource-group Prod-Resource-Group      --slot staging      --target-slot production
   ```

---

## Best Practices

1. **Environment Isolation**:
   - Maintain separate resource groups for **Dev**, **UAT**, and **Prod** to ensure proper isolation.

2. **Manual Approval Process**:
   - Implement manual approval gates before promoting code from **Dev** to **UAT**, and from **UAT** to **Prod**.

3. **Monitoring**:
   - Use **Application Insights** for monitoring across all environments to ensure performance.

4. **Access Control with RBAC**:
   - Use **RBAC** to assign appropriate roles and permissions to control access across the environments.

5. **Automation**:
   - Automate slot creation, deployment, and swapping to reduce the risk of manual errors.

---

## Securing Prod Resource Group with Manual Approvals

To ensure that only approved changes are made to the **Prod-Resource-Group**, the following practices are implemented:

### Restricting Manual Changes in Production

1. **Use Azure Resource Locks**:
   - Apply a **ReadOnly** lock to the **Prod-Resource-Group** to prevent unauthorized modifications.
   
2. **Bypass Lock via Pipeline**:
   - Ensure Azure DevOps has sufficient permissions to bypass the lock during deployment.

3. **RBAC Permissions**:
   - Create and assign roles to the **Approver**, **Maker**, and **Admin** groups to control who can approve and make changes to the pipeline.

### Steps for Configuring Locks and RBAC

1. **Apply a ReadOnly Lock**:
   ```bash
   az lock create      --name "ReadOnlyLock"      --resource-group "ProdResourceGroup"      --lock-type "ReadOnly"
   ```

2. **Grant Permissions to the Pipeline**:
   - Ensure the service principal for Azure DevOps has the `Contributor` role on the **Prod-Resource-Group** for deployment tasks.

3. **RBAC Configuration for Groups**:
   ```bash
   az ad group create --display-name "ApproverGroup" --mail-nickname "approvers"
   az ad group create --display-name "MakerGroup" --mail-nickname "makers"
   az ad group create --display-name "AdminGroup" --mail-nickname "admins"

   az role assignment create      --assignee-group "ApproverGroup"      --role "Pipeline Approver"      --scope "/subscriptions/<subscription-id>/resourceGroups/ProdResourceGroup"
   ```

4. **Unlock and Lock Workflow**:
   ```bash
   az lock delete      --name "ReadOnlyLock"      --resource-group "ProdResourceGroup"
   
   # Proceed with deployment

   az lock create      --name "ReadOnlyLock"      --resource-group "ProdResourceGroup"      --lock-type "ReadOnly"
   ```

---

## Final Diagram

```
Developer --> Modify YAML/Bicep --> Deploy to Dev Resource Group

Approver --> Review Pipeline Execution --> Approve for UAT

Pipeline --> Deploy to UAT Resource Group --> Notify Approver

Approver --> Final Approval --> Unlock Prod --> Deploy to Prod Resource Group --> Reapply Lock
```

---

## Conclusion

This setup provides a structured, efficient, and secure method for deploying web services across multiple environments. By using **deployment slots**, **manual approvals**, and **zero-downtime deployment**, the process ensures reliable and controlled deployment while maintaining production integrity.
