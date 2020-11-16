# Project templates

This repository contains template definitions to deploy your Kubernetes projects.

## Configuration

Its is necessary to configure some project specific values within the

    deployment-values.yaml

file of your project. This file is a copy of the

    values.yaml

found within this repository.

### Deployment values

This section describes the values that could or must be overwritten by your project. Most of these
values do not need to be changed or will be already applied if you are using the default CI pipeline.

#### name

Set a name for the object, which will be deployed to the cluster. It must be unique within a namespace. This name will applied to each object (deployment, service, ingress etc.) in the cluster, which is created by the chart.

    name: "exampleproject-prod"

> **NOTE** - the name gets overwritten within the default pipeline:
 
    --set name=${CI_PROJECT_NAME}-${CI_ENVIRONMENT_SLUG}

#### contact

Describes the contact person. The chart will automatically add a label named person to each object. This should always be defined by your project.

    contact:
        name: "Alice Henderson"

#### namespace

Defines the namespace where the application should be deployed.

    namespace: "helm-example-1"

> **NOTE** - the namespace gets overwritten within the default pipeline:
  
    export NAMESPACE_PREFIX=$( echo "${CI_PROJECT_NAMESPACE}" | shasum -a 256 | cut -c1-7 )
    --set namespace=${NAMESPACE_PREFIX}-${CI_PROJECT_NAME}
 
> ATTENTION: The current kubernetes-user/ci must have the read/write permissions for this namespace.

#### buildtype

Set the buildtype of the current deployment, e.g. dev, prod etc.

    buildtype: "prod"

> **NOTE** - the buildtype gets overwritten within the default pipeline:

    --set buildtype=${CI_ENVIRONMENT_SLUG}

#### replicas

Number of replicas of the application. Should be greater than 1 to ensure a disruption free service.

    replicas: 1
    
> **OPTIONAL** - Defaults to 1 because there might be concurrency issues in the application.

#### autoscaling

Enable automatic scaling of the application.

More information: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

    autoscaling:
        enabled: false
        # minReplicas: 1
        # maxReplicas: 10
        # targetCPUUtilizationPercentage: 80
        # targetMemoryUtilizationPercentage: 80
    
> **OPTIONAL** - Default: autoscaling disabled

#### resources

Defines resource limits.
Following defaults are set already for the namespace.

         resources:
           limits:
             memory: 512Mi
           requests:
             cpu: 10m
             memory: 32Mi

> **NOTE** - If you need to change them, you MUST talk to the DevOps team first.

#### probe
Defines an endpoint through which a health check is provided.
 This is used by Kubernetes to check when the service is available.
 The port for the probe will be set automatically to 'http' if not defined.

 More Information: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

    probe:
        path: /
        port: http

> **OPTIONAL** - Default: no liveness/startup probe

#### maxBodySize

Set to size of maximum allowed client body size for uploads. Please keep in
mind that huge uploads require temporary buffering of the file by the proxy if
not directly streamed to the backend. Values can be something like `1g` (1000MB)
or `32m` (32MB). More information can befound in the [nginx readme](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md#custom-max-body-size).

    maxBodySize: "1g"

> **OPTIONAL** - Default: not set

### Docker image

The following configurations are only necessary, if you do not use the default CI deployment process.
Otherwise just ignore.

#### dockerhubImage

The image that should be pulled from Docker Hub.

For more information: https://kubernetes.io/docs/concepts/containers/images/

    dockerhubImage: "syseleven/metakube-hello:1.0.0"

#### gitlabImage
The image that should be pulled from GitLab.

    gitlabImage:
       registry: "registry.example.com"
       repository: "registry.example.com/test/service"
       tag: "develop"
       user: "CHANGE-ME-PASSWORD"
       password: "CHANGE-ME-PASSWORD"

> **NODE** - properties set for CI

    --set gitlabImage.registry=${CI_REGISTRY}
    --set gitlabImage.repository=${CI_REGISTRY_IMAGE}
    --set gitlabImage.tag=${CI_ENVIRONMENT_SLUG}
    --set gitlabImage.user=${CI_REGISTRY_USER}
    --set gitlabImage.password=${CI_REGISTRY_PASSWORD}
 
#### environmentVariables
Environment variables that should be available in the container.

    environmentVariables:
      USERNAME: "demo"
      PASSWORD: "demo"

> **OPTIONAL** - Default: no environment variables available)

 
#### containerPort

> **DEPRECATED**, see `ports`.

Port which will be used for traffic by the application.


    containerPort: 8080

> **OPTIONAL** - Default: 8080


#### ports
Defines exposed and usable ports by the application. Keep in mind that only port 80 can be made public available for now,
others are only available within the cluster or via port forwarding.

    ports:
        http:
            container: 8080
            service: 80
        mysql:
            container: 3306
            service: 3306
        metrics:
            container: 10095
            service: 10095

> **OPTIONAL** - Default: container port 8080 mapped to service port 80


### Volumes

Volumes are only necessary if your application needs specific write access to the file system,
e.g. for caching or similar.

> **ATTENTION** - By default, the application has no write access to the file system.

Every replica has its own set of non-persistent volumes, whereas all persistent volumes
will be shared between all replicas. E.g. the persistent Volumes have a ReadWriteOnce access mode.
The unit is set by the chart. The unit is GB, e.g. storageSize: 0.5 equals 500 MB
All folders that are needed for write access MUST be specified below.

#### persistentVolumes
List of all persistent volumes of the application.

    persistentVolumes:
      - path: "/volume-mount-point-1"
        name: "test-volume-1"
        storageSize: 4
      - path: "/volume-mount-point-2"
        name: "test-volume-2"
        storageSize: 0.5

> **OPTIONAL** - Default: no volume mounted

#### temporaryVolumes
Non-persistent volumes will be deleted when the pod is killed, e.g. the application was stopped.

    temporaryVolumes:
      - path: "/var/cache/nginx"
        name: "var-cache-nginx"
      - path: "/tmp"
        name: "tmp"

> **OPTIONAL** - Default: Mount paths "/var/cache/nginx" and "/tmp"


### Domains

#### servePublicly
Set to false if the application should not be available from the internet. In this case all
of the following options will be ignored.

    servePublicly: true

> **OPTIONAL** - Default: true

#### customhosts
Every application has its own unique domain {NAME}-{NAMESPACE}.{CLUSTER-DOMAIN}, e.g.:

    example-1-helm-example-1.delta.k8s-wdy.de

You can add custom hostnames for other domains, e.g.: project.example.com

Each of these hostnames must have a CNAME DNS record with the unique domain from above.
Add domains after the creation of CNAME records.

    customhosts:
      - host: "project.example.com"
        buildtype: prod
        tls: true
        paths:
          - path: "/"
            port: 80

> **OPTIONAL** - Default: no custom domain set
