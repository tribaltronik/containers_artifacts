# Challenge 4

## Objectives


### Add addon azure-keyvault-secrets-provider
az aks enable-addons --addons azure-keyvault-secrets-provider --name aks-oh10-ch3 --resource-group teamResources


### Enable managed identity
az aks update -g teamResources -n aks-oh10-ch3 --enable-managed-identity 