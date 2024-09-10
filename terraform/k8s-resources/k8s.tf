provider "kubernetes" {
  host = data.terraform_remote_state.azure_infra.outputs.cluster_host
  client_certificate = base64decode(data.terraform_remote_state.azure_infra.outputs.cluster_client_certificate)
  client_key = base64decode(data.terraform_remote_state.azure_infra.outputs.cluster_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.azure_infra.outputs.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = data.terraform_remote_state.azure_infra.outputs.cluster_host
    client_certificate = base64decode(data.terraform_remote_state.azure_infra.outputs.cluster_client_certificate)
    client_key = base64decode(data.terraform_remote_state.azure_infra.outputs.cluster_client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.azure_infra.outputs.cluster_ca_certificate)
  }
}

data "terraform_remote_state" "azure_infra" {
  backend = "local"
  config = {
    path = "../terraform.tfstate"
  }
}

resource "kubernetes_service_account" "azure_workload_account" {
  metadata {
    name = "workload-identity"
    namespace = "default"
    annotations = {
      "azure.workload.identity/client-id" = data.terraform_remote_state.azure_infra.outputs.aks_workload_identity_client_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

resource "helm_release" "azure_workload_identity_chart" {
  name = "workload-identity-webhook"
  namespace = "azure-workload-identity-system"
  chart = "workload-identity-webhook"
  repository = "https://azure.github.io/azure-workload-identity/charts"

  force_update = false
  create_namespace = true

  set {
    name = "azureTenantID"
    value = data.terraform_remote_state.azure_infra.outputs.tenant_id
  }
}

resource "kubernetes_pod" "quick-test" {
  metadata {
    name = "quick-start"
    namespace = "default"
    labels = {
      "azure.workload.identity/use" = true
    }
  }
  spec {
    service_account_name = "workload-identity"
    container {
      image = "ghcr.io/azure/azure-workload-identity/msal-go"
      name = "oidc"
      env {
        name = "KEYVAULT_URL"
        value = data.terraform_remote_state.azure_infra.outputs.keyvault_uri
      }
      env {
        name = "SECRET-NAME"
        value = "my-secret"
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = 80
        }
        initial_delay_seconds = 3
        period_seconds        = 3
      }


    }
    node_selector = {
      "kubernetes.io/os" = "linux"
    }
  }
  lifecycle {
    ignore_changes = all
  }
  depends_on = [ 
   kubernetes_service_account.azure_workload_account,
   helm_release.azure_workload_identity_chart
   ]
}

