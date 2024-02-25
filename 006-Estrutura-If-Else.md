
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 6 - Estrutura If/Else -"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 6 - Estrutura If/Else


- Quando queremos usar um Secret, de forma dinâmica, sem passar no Values, usando um Secret já existente nas variáveis do trecho "env" no manifesto do Mongo-Deployment, por exemplo.

- Pasta com os manifestos do Chart:
/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates

- Mongo-Deployment

ANTES

~~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-mongodb
  template:
    metadata:     
      labels:
        app: {{ .Release.Name }}-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:{{ .Values.mongodb.tag }}
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        env:        
          - name: MONGO_INITDB_ROOT_USERNAME
            value: {{ .Values.mongodb.credentials.userName }}
          - name: MONGO_INITDB_ROOT_PASSWORD
            value: {{ .Values.mongodb.credentials.userPassword }}
~~~~






# SECRET

- Criar manifesto para o Secret.
na pasta
/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates


- O manifesto do Secret vai ficar assim:

~~~~YAML
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword }}
~~~~


- Neste formato temos um problema, pois o valor do campo "MONGO_INITDB_ROOT_USERNAME" vai receber um valor simples, o username mongouser. Porém o Secret precisa do valor em base64.
- Precisamos do valor encodado.
- Iremos usar funções, usando o pipe | e adicionando funções necessárias.
    b64enc - passar para base64 o valor
    quote - adiciona aspas.

- Ajustando:

~~~~YAML
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName | b64enc | quote }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword | b64enc | quote }}
~~~~


- Mais exemplos de funções no Helm:
https://helm.sh/docs/howto/charts_tips_and_tricks/
<https://helm.sh/docs/howto/charts_tips_and_tricks/>


http://masterminds.github.io/sprig/encoding.html
<http://masterminds.github.io/sprig/encoding.html>
    b64enc/b64dec: Encode or decode with Base64
    b32enc/b32dec: Encode or decode with Base32




## Quote Strings, Don't Quote Integers

When you are working with string data, you are always safer quoting the strings than leaving them as bare words:

name: {{ .Values.MyName | quote }}

But when working with integers do not quote the values. That can, in many cases, cause parsing errors inside of Kubernetes.

port: {{ .Values.Port }}




- Ajustando o manifesto do MongoDB Deployment:

DE:

~~~YAML
        env:        
          - name: MONGO_INITDB_ROOT_USERNAME
            value: {{ .Values.mongodb.credentials.userName }}
          - name: MONGO_INITDB_ROOT_PASSWORD
            value: {{ .Values.mongodb.credentials.userPassword }}
~~~

PARA:

~~~YAML
        envFrom:
          - secretRef:
            name: {{ .Release.Name }}-mongodb-secret
~~~




cd /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto
cd /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto


- Simulando upgrade:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug


- Apresentou erro:

~~~~bash
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
Error: UPGRADE FAILED: error validating "": error validating data: ValidationError(Deployment.spec.template.spec.containers[0].envFrom[0]): unknown field "name" in io.k8s.api.core.v1.EnvFromSource
helm.go:84: [debug] error validating "": error validating data: ValidationError(Deployment.spec.template.spec.containers[0].envFrom[0]): unknown field "name" in io.k8s.api.core.v1.EnvFromSource
helm.sh/helm/v3/pkg/kube.scrubValidationError
        helm.sh/helm/v3/pkg/kube/client.go:643
helm.sh/helm/v3/pkg/kube.(*Client).Build
        helm.sh/helm/v3/pkg/kube/client.go:215
helm.sh/helm/v3/pkg/action.validateManifest
        helm.sh/helm/v3/pkg/action/upgrade.go:531
helm.sh/helm/v3/pkg/action.(*Upgrade).prepareUpgrade
        helm.sh/helm/v3/pkg/action/upgrade.go:259
helm.sh/helm/v3/pkg/action.(*Upgrade).RunWithContext
        helm.sh/helm/v3/pkg/action/upgrade.go:143
main.newUpgradeCmd.func2
        helm.sh/helm/v3/cmd/helm/upgrade.go:199
github.com/spf13/cobra.(*Command).execute
        github.com/spf13/cobra@v1.5.0/command.go:872
