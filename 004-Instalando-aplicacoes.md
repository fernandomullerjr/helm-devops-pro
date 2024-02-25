
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 4 - Instalação aplicações"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 4 - Instalação aplicações

- Para exemplificar a instalação de uma aplicação, iremos usar o "NGINX Ingress Controller".


1. Adicionar o repositório que tem o "NGINX Ingress Controller".
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

2. Fazer o update:
    helm repo update


~~~~bash
fernando@debian10x64:~$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
"ingress-nginx" has been added to your repositories
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
fernando@debian10x64:~$
~~~~


3. Procurar pelo "NGINX Ingress Controller" nos meus repositórios:
    helm search repo ingress

~~~~bash
fernando@debian10x64:~$ helm search repo ingress
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
ingress-nginx/ingress-nginx     4.4.2           1.5.1           Ingress controller for Kubernetes using NGINX a...
stable/gce-ingress              1.2.2           1.4.0           DEPRECATED A GCE Ingress Controller
stable/ingressmonitorcontroller 1.0.50          1.0.47          DEPRECATED - IngressMonitorController chart tha...
stable/nginx-ingress            1.41.3          v0.34.1         DEPRECATED! An nginx Ingress controller that us...
stable/contour                  0.2.2           v0.15.0         DEPRECATED Contour Ingress controller for Kuber...
stable/external-dns             1.8.0           0.5.14          Configure external DNS servers (AWS Route53, Go...
stable/kong                     0.36.7          1.4             DEPRECATED The Cloud-Native Ingress and API-man...
stable/lamp                     1.1.6           7               DEPRECATED - Modular and transparent LAMP stack...
stable/nginx-lego               0.3.1                           Chart for nginx-ingress-controller and kube-lego
stable/traefik                  1.87.7          1.7.26          DEPRECATED - A Traefik based Kubernetes ingress...
stable/voyager                  3.2.4           6.0.0           DEPRECATED Voyager by AppsCode - Secure Ingress...
fernando@debian10x64:~$
~~~~


Nesse caso ele trouxe tudo que continha ingress.















4. Inspecionar o chart.
    helm inspect all ingress-nginx/ingress-nginx

Ele traz as especificações sobre aquele Chart, TODOS os detalhes dele.


/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect.md

~~~~bash

fernando@debian10x64:~$ helm inspect all ingress-nginx/ingress-nginx
annotations:
  artifacthub.io/changes: |
    - Adding support for disabling liveness and readiness probes to the Helm chart
    - add:(admission-webhooks) ability to set securityContext
    - Updated Helm chart to use the fullname for the electionID if not specified
    - Rename controller-wehbooks-networkpolicy.yaml
  artifacthub.io/prerelease: "false"
apiVersion: v2
appVersion: 1.5.1
description: Ingress controller for Kubernetes using NGINX as a reverse proxy and
  load balancer
home: https://github.com/kubernetes/ingress-nginx
icon: https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Nginx_logo.svg/500px-Nginx_logo.svg.png
keywords:
- ingress
- nginx
kubeVersion: '>=1.20.0-0'
maintainers:
- name: rikatz
- name: strongjz
- name: tao12345666333
name: ingress-nginx
sources:
- https://github.com/kubernetes/ingress-nginx
version: 4.4.2

---
## nginx configuration
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md
##

## Overrides for generated resource names
# See templates/_helpers.tpl
# nameOverride:
# fullnameOverride:

## Labels to apply to all resources
##
commonLabels: {}
# scmhash: abc123
# myLabel: aakkmd

controller:
  name: controller
  image:
    ## Keep false as default for now!
    chroot: false
    registry: registry.k8s.io
    image: ingress-nginx/controller
    ## for backwards compatibility consider setting the full image url via the repository value below
    ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
    ## repository:
    tag: "v1.5.1"
    digest: sha256:4ba73c697770664c1e00e9f968de14e08f606ff961c76e5d7033a4a9c593c629
    digestChroot: sha256:c1c091b88a6c936a83bd7b098662760a87868d12452529bad0d178fb36147345
    pullPolicy: IfNotPresent
    # www-data -> uid 101
    runAsUser: 101
    allowPrivilegeEscalation: true

  # -- Use an existing PSP instead of creating one
  existingPsp: ""

  # -- Configures the controller container name
  containerName: controller

  # -- Configures the ports that the nginx-controller listens on
  containerPort:
    http: 80
    https: 443

  # -- Will add custom configuration options to Nginx https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
  config: {}

  # -- Annotations to be added to the controller config configuration configmap.
  configAnnotations: {}

~~~~


[...]
Restante do inspect omitido.

















5. Inspecionando apenas os Values.
Removemos a palavra "all" do comando anterior e botamos "values":
    helm inspect values ingress-nginx/ingress-nginx


Agora ele traz apenas informações sobre os Values:

~~~~yaml
## nginx configuration
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md
##

## Overrides for generated resource names
# See templates/_helpers.tpl
# nameOverride:
# fullnameOverride:

## Labels to apply to all resources
##
commonLabels: {}
# scmhash: abc123
# myLabel: aakkmd

controller:
  name: controller
  image:
    ## Keep false as default for now!
    chroot: false
    registry: registry.k8s.io
    image: ingress-nginx/controller
    ## for backwards compatibility consider setting the full image url via the repository value below
    ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
    ## repository:
    tag: "v1.5.1"
    digest: sha256:4ba73c697770664c1e00e9f968de14e08f606ff961c76e5d7033a4a9c593c629
    digestChroot: sha256:c1c091b88a6c936a83bd7b098662760a87868d12452529bad0d178fb36147345
    pullPolicy: IfNotPresent
    # www-data -> uid 101
    runAsUser: 101
    allowPrivilegeEscalation: true

  # -- Use an existing PSP instead of creating one
  existingPsp: ""

  # -- Configures the controller container name
  containerName: controller

  # -- Configures the ports that the nginx-controller listens on
  containerPort:
    http: 80
    https: 443

  # -- Will add custom configuration options to Nginx https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
  config: {}

  # -- Annotations to be added to the controller config configuration configmap.
  configAnnotations: {}

  # -- Will add custom headers before sending traffic to backends according to https://github.com/kubernetes/ingress-nginx/tree/main/docs/examples/customization/custom-headers
  proxySetHeaders: {}

  # -- Will add custom headers before sending response traffic to the client according to: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#add-headers
  addHeaders: {}

  # -- Optionally customize the pod dnsConfig.
  dnsConfig: {}

  # -- Optionally customize the pod hostname.
  hostname: {}

  # -- Optionally change this to ClusterFirstWithHostNet in case you have 'hostNetwork: true'.
  # By default, while using host network, name resolution uses the host's DNS. If you wish nginx-controller
  # to keep resolving names inside the k8s network, use ClusterFirstWithHostNet.
  dnsPolicy: ClusterFirst

~~~~


Aqui só consigo ver o Template, não consigo ver os valores deste arquivo.








- Verificando o arquivo "helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect-values.yaml"
Podemos ver as opções que o Template permite.
Como por exemplo, no Kind podemos usar Deployment ou DaemonSet, usando DaemonSet teríamos maior resiliencia, pois haveria uma cópia do ingress em cada Node.

~~~~yaml

  # -- Use a `DaemonSet` or `Deployment`
  kind: Deployment

~~~~







6. Instalando a primeira aplicação, sem personalizar os valores, indo com tudo default por enquanto:
    helm install meu-ingress-controller ingress-nginx/ingress-nginx


~~~~bash

fernando@debian10x64:~$
fernando@debian10x64:~$ helm install meu-ingress-controller ingress-nginx/ingress-nginx
NAME: meu-ingress-controller
LAST DEPLOYED: Sun Jan  1 12:40:22 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w meu-ingress-controller-ingress-nginx-controller'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
fernando@debian10x64:~$

~~~~





~~~~bash

fernando@debian10x64:~$ kubectl get all -A
NAMESPACE     NAME                                                                  READY   STATUS    RESTARTS        AGE
default       pod/meu-ingress-controller-ingress-nginx-controller-85685788f8slnrx   1/1     Running   0               94s
kube-system   pod/coredns-78fcd69978-5xcpp                                          1/1     Running   0               2m48s
kube-system   pod/etcd-minikube                                                     1/1     Running   13              2m59s
kube-system   pod/kube-apiserver-minikube                                           1/1     Running   12              2m59s
kube-system   pod/kube-controller-manager-minikube                                  1/1     Running   13              2m59s
kube-system   pod/kube-proxy-5pc9k                                                  1/1     Running   0               2m48s
kube-system   pod/kube-scheduler-minikube                                           1/1     Running   9               2m59s
kube-system   pod/storage-provisioner                                               1/1     Running   1 (2m23s ago)   2m57s

NAMESPACE     NAME                                                                TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
default       service/kubernetes                                                  ClusterIP      10.96.0.1       <none>        443/TCP                      3m5s
default       service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.108.19.237   <pending>     80:32372/TCP,443:30009/TCP   95s
default       service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.96.51.154    <none>        443/TCP                      95s
kube-system   service/kube-dns                                                    ClusterIP      10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP       3m2s

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   3m2s

NAMESPACE     NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           95s
kube-system   deployment.apps/coredns                                           1/1     1            1           3m2s

NAMESPACE     NAME                                                                         DESIRED   CURRENT   READY   AGE
default       replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       94s
kube-system   replicaset.apps/coredns-78fcd69978                                           1         1         1       2m48s
fernando@debian10x64:~$

~~~~








- Service "EXTERNAL-IP" ficou com status <pending>.



https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending
<https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending>
It looks like you are using a custom Kubernetes Cluster (using minikube, kubeadm or the like). In this case, there is no LoadBalancer integrated (unlike AWS or Google Cloud). With this default setup, you can only use NodePort or an Ingress Controller.

With the Ingress Controller you can setup a domain name which maps to your pod; you don't need to give your Service the LoadBalancer type if you use an Ingress Controller.




minikube service <nome-do-serviço>
minikube service meu-ingress-controller-ingress-nginx-controller
minikube service meu-ingress-controller-ingress-nginx-controller
minikube service meu-ingress-controller-ingress-nginx-controller

fernando@debian10x64:~$ minikube service meu-ingress-controller-ingress-nginx-controller
|-----------|-------------------------------------------------|-------------|---------------------------|
| NAMESPACE |                      NAME                       | TARGET PORT |            URL            |
|-----------|-------------------------------------------------|-------------|---------------------------|
| default   | meu-ingress-controller-ingress-nginx-controller | http/80     | http://192.168.49.2:32372 |
|           |                                                 | https/443   | http://192.168.49.2:30009 |
|-----------|-------------------------------------------------|-------------|---------------------------|
* Opening service default/meu-ingress-controller-ingress-nginx-controller in default browser...




- Abrindo a página:
http://192.168.49.2:32372/

- Retorna a página do NGINX, conforme esperado, mesmo sendo o 404 neste caso:
404 Not Found
nginx






















fernando@debian10x64:~$ kubectl describe svc meu-ingress-controller-ingress-nginx-controller
Name:                     meu-ingress-controller-ingress-nginx-controller
Namespace:                default
Labels:                   app.kubernetes.io/component=controller
                          app.kubernetes.io/instance=meu-ingress-controller
                          app.kubernetes.io/managed-by=Helm
                          app.kubernetes.io/name=ingress-nginx
                          app.kubernetes.io/part-of=ingress-nginx
                          app.kubernetes.io/version=1.5.1
                          helm.sh/chart=ingress-nginx-4.4.2
Annotations:              meta.helm.sh/release-name: meu-ingress-controller
                          meta.helm.sh/release-namespace: default
Selector:                 app.kubernetes.io/component=controller,app.kubernetes.io/instance=meu-ingress-controller,app.kubernetes.io/name=ingress-nginx
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.108.19.237
IPs:                      10.108.19.237
Port:                     http  80/TCP
TargetPort:               http/TCP
NodePort:                 http  32372/TCP
Endpoints:                172.17.0.3:80
Port:                     https  443/TCP
TargetPort:               https/TCP
NodePort:                 https  30009/TCP
Endpoints:                172.17.0.3:443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
fernando@debian10x64:~$





- Expondo Service que do tipo LoadBalancer, que fica com EXTERNAL-IP em pending:
  minikube service <nome-do-serviço>
  minikube service meu-ingress-controller-ingress-nginx-controller






- 

# minikube tunnel

https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-tunnel
<https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-tunnel>

minikube tunnel runs as a process, creating a network route on the host to the service CIDR of the cluster using the cluster’s IP address as a gateway. The tunnel command exposes the external IP directly to any program running on the host operating system.

- Comando para expor ips externos para os Services do tipo LoadBalancer no minikube:
minikube tunnel

fernando@debian10x64:~$
fernando@debian10x64:~$ minikube tunnel
[sudo] password for fernando:
Status:
        machine: minikube
        pid: 23110
        route: 10.96.0.0/12 -> 192.168.49.2
        minikube: Running
        services: [meu-ingress-controller-ingress-nginx-controller]
    errors:
                minikube: no errors
                router: no errors
                loadbalancer emulator: no errors



- Após usar o tunnel, service obteve EXTERNAL-IP:

~~~~bash

fernando@debian10x64:~$ kubectl get all -A
NAMESPACE     NAME                                                                  READY   STATUS    RESTARTS      AGE
default       pod/meu-ingress-controller-ingress-nginx-controller-85685788f8slnrx   1/1     Running   0             12m
kube-system   pod/coredns-78fcd69978-5xcpp                                          1/1     Running   0             13m
kube-system   pod/etcd-minikube                                                     1/1     Running   13            13m
kube-system   pod/kube-apiserver-minikube                                           1/1     Running   12            13m
kube-system   pod/kube-controller-manager-minikube                                  1/1     Running   13            13m
kube-system   pod/kube-proxy-5pc9k                                                  1/1     Running   0             13m
kube-system   pod/kube-scheduler-minikube                                           1/1     Running   9             13m
kube-system   pod/storage-provisioner                                               1/1     Running   1 (13m ago)   13m

NAMESPACE     NAME                                                                TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
default       service/kubernetes                                                  ClusterIP      10.96.0.1       <none>          443/TCP                      13m
default       service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.108.19.237   10.108.19.237   80:32372/TCP,443:30009/TCP   12m
default       service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.96.51.154    <none>          443/TCP                      12m
kube-system   service/kube-dns                                                    ClusterIP      10.96.0.10      <none>          53/UDP,53/TCP,9153/TCP       13m

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   13m

NAMESPACE     NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           12m
kube-system   deployment.apps/coredns                                           1/1     1            1           13m

NAMESPACE     NAME                                                                         DESIRED   CURRENT   READY   AGE
default       replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       12m
kube-system   replicaset.apps/coredns-78fcd69978                                           1         1         1       13m
fernando@debian10x64:~$
fernando@debian10x64:~$

~~~~




10.108.19.237:30009
10.108.19.237:32372


- Através do tunnel do Minikube o Service não ficou acessível através deste ip 10.108.19.237.

- Também não funciona:
 192.168.92.129:30009
 192.168.92.129:32372

- IP 10.108.19.237 só é acessível a partir da VM.





- Somente assim ficou OK a exposição mesmo:
minikube service meu-ingress-controller-ingress-nginx-controller




- Também não ficou ok:
minikube service meu-ingress-controller-ingress-nginx-controller --url
fernando@debian10x64:~$ minikube service meu-ingress-controller-ingress-nginx-controller --url
http://192.168.49.2:32372
http://192.168.49.2:30009
fernando@debian10x64:~$



# PENDENTE
- Ver maneiras de expor os Services do minikube.
- Testar mais o tunnel, ver como expor o ip externo da VM, ao invés do ip 10.



- Video continua em:
07:35







# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
#  Dia 05/01/2023

- Iniciado o Minikube.
- Já tinha a release do ingress da aula passada.

fernando@debian10x64:~$
fernando@debian10x64:~$ helm list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
meu-ingress-controller  default         1               2023-01-01 12:40:22.579954092 -0300 -03 deployed        ingress-nginx-4.4.2     1.5.1
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get all -A
NAMESPACE     NAME                                                                  READY   STATUS    RESTARTS         AGE
default       pod/meu-ingress-controller-ingress-nginx-controller-85685788f8slnrx   1/1     Running   1 (2m55s ago)    4d9h
kube-system   pod/coredns-78fcd69978-5xcpp                                          1/1     Running   1 (2m55s ago)    4d9h
kube-system   pod/etcd-minikube                                                     1/1     Running   14 (2m55s ago)   4d9h
kube-system   pod/kube-apiserver-minikube                                           1/1     Running   13 (2m55s ago)   4d9h
kube-system   pod/kube-controller-manager-minikube                                  1/1     Running   14 (2m55s ago)   4d9h
kube-system   pod/kube-proxy-5pc9k                                                  1/1     Running   1 (2m55s ago)    4d9h
kube-system   pod/kube-scheduler-minikube                                           1/1     Running   10 (2m55s ago)   4d9h
kube-system   pod/storage-provisioner                                               1/1     Running   3 (79s ago)      4d9h

NAMESPACE     NAME                                                                TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
default       service/kubernetes                                                  ClusterIP      10.96.0.1       <none>        443/TCP                      4d9h
default       service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.108.19.237   <pending>     80:32372/TCP,443:30009/TCP   4d9h
default       service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.96.51.154    <none>        443/TCP                      4d9h
kube-system   service/kube-dns                                                    ClusterIP      10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP       4d9h

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   4d9h

NAMESPACE     NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           4d9h
kube-system   deployment.apps/coredns                                           1/1     1            1           4d9h

NAMESPACE     NAME                                                                         DESIRED   CURRENT   READY   AGE
default       replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       4d9h
kube-system   replicaset.apps/coredns-78fcd69978                                           1         1         1       4d9h
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ date
Thu 05 Jan 2023 09:54:19 PM -03
fernando@debian10x64:~$




- Expondo o Service:

minikube service meu-ingress-controller-ingress-nginx-controller

fernando@debian10x64:~$
fernando@debian10x64:~$ minikube service meu-ingress-controller-ingress-nginx-controller
|-----------|-------------------------------------------------|-------------|---------------------------|
| NAMESPACE |                      NAME                       | TARGET PORT |            URL            |
|-----------|-------------------------------------------------|-------------|---------------------------|
| default   | meu-ingress-controller-ingress-nginx-controller | http/80     | http://192.168.49.2:32372 |
|           |                                                 | https/443   | http://192.168.49.2:30009 |
|-----------|-------------------------------------------------|-------------|---------------------------|
* Opening service default/meu-ingress-controller-ingress-nginx-controller in default browser...




- Este endereço só abre ao clicar no link da CLI, num Firefox atrelado a VM do VMWARE: 
http://192.168.49.2:32372/

- Não abre direto no Firefox do Notebook:
192.168.92.129:32372
http://192.168.92.129:32372

fernando@debian10x64:~$ kubectl get nodes -o wide
NAME       STATUS   ROLES                  AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
minikube   Ready    control-plane,master   4d9h   v1.22.2   192.168.49.2   <none>        Ubuntu 20.04.2 LTS   4.19.0-17-amd64   docker://20.10.8
fernando@debian10x64:~$





http://192.168.49.2:32372 


http://192.168.0.125:32372


- Acessível somente na LAN da VM:

fernando@debian10x64:~$ curl http://192.168.49.2:32372
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
fernando@debian10x64:~$






- Node do Minikube sem EXTERNAL-IP:

fernando@debian10x64:~$ kubectl get nodes -o wide
NAME       STATUS   ROLES                  AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
minikube   Ready    control-plane,master   4d9h   v1.22.2   192.168.49.2   <none>        Ubuntu 20.04.2 LTS   4.19.0-17-amd64   docker://20.10.8
fernando@debian10x64:~$




sudo -E minikube start --driver=none


fernando@debian10x64:~$ sudo -E minikube start --driver=none
[sudo] password for fernando:
* minikube v1.23.2 on Debian 10.10
! Deleting existing cluster minikube with different driver docker due to --delete-on-failure flag set by the user.

! Exiting due to GUEST_DRIVER_MISMATCH: The existing "minikube" cluster was created using the "docker" driver, which is incompatible with requested "none" driver.
* Suggestion: Delete the existing 'minikube' cluster using: 'minikube delete', or start the existing 'minikube' cluster using: 'minikube start --driver=docker'

fernando@debian10x64:~$









# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
#  Dia 06/01/2022

- Definido que o expose do Service vai ser via "minikube service meu-ingress-controller-ingress-nginx-controller" mesmo, acessando 
minikube service meu-ingress-controller-ingress-nginx-controller



- Aqui verificamos que ele tá no Namespace "default":


fernando@debian10x64:~$ kubectl get all -A
NAMESPACE     NAME                                                                  READY   STATUS    RESTARTS       AGE
default       pod/meu-ingress-controller-ingress-nginx-controller-85685788f8slnrx   1/1     Running   3 (23h ago)    5d9h
kube-system   pod/coredns-78fcd69978-5xcpp                                          1/1     Running   3 (23h ago)    5d9h
kube-system   pod/etcd-minikube                                                     1/1     Running   16 (23h ago)   5d9h
kube-system   pod/kube-apiserver-minikube                                           1/1     Running   15 (23h ago)   5d9h
kube-system   pod/kube-controller-manager-minikube                                  1/1     Running   16 (23h ago)   5d9h
kube-system   pod/kube-proxy-5pc9k                                                  1/1     Running   3 (23h ago)    5d9h
kube-system   pod/kube-scheduler-minikube                                           1/1     Running   12 (23h ago)   5d9h
kube-system   pod/storage-provisioner                                               1/1     Running   7 (25m ago)    5d9h

NAMESPACE     NAME                                                                TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
default       service/kubernetes                                                  ClusterIP      10.96.0.1       <none>        443/TCP                      5d9h
default       service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.108.19.237   <pending>     80:32372/TCP,443:30009/TCP   5d9h
default       service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.96.51.154    <none>        443/TCP                      5d9h
kube-system   service/kube-dns                                                    ClusterIP      10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP       5d9h

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   5d9h

NAMESPACE     NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
default       deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           5d9h
kube-system   deployment.apps/coredns                                           1/1     1            1           5d9h

NAMESPACE     NAME                                                                         DESIRED   CURRENT   READY   AGE
default       replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       5d9h
kube-system   replicaset.apps/coredns-78fcd69978                                           1         1         1       5d9h
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm ls
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
meu-ingress-controller  default         1               2023-01-01 12:40:22.579954092 -0300 -03 deployed        ingress-nginx-4.4.2     1.5.1
fernando@debian10x64:~$



- Vamos botar o ingress num Namespace isolado. 
- Deixando no Namespace "default" não fica organizado.
- Desinstalar e instalar no Namespace escolhido.

- Desinstalando:
helm uninstall meu-ingress-controller

~~~~bash
fernando@debian10x64:~$ helm uninstall meu-ingress-controller
release "meu-ingress-controller" uninstalled
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm ls
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
fernando@debian10x64:~$
~~~~



- Verificando que agora não temos os recursos relacionados ao ingress:

~~~~bash
fernando@debian10x64:~$ kubectl get all -A
NAMESPACE     NAME                                   READY   STATUS    RESTARTS       AGE
kube-system   pod/coredns-78fcd69978-5xcpp           1/1     Running   3 (24h ago)    5d10h
kube-system   pod/etcd-minikube                      1/1     Running   16 (24h ago)   5d10h
kube-system   pod/kube-apiserver-minikube            1/1     Running   15 (24h ago)   5d10h
kube-system   pod/kube-controller-manager-minikube   1/1     Running   16 (24h ago)   5d10h
kube-system   pod/kube-proxy-5pc9k                   1/1     Running   3 (24h ago)    5d10h
kube-system   pod/kube-scheduler-minikube            1/1     Running   12 (24h ago)   5d10h
kube-system   pod/storage-provisioner                1/1     Running   7 (54m ago)    5d10h

NAMESPACE     NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  5d10h
kube-system   service/kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   5d10h

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   5d10h

NAMESPACE     NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/coredns   1/1     1            1           5d10h

NAMESPACE     NAME                                 DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/coredns-78fcd69978   1         1         1       5d10h
fernando@debian10x64:~$
~~~~




- Criando Namespace separado:
kubectl create namespace nginx-ingress

~~~~bash
fernando@debian10x64:~$ kubectl create namespace nginx-ingress
namespace/nginx-ingress created
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get ns
NAME              STATUS   AGE
default           Active   5d10h
kube-node-lease   Active   5d10h
kube-public       Active   5d10h
kube-system       Active   5d10h
nginx-ingress     Active   4s
fernando@debian10x64:~$
~~~~



- Instalando novamente, especificando o Namespace personalizado:
helm install meu-ingress-controller ingress-nginx/ingress-nginx --namespace nginx-ingress

~~~~bash
fernando@debian10x64:~$ helm install meu-ingress-controller ingress-nginx/ingress-nginx --namespace nginx-ingress
NAME: meu-ingress-controller
LAST DEPLOYED: Fri Jan  6 22:54:24 2023
NAMESPACE: nginx-ingress
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace nginx-ingress get services -o wide -w meu-ingress-controller-ingress-nginx-controller'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
fernando@debian10x64:~$

fernando@debian10x64:~$ helm ls -n nginx-ingress
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
meu-ingress-controller  nginx-ingress   1               2023-01-06 22:54:24.776937292 -0300 -03 deployed        ingress-nginx-4.4.2     1.5.1
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm ls -A
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
meu-ingress-controller  nginx-ingress   1               2023-01-06 22:54:24.776937292 -0300 -03 deployed        ingress-nginx-4.4.2     1.5.1
fernando@debian10x64:~$

~~~~



- Agora é necessário passar o namespace ao tentar listar as releases no Helm.





- Verificando os recursos criados no Namespace e o URL para acesso:

~~~~bash
fernando@debian10x64:~$ kubectl get all -n nginx-ingress
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running   0          6m7s

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.109.154.35    <pending>     80:30078/TCP,443:31591/TCP   6m7s
service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.111.105.194   <none>        443/TCP                      6m7s

NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           6m7s

NAME                                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       6m7s
fernando@debian10x64:~$

fernando@debian10x64:~$ minikube service list
|---------------|-----------------------------------------------------------|--------------|---------------------------|
|   NAMESPACE   |                           NAME                            | TARGET PORT  |            URL            |
|---------------|-----------------------------------------------------------|--------------|---------------------------|
| default       | kubernetes                                                | No node port |
| kube-system   | kube-dns                                                  | No node port |
| nginx-ingress | meu-ingress-controller-ingress-nginx-controller           | http/80      | http://192.168.49.2:30078 |
|               |                                                           | https/443    | http://192.168.49.2:31591 |
| nginx-ingress | meu-ingress-controller-ingress-nginx-controller-admission | No node port |
|---------------|-----------------------------------------------------------|--------------|---------------------------|
fernando@debian10x64:~$
~~~~



- Acessando, ficou ok:
<http://192.168.49.2:30078>
404 Not Found
nginx




- Atualmente nosso Pod tem só 1 replica.
- Vamos adicionar redundancia, 

- Verificando nosso arquivo de Values:
helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect-values.yaml

Temos um campo que diz a quantidade de replicas, é o campo "replicaCount":

~~~~yaml
  replicaCount: 1
~~~~



- Vamos modificar via Values.
- Alterar para 2 o replicaCount:

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect-values.yaml

~~~~yaml
  replicaCount: 2
~~~~





- Como iremos usar somente o  replicaCount, por enquanto, vamos limpar o arquivo de Values, deixando só este campo personalizado mesmo:

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect-values.yaml

~~~~yaml
## nginx configuration
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md
##

controller:

  replicaCount: 2
~~~~




- Agora para atualizar, irei utilizar o comando helm upgrade.

helm upgrade meu-ingress-controller ingress-nginx/ingress-nginx --namespace nginx-ingress --values /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect-values.yaml

~~~~bash
fernando@debian10x64:~$
fernando@debian10x64:~$ helm upgrade meu-ingress-controller ingress-nginx/ingress-nginx --namespace nginx-ingress --values /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/004-saida-do-inspect-values.yaml
Release "meu-ingress-controller" has been upgraded. Happy Helming!
NAME: meu-ingress-controller
LAST DEPLOYED: Fri Jan  6 23:18:51 2023
NAMESPACE: nginx-ingress
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
[...]


fernando@debian10x64:~$ helm ls -A
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
meu-ingress-controller  nginx-ingress   2               2023-01-06 23:18:51.783310368 -0300 -03 deployed        ingress-nginx-4.4.2     1.5.1
fernando@debian10x64:~$

~~~~






- Agora escalou para 2 Pods, conforme nosso values.yaml:

~~~~bash

fernando@debian10x64:~$ kubectl get all -n nginx-ingress
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running   0          26m
pod/meu-ingress-controller-ingress-nginx-controller-85685788f868bbf   1/1     Running   0          2m16s

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.109.154.35    <pending>     80:30078/TCP,443:31591/TCP   26m
service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.111.105.194   <none>        443/TCP                      26m

NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/meu-ingress-controller-ingress-nginx-controller   2/2     2            2           26m

NAME                                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   2         2         2       26m
fernando@debian10x64:~$

~~~~





- Verificando histórico de releases:
helm history meu-ingress-controller --namespace nginx-ingress

~~~~bash

fernando@debian10x64:~$ helm history meu-ingress-controller --namespace nginx-ingress
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Fri Jan  6 22:54:24 2023        superseded      ingress-nginx-4.4.2     1.5.1           Install complete
2               Fri Jan  6 23:18:51 2023        deployed        ingress-nginx-4.4.2     1.5.1           Upgrade complete
fernando@debian10x64:~$

~~~~





- No Helm temos o comando rollback, que retorna para versão anterior:
helm rollback meu-ingress-controller --namespace nginx-ingress

~~~~bash

fernando@debian10x64:~$ helm rollback meu-ingress-controller --namespace nginx-ingress
Rollback was a success! Happy Helming!
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm history meu-ingress-controller --namespace nginx-ingress
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Fri Jan  6 22:54:24 2023        superseded      ingress-nginx-4.4.2     1.5.1           Install complete
2               Fri Jan  6 23:18:51 2023        superseded      ingress-nginx-4.4.2     1.5.1           Upgrade complete
3               Fri Jan  6 23:24:31 2023        deployed        ingress-nginx-4.4.2     1.5.1           Rollback to 1
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get all -n nginx-ingress
NAME                                                                  READY   STATUS        RESTARTS   AGE
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running       0          30m
pod/meu-ingress-controller-ingress-nginx-controller-85685788f868bbf   1/1     Terminating   0          5m46s

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.109.154.35    <pending>     80:30078/TCP,443:31591/TCP   30m
service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.111.105.194   <none>        443/TCP                      30m

NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           30m

NAME                                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       30m
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get all -n nginx-ingress
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running   0          30m

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.109.154.35    <pending>     80:30078/TCP,443:31591/TCP   30m
service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.111.105.194   <none>        443/TCP                      30m

NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/meu-ingress-controller-ingress-nginx-controller   1/1     1            1           30m

NAME                                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   1         1         1       30m
fernando@debian10x64:~$

~~~~










- Agora para atualizar utilizando o set, .
helm upgrade meu-ingress-controller ingress-nginx/ingress-nginx --namespace nginx-ingress --set controller.replicaCount=3

~~~~bash

fernando@debian10x64:~$ helm upgrade meu-ingress-controller ingress-nginx/ingress-nginx --namespace nginx-ingress --set controller.replicaCount=3
Release "meu-ingress-controller" has been upgraded. Happy Helming!
NAME: meu-ingress-controller
LAST DEPLOYED: Fri Jan  6 23:39:04 2023
NAMESPACE: nginx-ingress
STATUS: deployed
REVISION: 4
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.



fernando@debian10x64:~$ helm ls -A
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
meu-ingress-controller  nginx-ingress   4               2023-01-06 23:39:04.263610761 -0300 -03 deployed        ingress-nginx-4.4.2     1.5.1
fernando@debian10x64:~$
fernando@debian10x64:~$


fernando@debian10x64:~$ kubectl get all -n nginx-ingress
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82bj9g   1/1     Running   0          30s
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running   0          45m
pod/meu-ingress-controller-ingress-nginx-controller-85685788f8xpg5v   1/1     Running   0          30s

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.109.154.35    <pending>     80:30078/TCP,443:31591/TCP   45m
service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.111.105.194   <none>        443/TCP                      45m

NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/meu-ingress-controller-ingress-nginx-controller   3/3     3            3           45m

NAME                                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   3         3         3       45m
fernando@debian10x64:~$

~~~~

- Escalou para 3 replicas.
- Foi para o revision 4.

helm history meu-ingress-controller --namespace nginx-ingress

~~~~bash

fernando@debian10x64:~$ helm history meu-ingress-controller --namespace nginx-ingress
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Fri Jan  6 22:54:24 2023        superseded      ingress-nginx-4.4.2     1.5.1           Install complete
2               Fri Jan  6 23:18:51 2023        superseded      ingress-nginx-4.4.2     1.5.1           Upgrade complete
3               Fri Jan  6 23:24:31 2023        superseded      ingress-nginx-4.4.2     1.5.1           Rollback to 1
4               Fri Jan  6 23:39:04 2023        deployed        ingress-nginx-4.4.2     1.5.1           Upgrade complete
fernando@debian10x64:~$

~~~~



- O Set tem maior valor entre o upgrade usando values e o valor default setado.

- Pesos:
1. Set
2. Values
3. Values Default




- Rollback para uma Revision especifica, voltando para o Revision 2, onde tinha 2 Pods de replicas:
helm rollback <nome-do-chart> <numero-do-revision> --namespace nginx-ingress
helm rollback meu-ingress-controller 2 --namespace nginx-ingress

voltando para revision que tinha 2 replicas:

~~~~bash
fernando@debian10x64:~$ helm rollback meu-ingress-controller 2 --namespace nginx-ingress
Rollback was a success! Happy Helming!
fernando@debian10x64:~$
fernando@debian10x64:~$ helm history meu-ingress-controller --namespace nginx-ingress
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Fri Jan  6 22:54:24 2023        superseded      ingress-nginx-4.4.2     1.5.1           Install complete
2               Fri Jan  6 23:18:51 2023        superseded      ingress-nginx-4.4.2     1.5.1           Upgrade complete
3               Fri Jan  6 23:24:31 2023        superseded      ingress-nginx-4.4.2     1.5.1           Rollback to 1
4               Fri Jan  6 23:39:04 2023        superseded      ingress-nginx-4.4.2     1.5.1           Upgrade complete
5               Fri Jan  6 23:54:51 2023        deployed        ingress-nginx-4.4.2     1.5.1           Rollback to 2
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get all -n nginx-ingress
NAME                                                                  READY   STATUS        RESTARTS   AGE
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82bj9g   1/1     Terminating   0          15m
pod/meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running       0          60m
pod/meu-ingress-controller-ingress-nginx-controller-85685788f8xpg5v   1/1     Running       0          15m

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/meu-ingress-controller-ingress-nginx-controller             LoadBalancer   10.109.154.35    <pending>     80:30078/TCP,443:31591/TCP   60m
service/meu-ingress-controller-ingress-nginx-controller-admission   ClusterIP      10.111.105.194   <none>        443/TCP                      60m

NAME                                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/meu-ingress-controller-ingress-nginx-controller   2/2     2            2           60m

NAME                                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/meu-ingress-controller-ingress-nginx-controller-85685788f8   2         2         2       60m
fernando@debian10x64:~$
~~~~