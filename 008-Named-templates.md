
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 8 - Named Templates"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 8 - Named Templates

- Material de apoio:
https://helm.sh/docs/chart_template_guide/named_templates/
<https://helm.sh/docs/chart_template_guide/named_templates/>


- Os "Named Templates" são Templates auxiliares.

- No caso do MongoDB Service, por exemplo, usamos o  {{ .Release.Name }}-mongo-service para definir o name do Service:

~~~~YAML
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-mongo-service
spec:
  selector:
    app: {{ .Release.Name }}-mongodb
  ports:
  - port: 27017
    targetPort: 27017
~~~~



- Usamos diversas vezes o  {{ .Release.Name }}-mongo-service em outros pontos, normalmente.

- Para facilitar a manutenção, vamos criar um arquivo de template.
- Necessário criar um arquivo nomeado:
    _helpers.tpl
- O nome precisa ter um underscore ao inicio do nome.



Named Templates são templates no Helm que possuem nomes específicos e podem ser reutilizados em diferentes arquivos de template. Eles permitem que partes comuns de um template sejam definidas em um único lugar e depois chamadas em vários outros lugares.

Por exemplo, se você tem uma seção de configuração que é comum entre vários charts diferentes, você pode definir essa seção como um Named Template e, em seguida, chamá-la em cada chart onde ela é necessária.

A sintaxe para definir um Named Template é a seguinte:

~~~~YAML
{{- define "nome_do_template" -}}
Conteúdo do template aqui
{{- end -}}
~~~~

A sintaxe para chamar um Named Template é a seguinte:

~~~~YAML
{{ template "nome_do_template" . }}
~~~~

Espero que isso ajude a entender como os Named Templates funcionam no Helm.





- Criado o arquivo tpl:

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates/_helpers.tpl