github.com/spf13/cobra.(*Command).ExecuteC
        github.com/spf13/cobra@v1.5.0/command.go:990
github.com/spf13/cobra.(*Command).Execute
        github.com/spf13/cobra@v1.5.0/command.go:918
main.main
        helm.sh/helm/v3/cmd/helm/helm.go:83
runtime.main
        runtime/proc.go:250
runtime.goexit
        runtime/asm_amd64.s:1571
UPGRADE FAILED
main.newUpgradeCmd.func2
        helm.sh/helm/v3/cmd/helm/upgrade.go:201
github.com/spf13/cobra.(*Command).execute
        github.com/spf13/cobra@v1.5.0/command.go:872
github.com/spf13/cobra.(*Command).ExecuteC
        github.com/spf13/cobra@v1.5.0/command.go:990
github.com/spf13/cobra.(*Command).Execute
        github.com/spf13/cobra@v1.5.0/command.go:918
main.main
        helm.sh/helm/v3/cmd/helm/helm.go:83
runtime.main
        runtime/proc.go:250
runtime.goexit
        runtime/asm_amd64.s:1571
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$


fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS  CHART                   APP VERSION
minhaapi        default         1               2023-01-14 00:39:29.189971908 -0300 -03 failed  api-produto-0.1.0       1.16.0
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$

~~~~






- Analisando, foi ajustada a identação do YAML, na parte sobre o name da Secret:

~~~~YAML
        envFrom:
          - secretRef:
              name: {{ .Release.Name }}-mongodb-secret
~~~~


- Nova tentativa de upgrade usando Dry-Run, para validar:
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug

- Funcionou, porém o valor do "MONGO_INITDB_ROOT_USERNAME" e do "MONGO_INITDB_ROOT_PASSWORD" não ficou em base64:

~~~~bash
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:150: [debug] performing update for minhaapi
upgrade.go:313: [debug] dry run for minhaapi
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 14 20:35:29 2023
NAMESPACE: default
STATUS: pending-upgrade
REVISION: 2
TEST SUITE: None
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: LoadBalancer
mongodb:
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  tag: 4.2.8

HOOKS:
MANIFEST:
---
# Source: api-produto/templates/mongodb-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: minhaapi-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: mongouser
  MONGO_INITDB_ROOT_PASSWORD: mongopwd
---
# Source: api-produto/templates/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-api-service
spec:
  selector:
    app: minhaapi-api
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
---
# Source: api-produto/templates/mongodb-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-mongo-service
spec:
  selector:
    app: minhaapi-mongodb
  ports:
  - port: 27017
    targetPort: 27017
---
# Source: api-produto/templates/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-api-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-api
  template:
    metadata:
      labels:
        app: minhaapi-api
    spec:
      containers:
      - name: api
        image: fabricioveronez/pedelogo-catalogo:v1
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        env:
          - name: Mongo__User
            value: mongouser
          - name: Mongo__Password
            value: mongopwd
          - name: Mongo__Host
            value: minhaapi-mongo-service
          - name: Mongo__DataBase
            value: admin
---
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: minhaapi-mongodb-secret

NOTES:
Instalado
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$

~~~~







- Pegando o ajustado de antes, que faltou passar pro manifesto do Secret, que acabou ficando sem os "b64enc | quote" para encodar:

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates/mongodb-secret.yaml

DE:

~~~~YAML
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword }}
~~~~

PARA:

~~~~YAML
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName | b64enc | quote }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword | b64enc | quote }}
~~~~



- Nova tentativa de upgrade usando Dry-Run, para validar:
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug

- Funcionou, pt2, agora gerou todos os manifestos e encodou as Secrets em base64, conforme o esperado:
  MONGO_INITDB_ROOT_USERNAME: "bW9uZ291c2Vy"
  MONGO_INITDB_ROOT_PASSWORD: "bW9uZ29wd2Q="

~~~~bash
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:150: [debug] performing update for minhaapi
upgrade.go:313: [debug] dry run for minhaapi
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 14 20:39:11 2023
NAMESPACE: default
STATUS: pending-upgrade
REVISION: 2
TEST SUITE: None
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: LoadBalancer
mongodb:
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  tag: 4.2.8

