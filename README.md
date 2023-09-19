# devops-stack-test-multicluster

Repository that holds the Terraform files for my multicluster test using Camptocamp's [DevOps Stack](https://devops-stack.io/).

```bash
# Create the cluster
summon terraform init && summon terraform apply

# Get the kubeconfig settings for the control-plane cluster
summon-is-sandbox aws eks update-kubeconfig --name gh-control-plane --region eu-west-1 --kubeconfig ~/.kube/is-sandbox-gh-control-plane.config

# Get the kubeconfig settings for the worker 1 cluster
summon-is-sandbox-exo exo compute sks kubeconfig gh-worker-1 kube-admin --zone ch-gva-2 --group system:masters > ~/.kube/is-sandbox-exo-gh-worker-1.config

# Get the kubeconfig settings for the worker 2 cluster
summon-is-sandbox-exo exo compute sks kubeconfig gh-worker-2 kube-admin --zone ch-dk-2 --group system:masters > ~/.kube/is-sandbox-exo-gh-worker-2.config

# Destroy the cluster
summon terraform state rm $(summon terraform state list | grep "argocd_application\|argocd_project\|argocd_cluster\|argocd_repository\|kubernetes_\|helm_") && summon terraform destroy
```
