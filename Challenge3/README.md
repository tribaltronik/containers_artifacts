# Challenge 3

## Objectives

- created an RBAC enabled AKS cluster within the address space allocated
- 


## Create
# Create an AKS-managed Azure AD cluster
az aks create -g MyResourceGroup -n MyManagedCluster --enable-aad --enable-azure-rbac

## Add Roles

az role assignment create --role "Azure Kubernetes Service RBAC Reader" --assignee <AAD-ENTITY-ID> --scope $AKS_ID/namespaces/<namespace-name>

az role assignment create --assignee "<user@>" --role "Azure Kubernetes Service RBAC writer" --scope 