HOOKS:
MANIFEST:
---
# Source: api-produto/templates/mongodb-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: minhaapi-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: "bW9uZ291c2Vy"
  MONGO_INITDB_ROOT_PASSWORD: "bW9uZ29wd2Q="
---
# Source: api-produto/templates/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-api-service
spec:
  selector:
    app: minhaapi-api
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
---
# Source: api-produto/templates/mongodb-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-mongo-service
spec:
  selector:
    app: minhaapi-mongodb
  ports:
  - port: 27017
    targetPort: 27017
---
# Source: api-produto/templates/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-api-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-api
  template:
    metadata:
      labels:
        app: minhaapi-api
    spec:
      containers:
      - name: api
        image: fabricioveronez/pedelogo-catalogo:v1
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        env:
          - name: Mongo__User
            value: mongouser
          - name: Mongo__Password
            value: mongopwd
          - name: Mongo__Host
            value: minhaapi-mongo-service
          - name: Mongo__DataBase
            value: admin
---
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: minhaapi-mongodb-secret

NOTES:
Instalado
fernando@debian10x64:~/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto$

~~~~






git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 6 - Estrutura If/Else - TSHOOT - Ajustado o base64 nas Secrets usando a função b64enc"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





- Agora precisamos ajustar na API.
- No caso da API, vamos gerar um ConfigMap.

~~~~YAML
apiVersion: v1
kind: ConfigMap
metadata:
    name: {{ .Release.Name }}-api-configmap
data:
    Mongo__Host: {{ .Release.Name }}-mongo-service
    Mongo__DataBase: {{ .Values.mongodb.databaseName }}
~~~~


- Atualmente o Deployment do API está assim:

~~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-api-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-api
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-api
    spec:
      containers:
      - name: api
        image: {{ .Values.api.image }}
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        env:
          - name: Mongo__User
            value: {{ .Values.mongodb.credentials.userName }}
          - name: Mongo__Password
            value: {{ .Values.mongodb.credentials.userPassword }}
          - name: Mongo__Host
            value: {{ .Release.Name }}-mongo-service
          - name: Mongo__DataBase
            value: {{ .Values.mongodb.databaseName }}

~~~~





# PENDENTE:
- Continua em 09:43.
- Modificar os campos de ENV no Deployment do API, usar ConfigMAP.







# EXEMPLO - Uso de ConfigMap envFrom

Use envFrom to define all of the ConfigMap's data as container environment variables. The key from the ConfigMap becomes the environment variable name in the Pod.
pods/pod-configmap-envFrom.yaml [Copy pods/pod-configmap-envFrom.yaml to clipboard]

~~~~YAML
apiVersion: v1
  kind: Pod
  metadata:
    name: dapi-test-pod
  spec:
    containers:
      - name: test-container
        image: registry.k8s.io/busybox
        command: [ "/bin/sh", "-c", "env" ]
        envFrom:
        - configMapRef:
            name: special-config
    restartPolicy: Never
~~~~



# EXEMPLO - Uso de Secret

This is an example of a Pod that uses a Secret via environment variables:

~~~~YAML
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
            optional: false # same as default; "mysecret" must exist
                            # and include a key named "username"
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
            optional: false # same as default; "mysecret" must exist
                            # and include a key named "password"
  restartPolicy: Never
~~~~





- Ajustando o manifesto do Deployment do API:
adicionando referencia de ENV do ConfigMap, da onde pegaremos os valores de Mongo__Host e Mongo__DataBase.

        envFrom:
          - configMapRef:
              name: {{ .Release.Name }}-api-configmap



- Já os valores de User e Password, vamos pegar do Secret do MongoDB.
adicionando referencia ao Secret
exemplo:

        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username

usando a Secret do Mongo
{{ .Release.Name }}-mongodb-secret

        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_USERNAME
                key: {{ .Release.Name }}-mongodb-secret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_PASSWORD
                key: {{ .Release.Name }}-mongodb-secret



- Ficou assim o Deployment da API:

