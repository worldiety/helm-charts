# worldiety Helm-Charts

This repository hosts all [Helm Charts](https://helm.sh/docs/topics/charts/) of worldiety.
It's main purpose is to provide best practices of Kubernetes deployments.

## Example GitLab CI Integration

Requriements:

* most recent version of the [helm-charts repository](https://github.com/worldiety/helm-charts/)
* customized `values.yaml` file in the project folder
* existing namespace/account for your project (should be created by the DevOps team)

... work in progress ...

## Useful chart debugging commands

```bash
# print resolved template on console (requires a test deployment-values.yaml)
helm template --debug -f deployment-values.yaml --set buildtype=dev --set gitlabImage.repository=testrepo --set name=testname --set namespace=testnamespace helm-charts/project-template/

# create a new namespace (k8s admin access required)
kubectl create namespace namespace-example-1

# create an example app (k8s admin access required)
helm upgrade --install app1 -f values.yaml helm-charts/project-template/
```


## Maintainer

worldiety DevOps Team
