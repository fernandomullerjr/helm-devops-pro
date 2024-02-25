
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 9 - Dependência de Charts"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 9 - Dependência de Charts

- No Helm é possível linkar o Chart com alguma dependencia.

- No nosso caso vamos usar um MongoDB de um repositório do Bitnami.
- Nas aulas anteriores, nós criamos os manifestos para o MongoDB, como o Deployment, Service, Secret, etc.

- Nova pasta para fazer os testes com dependencias:
    DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates


- Deletar os manifestos do Mongo que estão na pasta:
    DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates


# Chart - MongoDB - Bitnami
<https://github.com/bitnami/charts/tree/main/bitnami/mongodb/>

- Iremos usar o chart do MongoDB disponibilizado pela Bitnami:
https://github.com/bitnami/charts/tree/main/bitnami/mongodb/
<https://github.com/bitnami/charts/tree/main/bitnami/mongodb/>




1. O primeiro passo é ir no arquivo "Chart.yaml":
/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/Chart.yaml

2. Adicionar a definição de dependencia.

- Exemplo:

~~~~YAML
#For example, this Chart.yaml declares two dependencies:
# Chart.yaml
dependencies:
- name: nginx
  version: "1.2.3"
  repository: "https://example.com/charts"
- name: memcached
  version: "3.2.1"
  repository: "https://another.example.com/charts"
~~~~


- Ajustado, dependencia do MongoDB:

a versão que iremos setar, podemos pegar no arquivo do chart no repositório:
https://github.com/bitnami/charts/blob/main/bitnami/mongodb/Chart.yaml
no caso era 13.6.4
e o endereço do repositório do chart, pegamos no README do repo do Github:
https://charts.bitnami.com/bitnami

~~~~YAML
dependencies:
- name: mongodb
  version: "13.6.4"
  repository: "https://charts.bitnami.com/bitnami"
~~~~



- Para setar os valores, necessário ajustar o arquivo values.yaml para os valores desejados, seguindo a estrutura mostrada no manual do repositório no GitHub:
https://github.com/bitnami/charts/tree/main/bitnami/mongodb/
<https://github.com/bitnami/charts/tree/main/bitnami/mongodb/>

vamos pegar e definir os valores de senha, usuario, banco de dados, seguindo a estrutura do manual, removendo o credentials e usando o auth, na identação necessária
auth.rootPassword 	MongoDB(®) root password 	""
auth.usernames 	List of custom users to be created during the initialization 	[]
auth.passwords 	List of passwords for the custom users set at auth.usernames 	[]

Quanto a persistencia, vamos deixar em false por enquanto, pois o default dela é true
Persistence parameters
Name 	Description 	Value
persistence.enabled 	Enable MongoDB(®) data persistence using PVC 	true


DE:

~~~~YAML
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  tag: 4.2.8
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  #existSecret: nome do secret
~~~~


PARA:

~~~~YAML
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  auth:
    usernames: mongouser
    passwords: mongopwd
    rootPassword: mongoRoot
    databases: admin
  persistence:
    enabled: false
~~~~



- Ajustado o values.



- Necessário ajustar agora os Templates.


- Como não teremos mais o Secret do MongoDB, devemos remover o trecho de variáveis no manifesto do API-Deployment:

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


- O nome do MongoDB Service é diferente neste chart, devemos ajustar o arquivo  _helpers.tpl , colocando o valor correto para o template:

DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates/_helpers.tpl

DE:

~~~~YAML
{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongo-service
{{- end -}}
~~~~

PARA:

~~~~YAML
{{/* Nome do Service do MongoDB */}}
{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongodb
{{- end -}}
~~~~



- ATENÇÃO:
Cuidar no final, para este chart o nome do Mongo é mongodb, ao invés de só mongo.

- Com o template ajustado, em caso de mudança do nome do Mongo, não precisamos editar em vários lugares.



# Secret

- Agora vamos criar uma Secret para a API.
- Vamos colocar nela os valores que estavam no env do API Deployment.

DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates/api-secret.yaml

~~~~YAML
apiVersion: v1
kind: Secret
metadata:
    name: {{ .Release.Name }}-api-secret
data:
    Mongo__User: {{ .Values.mongodb.auth.usernames }}
    Mongo__Password: {{ .Values.mongodb.auth.passwords }}
~~~~


- Ajustado o value do campo "Mongo__DataBase" no manifesto do ConfigMap, visto que o values.yaml foi alterada a estrutura, para ficar de acordo com o Chart do Bitnami:

DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates/api-configmap.yaml

~~~~YAML
apiVersion: v1
kind: ConfigMap
metadata:
    name: {{ .Release.Name }}-api-configmap
data:
    Mongo__Host: {{ template "mongodb.serviceName" . }}
    Mongo__DataBase: {{ .Values.mongodb.auth.databases }}
~~~~




- Adicionar no manifesto do Deployment da API a referencia ao Secret:

          - secretRef:
              name: {{ .Release.Name }}-api-secret

- Ficando assim após o ajuste:

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
          - secretRef:
              name: {{ .Release.Name }}-api-secret
~~~~




- Agora vamos executar um comando que vai pegar as dependencias e baixar para junto do meu Chart:

helm dependency build <caminho-do-chart>
helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/

- Porém nada ocorreu:

~~~~bash
fernando@debian10x64:~$ helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/
fernando@debian10x64:~$
fernando@debian10x64:~$
~~~~

- Estava faltando o trecho de código sobre a dependencia, no arquivo Chart.yaml:

DevOps-Pro-Helm/009-Material-chart-novo/api-produto/Chart.yaml

~~~~YAML
dependencies:
- name: mongodb
  version: "13.6.4"
  repository: "https://charts.bitnami.com/bitnami"
~~~~

- Executando o build de dependencias novamente:

helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/

~~~~bash
fernando@debian10x64:~$ helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/
Getting updates for unmanaged Helm repositories...
...Successfully got an update from the "https://charts.bitnami.com/bitnami" chart repository
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Downloading mongodb from repo https://charts.bitnami.com/bitnami
Deleting outdated charts
fernando@debian10x64:~$
~~~~


- Ele gera um arquivo tgz na pasta "charts":
  /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/charts/mongodb-13.6.4.tgz



- Efetuando um Upgrade com dry-run para ver os resultados:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug


erro


fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:524: [debug] copying values from minhaapi (v5) to new release.
Error: UPGRADE FAILED: template: api-produto/charts/mongodb/templates/standalone/dep-sts.yaml:189:32: executing "api-produto/charts/mongodb/templates/standalone/dep-sts.yaml" at <include "mongodb.customUsers" .>: error calling include: template: api-produto/charts/mongodb/templates/_helpers.tpl:128:21: executing "mongodb.customUsers" at <.Values.auth.usernames>: range can't iterate over mongouser
helm.go:84: [debug] template: api-produto/charts/mongodb/templates/standalone/dep-sts.yaml:189:32: executing "api-produto/charts/mongodb/templates/standalone/dep-sts.yaml" at <include "mongodb.customUsers" .>: error calling include: template: api-produto/charts/mongodb/templates/_helpers.tpl:128:21: executing "mongodb.customUsers" at <.Values.auth.usernames>: range can't iterate over mongouser
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
fernando@debian10x64:~$






api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  auth:
    usernames: mongouser
    passwords: mongopwd
    rootPassword: mongoRoot
    databases: admin
  persistence:
    enabled: false




api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  auth:
    usernames: [mongouser]
    passwords: [mongopwd]
    rootPassword: mongoRoot
    databases: [admin]
  persistence:
    enabled: false






- Efetuando um Upgrade com dry-run para ver os resultados:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug


erro 2


fernando@debian10x64:~$ ^C
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:524: [debug] copying values from minhaapi (v5) to new release.
Error: UPGRADE FAILED: error validating "": error validating data: [ValidationError(Secret.data.Mongo__Password): invalid type for io.k8s.api.core.v1.Secret.data: got "array", expected "string", ValidationError(Secret.data.Mongo__User): invalid type for io.k8s.api.core.v1.Secret.data: got "array", expected "string"]
helm.go:84: [debug] error validating "": error validating data: [ValidationError(Secret.data.Mongo__Password): invalid type for io.k8s.api.core.v1.Secret.data: got "array", expected "string", ValidationError(Secret.data.Mongo__User): invalid type for io.k8s.api.core.v1.Secret.data: got "array", expected "string"]
helm.sh/helm/v3/pkg/kube.scrubValidationError
        helm.sh/helm/v3/pkg/kube/client.go:643






- NECESSÁRIO AJUSTAR O SECRET DO API, botar o pipe, base64, etc
pegar exemplo:
  MONGO_INITDB_ROOT_USERNAME: {{ .Values.mongodb.credentials.userName | b64enc | quote }}
  MONGO_INITDB_ROOT_PASSWORD: {{ .Values.mongodb.credentials.userPassword | b64enc | quote }}




DE:

apiVersion: v1
kind: Secret
metadata:
    name: {{ .Release.Name }}-api-secret
data:
    Mongo__User: {{ .Values.mongodb.auth.usernames }}
    Mongo__Password: {{ .Values.mongodb.auth.passwords }}

PARA:

apiVersion: v1
kind: Secret
metadata:
    name: {{ .Release.Name }}-api-secret
data:
    Mongo__User: {{ .Values.mongodb.auth.usernames | b64enc | quote }}
    Mongo__Password: {{ .Values.mongodb.auth.passwords | b64enc | quote }}




- Testando denovo

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug



erro 3


fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:524: [debug] copying values from minhaapi (v5) to new release.
Error: UPGRADE FAILED: template: api-produto/templates/api-secret.yaml:6:53: executing "api-produto/templates/api-secret.yaml" at <b64enc>: wrong type for value; expected string; got []interface {}
helm.go:84: [debug] template: api-produto/templates/api-secret.yaml:6:53: executing "api-produto/templates/api-secret.yaml" at <b64enc>: wrong type for value; expected string; got []interface {}
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
fernando@debian10x64:~$



# PENDENTE

- Video continua em 15:39
- Tratar erros relacionados aos valores do Values.yaml. Documentação do Chart do Bitnami pede que eles sejam array. Porém colocando eles como array, impacta no campo do Mongo__User. 
- Necessário analisar.
- Ver também para documentar os comandos, adicionar estes abaixo:
SEE ALSO
    helm - The Helm package manager for Kubernetes.
    helm dependency build - rebuild the charts/ directory based on the Chart.lock file
    helm dependency list - list the dependencies for the given chart
    helm dependency update - update charts/ based on the contents of Chart.yaml
- Documentar melhor o "quote" e o "base64".








DE:

api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  auth:
    usernames: [mongouser]
    passwords: [mongopwd]
    rootPassword: mongoRoot
    databases: [admin]
  persistence:
    enabled: false



PARA:

api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  auth:
    usernames: mongouser
    passwords: mongopwd
    rootPassword: mongoRoot
    databases: admin
  persistence:
    enabled: false



- Testando denovo

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug


fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:524: [debug] copying values from minhaapi (v5) to new release.
Error: UPGRADE FAILED: template: api-produto/charts/mongodb/templates/standalone/dep-sts.yaml:189:32: executing "api-produto/charts/mongodb/templates/standalone/dep-sts.yaml" at <include "mongodb.customUsers" .>: error calling include: template: api-produto/charts/mongodb/templates/_helpers.tpl:128:21: executing "mongodb.customUsers" at <.Values.auth.usernames>: range can't iterate over mongouser
helm.go:84: [debug] template: api-produto/charts/mongodb/templates/standalone/dep-sts.yaml:189:32: executing "api-produto/charts/mongodb/templates/standalone/dep-sts.yaml" at <include "mongodb.customUsers" .>: error calling include: template: api-produto/charts/mongodb/templates/_helpers.tpl:128:21: executing "mongodb.customUsers" at <.Values.auth.usernames>: range can't iterate over mongouser
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
fernando@debian10x64:~$












- Removidos os valores que eram array.
- Usando os depreciados mesmo.
<https://github.com/bitnami/charts/tree/main/bitnami/mongodb/>
auth.username 	DEPRECATED: use auth.usernames instead 	""
auth.password 	DEPRECATED: use auth.passwords instead 	""
auth.database 	DEPRECATED: use auth.databases instead 	""

- Ajustando o value do "databases" para "database" no singular, no manifesto do ConfigMap:

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates/api-configmap.yaml

~~~~YAML
apiVersion: v1
kind: ConfigMap
metadata:
    name: {{ .Release.Name }}-api-configmap
data:
    Mongo__Host: {{ template "mongodb.serviceName" . }}
    Mongo__DataBase: {{ .Values.mongodb.auth.database }}
~~~~

- No manifesto do Secret, passado para o singular o username e o password:

~~~~YAML
apiVersion: v1
kind: Secret
metadata:
    name: {{ .Release.Name }}-api-secret
data:
    Mongo__User: {{ .Values.mongodb.auth.username | b64enc | quote }}
    Mongo__Password: {{ .Values.mongodb.auth.password | b64enc | quote }}
~~~~


- Novo arquivo values:

~~~~YAML
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br
  - api.aulakubedev.com.br

mongodb:
  auth:
    username: mongouser
    password: mongopwd
    rootPassword: mongoRoot
    database: admin
  persistence:
    enabled: false
~~~~




- Testando denovo

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto --dry-run --debug

dry-run completo:
/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-dry-run-completo.yaml
o chart da Bitnami cria Service Account também, e muito mais.

- Agora funcionou!
- Foi necessário deixar os campos do values no singular, sem ser array, pois o outro apresentava problema.





- ANTES:

~~~~bash
fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         5               2023-01-23 22:56:43.805941156 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS     AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       0/1     CreateContainerConfigError   3 (3d ago)   5d6h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0            3d
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0            3d
minhaapi-mongodb-deployment-85d944c57d-8flk4   0/1     CreateContainerConfigError   4 (3d ago)   5d6h
fernando@debian10x64:~$
~~~~



- Agora fazer um teste real:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto

deu erro


fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto
Error: UPGRADE FAILED: no Service with the name "minhaapi-mongodb" found
fernando@debian10x64:~$






# PENDENTE
- Tratar erro sobre o name do Service.

06:22
fala sobre o service desse projeto



DE:

~~~~YAML
dependencies:
- name: mongodb
  version: "13.6.4"
  repository: "https://charts.bitnami.com/bitnami"
~~~~

PARA:

~~~~YAML
dependencies:
- name: mongodb
  version: "9.2.5"
  repository: "https://charts.bitnami.com/bitnami"
~~~~


- Efetuando novo teste, após trocar a versão do MongoDB, deixando igual do video do Veronez:

helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/

~~~~bash
fernando@debian10x64:~$ helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/
Error: no repository definition for https://charts.bitnami.com/bitnami. Please add the missing repos via 'helm repo add'
fernando@debian10x64:~$ ^C
~~~~


- Adicionando o repo do Bitnami na listagem do Helm:

~~~~bash
https://github.com/bitnami/charts/tree/main/bitnami/mongodb/
<https://github.com/bitnami/charts/tree/main/bitnami/mongodb/>
$ helm repo add my-repo https://charts.bitnami.com/bitnami
$ helm install my-release my-repo/mongodb
~~~~

~~~~bash
fernando@debian10x64:~$ helm repo add my-repo https://charts.bitnami.com/bitnami
"my-repo" has been added to your repositories
fernando@debian10x64:~$
fernando@debian10x64:~$
~~~~


- Testando o build das dependencias novamente:

~~~~bash
fernando@debian10x64:~$ helm dependency build /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "my-repo" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Downloading mongodb from repo https://charts.bitnami.com/bitnami
Deleting outdated charts
fernando@debian10x64:~$
~~~~




- Agora fazer um teste real:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto
Error: UPGRADE FAILED: cannot patch "minhaapi-mongodb" with kind Service: Service "minhaapi-mongodb" is invalid: metadata.resourceVersion: Invalid value: "": must be specified for an update
fernando@debian10x64:~$
~~~~

Falha ao tentar fazer um patch num Service com nome "minhaapi-mongodb"






- Deletado o arquivo "mongodb-service.yaml" da pasta "DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates"
mongodb-service.yaml
DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates
efetuado backup dele na pasta:
/home/fernando/cursos/helm-cursos/outros/bkp-teste/mongodb-service.yaml


- Agora fazer um teste real:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto


- Funcionou:

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 28 17:14:06 2023
NAMESPACE: default
STATUS: deployed
REVISION: 8
TEST SUITE: None
NOTES:
Instalado
fernando@debian10x64:~$

fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         8               2023-01-28 17:14:06.002515107 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
NAME                                       READY   STATUS    RESTARTS   AGE
minhaapi-api-deployment-6586d4f7bc-6vcsx   1/1     Running   0          5m6s
minhaapi-mongodb-6c98c75fcc-lnq5l          1/1     Running   0          5m7s
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get all
NAME                                           READY   STATUS    RESTARTS   AGE
pod/minhaapi-api-deployment-6586d4f7bc-6vcsx   1/1     Running   0          5m11s
pod/minhaapi-mongodb-6c98c75fcc-lnq5l          1/1     Running   0          5m12s

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP     27d
service/minhaapi-api-service   ClusterIP   10.104.23.138    <none>        80/TCP      14d
service/minhaapi-mongodb       ClusterIP   10.100.148.239   <none>        27017/TCP   41h

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minhaapi-api-deployment   1/1     1            1           14d
deployment.apps/minhaapi-mongodb          1/1     1            1           5m12s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/minhaapi-api-deployment-6586d4f7bc   1         1         1       5m12s
replicaset.apps/minhaapi-api-deployment-6d998c4f44   0         0         0       7d
replicaset.apps/minhaapi-api-deployment-8686474859   0         0         0       14d
replicaset.apps/minhaapi-api-deployment-b957589b     0         0         0       4d18h
replicaset.apps/minhaapi-mongodb-6c98c75fcc          1         1         1       5m12s
fernando@debian10x64:~$
~~~~






minikube service minhaapi-api-service

fernando@debian10x64:~$ minikube service minhaapi-api-service
|-----------|----------------------|-------------|--------------|
| NAMESPACE |         NAME         | TARGET PORT |     URL      |
|-----------|----------------------|-------------|--------------|
| default   | minhaapi-api-service |             | No node port |
|-----------|----------------------|-------------|--------------|
* service default/minhaapi-api-service has no node port
fernando@debian10x64:~$



NodePort

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto


fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 28 17:30:06 2023
NAMESPACE: default
STATUS: deployed
REVISION: 9
TEST SUITE: None
NOTES:
Instalado
fernando@debian10x64:~$



fernando@debian10x64:~$ kubectl get all
NAME                                           READY   STATUS    RESTARTS   AGE
pod/minhaapi-api-deployment-6586d4f7bc-6vcsx   1/1     Running   0          20m
pod/minhaapi-mongodb-6c98c75fcc-lnq5l          1/1     Running   0          20m

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP        27d
service/minhaapi-api-service   NodePort    10.104.23.138    <none>        80:32182/TCP   14d
service/minhaapi-mongodb       ClusterIP   10.100.148.239   <none>        27017/TCP      42h

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minhaapi-api-deployment   1/1     1            1           14d
deployment.apps/minhaapi-mongodb          1/1     1            1           20m

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/minhaapi-api-deployment-6586d4f7bc   1         1         1       20m
replicaset.apps/minhaapi-api-deployment-6d998c4f44   0         0         0       7d
replicaset.apps/minhaapi-api-deployment-8686474859   0         0         0       14d
replicaset.apps/minhaapi-api-deployment-b957589b     0         0         0       4d18h
replicaset.apps/minhaapi-mongodb-6c98c75fcc          1         1         1       20m
fernando@debian10x64:~$





fernando@debian10x64:~$
fernando@debian10x64:~$ minikube service minhaapi-api-service
|-----------|----------------------|-------------|---------------------------|
| NAMESPACE |         NAME         | TARGET PORT |            URL            |
|-----------|----------------------|-------------|---------------------------|
| default   | minhaapi-api-service |          80 | http://192.168.49.2:32182 |
|-----------|----------------------|-------------|---------------------------|
* Opening service default/minhaapi-api-service in default browser...
fernando@debian10x64:~$




- Acessível via:
http://192.168.49.2:32182/swagger

- Testes OK
200