~~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-api-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-api
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-api
    spec:
      containers:
      - name: api
        image: {{ .Values.api.image }}
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: {{ .Release.Name }}-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_USERNAME
                key: {{ .Release.Name }}-mongodb-secret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_PASSWORD
                key: {{ .Release.Name }}-mongodb-secret
~~~~





- Simulando upgrade:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug




fernando@debian10x64:~$
fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS  CHART                   APP VERSION
minhaapi        default         1               2023-01-14 00:39:29.189971908 -0300 -03 failed  api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ date
Wed 18 Jan 2023 11:57:50 PM -03
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods -A
NAMESPACE       NAME                                                              READY   STATUS    RESTARTS        AGE
default         minhaapi-api-deployment-8686474859-6grcf                          1/1     Running   2 (4d2h ago)    4d23h
default         minhaapi-mongodb-deployment-7c664ccf4b-29fv5                      1/1     Running   2 (4d2h ago)    4d23h
kube-system     coredns-78fcd69978-5xcpp                                          1/1     Running   9 (4d2h ago)    17d
kube-system     etcd-minikube                                                     1/1     Running   22 (4d2h ago)   17d
kube-system     kube-apiserver-minikube                                           1/1     Running   21 (4d2h ago)   17d
kube-system     kube-controller-manager-minikube                                  1/1     Running   22 (4d2h ago)   17d
kube-system     kube-proxy-5pc9k                                                  1/1     Running   9               17d
kube-system     kube-scheduler-minikube                                           1/1     Running   18 (4d2h ago)   17d
kube-system     storage-provisioner                                               1/1     Running   19 (24m ago)    17d
nginx-ingress   meu-ingress-controller-ingress-nginx-controller-85685788f82hp89   1/1     Running   6 (4d2h ago)    12d
nginx-ingress   meu-ingress-controller-ingress-nginx-controller-85685788f8xpg5v   1/1     Running   6 (4d2h ago)    12d
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:150: [debug] performing update for minhaapi
upgrade.go:313: [debug] dry run for minhaapi
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Wed Jan 18 23:57:58 2023
NAMESPACE: default
STATUS: pending-upgrade
REVISION: 2
TEST SUITE: None
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: LoadBalancer
mongodb:
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  tag: 4.2.8

HOOKS:
MANIFEST:
---
# Source: api-produto/templates/mongodb-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: minhaapi-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: "bW9uZ291c2Vy"
  MONGO_INITDB_ROOT_PASSWORD: "bW9uZ29wd2Q="
---
# Source: api-produto/templates/api-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: minhaapi-api-configmap
data:
    Mongo__Host: minhaapi-mongo-service
    Mongo__DataBase: admin
---
# Source: api-produto/templates/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-api-service
spec:
  selector:
    app: minhaapi-api
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
---
# Source: api-produto/templates/mongodb-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-mongo-service
spec:
  selector:
    app: minhaapi-mongodb
  ports:
  - port: 27017
    targetPort: 27017
---
# Source: api-produto/templates/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-api-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-api
  template:
    metadata:
      labels:
        app: minhaapi-api
    spec:
      containers:
      - name: api
        image: fabricioveronez/pedelogo-catalogo:v1
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: minhaapi-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_USERNAME
                key: minhaapi-mongodb-secret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_PASSWORD
                key: minhaapi-mongodb-secret
---
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: minhaapi-mongodb-secret

NOTES:
Instalado
fernando@debian10x64:~$






- Até aqui, trouxe os valores esperados do ConfigMap e do Secret.

- Caso eu queira usar um Secret separado, vai ser necessário utilizar uma estrutura condicional.











# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Estrutura If/Else

[14:20]

- Inicialmente, os ajustes serão realizados no Deployment do MongoDB.

- Atualmente o manifesto está assim:

~~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-mongodb
  template:
    metadata:     
      labels:
        app: {{ .Release.Name }}-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:{{ .Values.mongodb.tag }}
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: {{ .Release.Name }}-mongodb-secret
~~~~


- Além disso, iremos fazer modificações no Values, atualmente ele está assim:

~~~~YAML
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: LoadBalancer

mongodb:
  tag: 4.2.8
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
~~~~





- Exemplos de Template If/Else