~~~~YAML
{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongo-service
{{- end -}}
~~~~



- Editando o arquivo api-configmap, para que ele deixe de usar o {{ .Release.Name }}-mongo-service no campo Mongo__Host:
colocar o seguinte:
    {{ template "mongodb.serviceName" . }}

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates/api-configmap.yaml

- ANTES:

~~~~YAML
apiVersion: v1
kind: ConfigMap
metadata:
    name: {{ .Release.Name }}-api-configmap
data:
    Mongo__Host: {{ .Release.Name }}-mongo-service
    Mongo__DataBase: {{ .Values.mongodb.databaseName }}
~~~~

- DEPOIS:

~~~~YAML
apiVersion: v1
kind: ConfigMap
metadata:
    name: {{ .Release.Name }}-api-configmap
data:
    Mongo__Host: {{ template "mongodb.serviceName" . }}
    Mongo__DataBase: {{ .Values.mongodb.databaseName }}
~~~~





- O ponto é pra passar o contexto atual.
- O ponto é pra passar o contexto atual.
- O ponto é pra passar o contexto atual.


- Ajustando para template o name do MongoDB Service no arquivo do próprio MongoDB Service:

/home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates/mongodb-service.yaml

- DE: 

~~~~YAML
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-mongo-service
spec:
  selector:
    app: {{ .Release.Name }}-mongodb
  ports:
  - port: 27017
    targetPort: 27017
~~~~

- PARA:

~~~~YAML
apiVersion: v1
kind: Service
metadata:
  name: {{ template "mongodb.serviceName" . }}
spec:
  selector:
    app: {{ .Release.Name }}-mongodb
  ports:
  - port: 27017
    targetPort: 27017
~~~~



- Simulando upgrade, com valor do --set especificado, setando um valor para o campo "existSecret" do Values:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug

[...]
~~~~bash
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
  type: ClusterIP
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

~~~~
[...]


- Trouxe os campos de name com "minhaapi-mongo-service", conforme o esperado.





- Efetuando tentativa de upgrade real:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Mon Jan 23 22:55:27 2023
NAMESPACE: default
STATUS: deployed
REVISION: 4
TEST SUITE: None
NOTES:
Instalado
fernando@debian10x64:~$


fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         4               2023-01-23 22:55:27.795283516 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS        AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running                      3 (6m51s ago)   2d5h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0               12s
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0               12s
minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running                      4 (6m51s ago)   2d5h
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS       AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running                      3 (7m1s ago)   2d5h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0              22s
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0              22s
minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running                      4 (7m1s ago)   2d5h
fernando@debian10x64:~$


Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  44s                default-scheduler  Successfully assigned default/minhaapi-api-deployment-b957589b-czhg9 to minikube
  Normal   Pulled     41s                kubelet            Successfully pulled image "fabricioveronez/pedelogo-catalogo:v1" in 1.469623006s
  Normal   Pulled     38s                kubelet            Successfully pulled image "fabricioveronez/pedelogo-catalogo:v1" in 1.484983015s
  Normal   Pulled     26s                kubelet            Successfully pulled image "fabricioveronez/pedelogo-catalogo:v1" in 1.523602319s
  Warning  Failed     13s (x4 over 41s)  kubelet            Error: secret "umsecret" not found
  Normal   Pulled     13s                kubelet            Successfully pulled image "fabricioveronez/pedelogo-catalogo:v1" in 1.52937228s
  Normal   Pulling    0s (x5 over 42s)   kubelet            Pulling image "fabricioveronez/pedelogo-catalogo:v1"
fernando@debian10x64:~$
~~~~













- Nova tentativa de upgrade, sem informar um secret inexistente no set:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Mon Jan 23 22:56:43 2023
NAMESPACE: default
STATUS: deployed
REVISION: 5
TEST SUITE: None
NOTES:
Instalado
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS        AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running                      3 (7m59s ago)   2d5h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0               80s
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0               80s
minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running                      4 (7m59s ago)   2d5h
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS       AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running                      3 (8m4s ago)   2d5h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0              85s
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0              85s
minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running                      4 (8m4s ago)   2d5h
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS        AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running                      3 (8m15s ago)   2d5h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0               96s
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0               96s
minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running                      4 (8m15s ago)   2d5h
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         5               2023-01-23 22:56:43.805941156 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$

fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         5               2023-01-23 22:56:43.805941156 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$ kubectl get deploy
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
minhaapi-api-deployment       1/1     1            1           9d
minhaapi-mongodb-deployment   1/1     1            1           9d
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm ls^C
fernando@debian10x64:~$ kubectl get pods
NAME                                           READY   STATUS                       RESTARTS        AGE
minhaapi-api-deployment-6d998c4f44-zbrbt       1/1     Running                      3 (8m56s ago)   2d5h
minhaapi-api-deployment-b957589b-czhg9         0/1     CreateContainerConfigError   0               2m17s
minhaapi-mongodb-deployment-768fc9bd8f-wfb5l   0/1     CreateContainerConfigError   0               2m17s
minhaapi-mongodb-deployment-85d944c57d-8flk4   1/1     Running                      4 (8m56s ago)   2d5h
fernando@debian10x64:~$
~~~~




- Aparentemente, não ocorreram alterações nos Pods mais antigos e não tentou criar novos, como o name é mesmo, teoricamente nada se alterou mesmo.
- Aparentemente, não ocorreram alterações nos Pods mais antigos e não tentou criar novos, como o name é mesmo, teoricamente nada se alterou mesmo.
- Aparentemente, não ocorreram alterações nos Pods mais antigos e não tentou criar novos, como o name é mesmo, teoricamente nada se alterou mesmo.
- Aparentemente, não ocorreram alterações nos Pods mais antigos e não tentou criar novos, como o name é mesmo, teoricamente nada se alterou mesmo.







- Adicionando comentários, usando um bloco de documentação:
    {{/* Generate basic labels */}}

- Exemplo:

~~~~YAML
{{/* Generate basic labels */}}
{{- define "mychart.labels" }}
  labels:
    generator: helm
    date: {{ now | htmlDate }}
{{- end }}
~~~~