~~~~YAML
{{ if PIPELINE }}
  # Do something
{{ else if OTHER_PIPELINE }}
  # Do something else
{{ else }}
  # Default case
{{ end }}
~~~~


Example 2:

~~~~YAML
{{ if .Values.debug }}
  # Do something
{{ else }}
  # Do something else
{{ end }}
~~~~




- Criamos o valor "existSecret", vamos deixar ele comentado por enquanto.

- Explicando a estrutura if criada:
    - No "if", verificamos se o valor do Value "existSecret" é vazio, caso positivo, vamos pegar o valor da nossa Secret do MongoDB.
    - No "else", caso o valor "existSecret" não seja vazio, ou seja, exista um valor definido pra "existSecret", vamos pegar o valor dela.


        envFrom:
          {{ if empty .Values.mongodb.existSecret }}
          - secretRef:
              name: {{ .Release.Name }}-mongodb-secret
          {{ else }}
          - secretRef:
              name: {{ .Values.mongodb.existSecret }}
          {{ end }}


- Após ajustada a estrutura de if/else, nosso manifesto do Deployment do MongoDB ficou assim:

~~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-mongodb
  template:
    metadata:     
      labels:
        app: {{ .Release.Name }}-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:{{ .Values.mongodb.tag }}
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          {{ if empty .Values.mongodb.existSecret }}
          - secretRef:
              name: {{ .Release.Name }}-mongodb-secret
          {{ else }}
          - secretRef:
              name: {{ .Values.mongodb.existSecret }}
          {{ end }}
~~~~




- Simulando upgrade:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug





~~~~bash
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:

          - secretRef:
              name: minhaapi-mongodb-secret

NOTES:
Instalado
fernando@debian10x64:~$
~~~~




- Como o Value "existSecret" está vazio, ele pegou o Secret mesmo.

- Porém, abaixo do "envFrom" temos um espaço em branco.

- Faltava colocar um traço - após as duas chaves que abrem as condições:

ANTES:

        envFrom:
          {{ if empty .Values.mongodb.existSecret }}
          - secretRef:
              name: {{ .Release.Name }}-mongodb-secret
          {{ else }}
          - secretRef:
              name: {{ .Values.mongodb.existSecret }}
          {{ end }}

DEPOIS:

        envFrom:
          {{- if empty .Values.mongodb.existSecret }}
          - secretRef:
              name: {{ .Release.Name }}-mongodb-secret
          {{- else }}
          - secretRef:
              name: {{ .Values.mongodb.existSecret }}
          {{- end }}


- Maiores detalhes sobre:
<https://helm.sh/docs/chart_template_guide/control_structures/#controlling-whitespace>


- Simulando upgrade:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug

- Após aplicado AJUSTE, colocando o traço no começo da das chaves, o espaço em branco após o "envFrom" não surgiu novamente:

~~~~bash
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: minhaapi-mongodb-secret

NOTES:
Instalado
fernando@debian10x64:~$
~~~~




- Agora vamos simular com o valor do Value "existSecret" setado manualmente usando o parametro --set no comando de upgrade:
  --set mongodb.existSecret=umsecret

- Simulando upgrade:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug

- Resultado:

~~~~bash
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: umsecret

NOTES:
Instalado
fernando@debian10x64:~$
~~~~





- Gerou tudo certinho.
- Porém agora ficamos com 1 problema apenas.
- O nosso secret continua sendo gerado, mesmo quando dizemos que já existe um secret.
- Temos que fazer uma condição no manifesto do Secret, para que ele não seja gerado, quando temos 1 secret, conforme o valor do campo "existSecret" em Values.
- Vamos adicionar a condicional, se campo "existSecret" estiver vazio, cria o Secret conforme o manifesto:
{{- if empty .Values.mongodb.existSecret }}
{{- end }}

- ANTES:

~~~YAML
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName | b64enc | quote }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword | b64enc | quote }}
~~~

- DEPOIS:

~~~YAML
{{- if empty .Values.mongodb.existSecret }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-mongodb-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName | b64enc | quote }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword | b64enc | quote }}
{{- end }}
~~~


- Simulando upgrade:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug

- Agora não gerou o Secret do MongoDB, conforme o esperado, seguindo a estrutura de if else:

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:150: [debug] performing update for minhaapi
upgrade.go:313: [debug] dry run for minhaapi
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Thu Jan 19 23:24:42 2023
NAMESPACE: default
STATUS: pending-upgrade
REVISION: 2
TEST SUITE: None
USER-SUPPLIED VALUES:
mongodb:
  existSecret: umsecret

COMPUTED VALUES:
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: LoadBalancer
mongodb:
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  existSecret: umsecret
  tag: 4.2.8

HOOKS:
MANIFEST:
---
# Source: api-produto/templates/api-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: minhaapi-api-configmap
data:
    Mongo__Host: minhaapi-mongo-service
    Mongo__DataBase: admin
---
# Source: api-produto/templates/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-api-service
spec:
  selector:
    app: minhaapi-api
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
---
# Source: api-produto/templates/mongodb-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minhaapi-mongo-service
spec:
  selector:
    app: minhaapi-mongodb
  ports:
  - port: 27017
    targetPort: 27017
---
# Source: api-produto/templates/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-api-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-api
  template:
    metadata:
      labels:
        app: minhaapi-api
    spec:
      containers:
      - name: api
        image: fabricioveronez/pedelogo-catalogo:v1
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: minhaapi-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_USERNAME
                key: minhaapi-mongodb-secret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_PASSWORD
                key: minhaapi-mongodb-secret
---
# Source: api-produto/templates/mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-mongodb-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-mongodb
  template:
    metadata:
      labels:
        app: minhaapi-mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.2.8
        ports:
        - containerPort: 27017
        resources:
          requests:
            memory: "1Gi"
            cpu: "1500m"
          limits:
            memory: "1Gi"
            cpu: "1500m"
        envFrom:
          - secretRef:
              name: umsecret

NOTES:
Instalado
fernando@debian10x64:~$
~~~~






- Efetuando ajuste, para que o manifesto do Deployment da API tenha uma condição if else para o Secret também:

- ANTES:

~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-api-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-api
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-api
    spec:
      containers:
      - name: api
        image: {{ .Values.api.image }}
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: {{ .Release.Name }}-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_USERNAME
                key: {{ .Release.Name }}-mongodb-secret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                name: MONGO_INITDB_ROOT_PASSWORD
                key: {{ .Release.Name }}-mongodb-secret
~~~



- DEPOIS:

~~~YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-api-deployment
spec:
  selector:
    matchLabels:
      app: {{ .Release.Name }}-api
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-api
    spec:
      containers:
      - name: api
        image: {{ .Values.api.image }}
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: {{ .Release.Name }}-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_USERNAME
                {{- if empty .Values.mongodb.existSecret }}
                name: {{ .Release.Name }}-mongodb-secret
                {{- else }}
                name: {{ .Values.mongodb.existSecret }}
                {{- end }}
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_PASSWORD
                {{- if empty .Values.mongodb.existSecret }}
                name: {{ .Release.Name }}-mongodb-secret
                {{- else }}
                name: {{ .Values.mongodb.existSecret }}
                {{- end }}
~~~




- Simulando upgrade, com valor do --set especificado, setando um valor para o campo "existSecret" do Values:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug

- Resultado:

~~~~bash
# Source: api-produto/templates/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-api-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-api
  template:
    metadata:
      labels:
        app: minhaapi-api
    spec:
      containers:
      - name: api
        image: fabricioveronez/pedelogo-catalogo:v1
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: minhaapi-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_USERNAME
                name: umsecret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_PASSWORD
                name: umsecret
---
~~~~


- Simulando sem um valor do existSecret setado:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --dry-run --debug

~~~~bash
# Source: api-produto/templates/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minhaapi-api-deployment
spec:
  selector:
    matchLabels:
      app: minhaapi-api
  template:
    metadata:
      labels:
        app: minhaapi-api
    spec:
      containers:
      - name: api
        image: fabricioveronez/pedelogo-catalogo:v1
        ports:
        - containerPort: 80
        imagePullPolicy: Always
        resources:
          requests:
            memory: "32Mi"
            cpu: "500m"
          limits:
            memory: "64Mi"
            cpu: "500m"
        envFrom:
          - configMapRef:
              name: minhaapi-api-configmap
        env:
          - name: Mongo__User
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_USERNAME
                name: minhaapi-mongodb-secret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_PASSWORD
                name: minhaapi-mongodb-secret
---
~~~~



# pendente
continua em
21:14






# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Dia 21/01/2023

continua em
21:14

- Agora vamos testar o funcionamento dos recursos no cluster.


- ANTES:

~~~~bash
fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS  CHART                   APP VERSION
minhaapi        default         1               2023-01-14 00:39:29.189971908 -0300 -03 failed  api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get all
NAME                                               READY   STATUS    RESTARTS      AGE
pod/minhaapi-api-deployment-8686474859-6grcf       1/1     Running   4 (41h ago)   7d16h
pod/minhaapi-mongodb-deployment-7c664ccf4b-29fv5   1/1     Running   4 (41h ago)   7d16h

NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/kubernetes               ClusterIP      10.96.0.1        <none>        443/TCP        20d
service/minhaapi-api-service     LoadBalancer   10.104.23.138    <pending>     80:32138/TCP   7d16h
service/minhaapi-mongo-service   ClusterIP      10.105.126.136   <none>        27017/TCP      7d16h

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minhaapi-api-deployment       1/1     1            1           7d16h
deployment.apps/minhaapi-mongodb-deployment   1/1     1            1           7d16h

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/minhaapi-api-deployment-8686474859       1         1         1       7d16h
replicaset.apps/minhaapi-mongodb-deployment-7c664ccf4b   1         1         1       7d16h
fernando@debian10x64:~$
~~~~




- Aplicando upgrade sem o Dry-Run, para aplicar no Helm de verdade:
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 21 17:04:24 2023
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
Instalado
fernando@debian10x64:~$

fernando@debian10x64:~$ kubectl get all
NAME                                               READY   STATUS    RESTARTS   AGE
pod/minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running   0          16s
pod/minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running   0          16s

NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/kubernetes               ClusterIP      10.96.0.1        <none>        443/TCP        20d
service/minhaapi-api-service     LoadBalancer   10.104.23.138    <pending>     80:32138/TCP   7d16h
service/minhaapi-mongo-service   ClusterIP      10.105.126.136   <none>        27017/TCP      7d16h

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minhaapi-api-deployment       1/1     1            1           7d16h
deployment.apps/minhaapi-mongodb-deployment   1/1     1            1           7d16h

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/minhaapi-api-deployment-6d998c4f44       1         1         1       16s
replicaset.apps/minhaapi-api-deployment-8686474859       0         0         0       7d16h
replicaset.apps/minhaapi-mongodb-deployment-7c664ccf4b   0         0         0       7d16h
replicaset.apps/minhaapi-mongodb-deployment-85d944c57d   1         1         1       16s
fernando@debian10x64:~$
~~~~



- Expondo o service da API:

minikube service minhaapi-api-service

~~~~bash
fernando@debian10x64:~$ minikube service minhaapi-api-service
|-----------|----------------------|-------------|---------------------------|
| NAMESPACE |         NAME         | TARGET PORT |            URL            |
|-----------|----------------------|-------------|---------------------------|
| default   | minhaapi-api-service |          80 | http://192.168.49.2:32138 |
|-----------|----------------------|-------------|---------------------------|
* Opening service default/minhaapi-api-service in default browser...
~~~~



- Acessando a API do Swagger:

http://192.168.49.2:32138/swagger/index.html
<http://192.168.49.2:32138/swagger/index.html>



- Testando um GET no /produto:

~~~~bash
Responses
Curl

curl -X GET "http://192.168.49.2:32138/Produto" -H  "accept: text/plain"

Request URL

http://192.168.49.2:32138/Produto

Server response
Code	Details
200	
Response body
Download

[]

Response headers

 content-type: application/json; charset=utf-8  date: Sat21 Jan 2023 20:08:46 GMT  server: Kestrel  transfer-encoding: chunked 

Responses
Code	Description	Links
200	

Success
~~~~



- Tudo funcionando.

- Agora estamos na Revision 2 do nosso Chart no Helm:

~~~~bash
fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         2               2023-01-21 17:04:24.039505638 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
~~~~

