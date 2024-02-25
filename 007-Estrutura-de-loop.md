
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 7 - Estrutura de loop"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 7 - Estrutura de loop

- Agora iremos adicionar uma regra para ingress.
- Este ingress terá um laço de repetição que vai criar rules no ingress para diversos domínios, setando o campo "host" no manifesto dinamicamente.

- Criar um manifesto de ingress na pasta "templates":
DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates

- Criado arquivo:
DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto/templates/api-ingress.yaml

~~~~YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
~~~~




- Name:
{{ .Release.Name }}-api-ingress



Continua em 03:20

- Após ajustado o api-ingress:

~~~~YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  {{- range .Values.api.ingress }}
  - host: {{ . }}
    http:
      paths:
      - backend:
          service:
            name: {{ $.Release.Name }}-api-service
            port:
              number: 80
  {{- end }}
~~~~

- Trazer o valor desse contexto, que neste caso vai ser o nome da API:
    {{ . }}


- Sem passar o dólar $, o valor dentro das chaves será procurado no escopo da estrutura de repetição loop apenas.
- Para conseguir obter valores de fora da estrutura do Loop, é necessário usar o dólar $.
exemplo, na formação do name neste caso:
    name: {{ $.Release.Name }}-api-service


- Editar o arquivo values.yaml, adicionando o campo do ingress e editando o serviceType de "LoadBalancer" para "ClusterIP":

- ANTES:

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
  #existSecret: nome do secret
~~~~

- DEPOIS:

~~~~YAML
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br

mongodb:
  tag: 4.2.8
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  #existSecret: nome do secret
~~~~






- Simulando upgrade, com valor do --set especificado, setando um valor para o campo "existSecret" do Values:
helm upgrade minhaapi <caminho-do-chart> --dry-run --debug
helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug


- ERRO:

~~~~BASH
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
Error: UPGRADE FAILED: error validating "": error validating data: ValidationError(Ingress.spec.rules[0].http.paths[0]): missing required field "pathType" in io.k8s.api.networking.v1.HTTPIngressPath
helm.go:84: [debug] error validating "": error validating data: ValidationError(Ingress.spec.rules[0].http.paths[0]): missing required field "pathType" in io.k8s.api.networking.v1.HTTPIngressPath
helm.sh/helm/v3/pkg/kube.scrubValidationError
        helm.sh/helm/v3/pkg/kube/client.go:643
helm.sh/helm/v3/pkg/kube.(*Client).Build
        helm.sh/helm/v3/pkg/kube/client.go:215
~~~~





- Editado novamente:

~~~~YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  {{- range .Values.api.ingress }}
  - host: {{ . }}
    http:
      paths:
      pathType: Prefix
      - backend:
          service:
            name: {{ $.Release.Name }}-api-service
            port:
              number: 80
  {{- end }}
~~~~





- NOVO ERRO:

~~~~bash
fernando@debian10x64:~$
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
Error: UPGRADE FAILED: YAML parse error on api-produto/templates/api-ingress.yaml: error converting YAML to JSON: yaml: line 13: did not find expected key
helm.go:84: [debug] error converting YAML to JSON: yaml: line 13: did not find expected key
YAML parse error on api-produto/templates/api-ingress.yaml
helm.sh/helm/v3/pkg/releaseutil.(*manifestFile).sort
        helm.sh/helm/v3/pkg/releaseutil/manifest_sorter.go:146
helm.sh/helm/v3/pkg/releaseutil.SortManifests
        helm.sh/helm/v3/pkg/releaseutil/manifest_sorter.go:106
helm.sh/helm/v3/pkg/action.(*Configuration).renderResources
~~~~



- Adicionando o campo path
    - path: /

~~~~YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  {{- range .Values.api.ingress }}
  - host: {{ . }}
    http:
      paths:
      - path: /
        pathType: Prefix
        - backend:
            service:
              name: {{ $.Release.Name }}-api-service
              port:
                number: 80
  {{- end }}
~~~~




- NOVO ERRO 2:

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
Error: UPGRADE FAILED: YAML parse error on api-produto/templates/api-ingress.yaml: error converting YAML to JSON: yaml: line 14: did not find expected key
helm.go:84: [debug] error converting YAML to JSON: yaml: line 14: did not find expected key
YAML parse error on api-produto/templates/api-ingress.yaml
helm.sh/helm/v3/pkg/releaseutil.(*manifestFile).sort
        helm.sh/helm/v3/pkg/releaseutil/manifest_sorter.go:146
helm.sh/helm/v3/pkg/releaseutil.SortManifests
~~~~









- Ajustado o campo backend, removido o traço e 1 espaço:

DE:
        - backend:
PARA:
        backend:

~~~~YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  {{- range .Values.api.ingress }}
  - host: {{ . }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
            service:
              name: {{ $.Release.Name }}-api-service
              port:
                number: 80
  {{- end }}
~~~~






- Resolvido.
- Não ocorreu erro ao tentar simular o upgrade via Helm:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug
upgrade.go:142: [debug] preparing upgrade for minhaapi
upgrade.go:150: [debug] performing update for minhaapi
upgrade.go:313: [debug] dry run for minhaapi
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 21 21:45:22 2023
NAMESPACE: default
STATUS: pending-upgrade
REVISION: 3
TEST SUITE: None
USER-SUPPLIED VALUES:
mongodb:
  existSecret: umsecret

COMPUTED VALUES:
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  ingress:
  - aulakubedev.com.br
  serviceType: ClusterIP
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
                key: MONGO_INITDB_ROOT_USERNAME
                name: umsecret
          - name: Mongo__Password
            valueFrom:
              secretKeyRef:
                key: MONGO_INITDB_ROOT_PASSWORD
                name: umsecret
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
---
# Source: api-produto/templates/api-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minhaapi-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - host: aulakubedev.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
            service:
              name: minhaapi-api-service
              port:
                number: 80

NOTES:
Instalado
fernando@debian10x64:~$
~~~~








# ##############################################################################################################################################################
# Explicando melhor o laço do manifesto do Ingress

o que esse manifesto do Kubernetes faz exatamente e como o Helm trabalha com este laço de repetição?

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  {{- range .Values.api.ingress }}
  - host: {{ . }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
            service:
              name: {{ $.Release.Name }}-api-service
              port:
                number: 80
  {{- end }}

Este manifesto do Kubernetes é um exemplo de configuração de Ingress, que é usado para gerenciar o acesso às aplicações em um cluster Kubernetes. Ele especifica uma regra de Ingress para cada valor de entrada na lista "api.ingress" no arquivo de valores do Helm. A regra especifica que o host deve ser o valor da lista e que o caminho deve ser "/" com um prefixo. O backend da regra é definido como um serviço chamado "{{ $.Release.Name }}-api-service" na porta 80.

O Helm trabalha com este laço de repetição, pois ele é uma ferramenta de gerenciamento de pacotes para Kubernetes. Ele permite que os usuários criem, gerenciem e atualizem facilmente aplicações em um cluster Kubernetes. Com o Helm, os usuários podem usar esse manifesto como um modelo para criar e gerenciar múltiplas regras de Ingress para aplicações diferentes, sem precisar escrever manualmente cada configuração. Ele também permite que os usuários atualizem facilmente as configurações de Ingress, sem precisar editar manualmente cada manifesto.
fernandomj90@gmail.com
preciso entender melhor como o campo host é especificado pela regra.

# ##############################################################################################################################################################
# Explicando melhor o uso do {{ . }}

O campo host é especificado na regra de Ingress através da sintaxe "{{ . }}". Isso é um recurso do Helm que permite que os valores sejam passados para o manifesto através de um arquivo de valores. No exemplo dado, a lista "api.ingress" é definida no arquivo de valores do Helm e cada valor da lista é passado para o manifesto como o host da regra de Ingress.

Por exemplo, se a lista "api.ingress" no arquivo de valores do Helm tiver os valores "example1.com" e "example2.com", o manifesto criará duas regras de Ingress. A primeira regra terá o host "example1.com" e a segunda regra terá o host "example2.com". Isso permite que várias regras de Ingress sejam criadas automaticamente a partir de uma única configuração, sem precisar escrever manualmente cada regra.

Esse é uma forma de parametrizar o manifesto, onde é possível configurar alguns valores antes de subir o manifesto. Isso é importante para não colocar informações sensíveis diretamente no manifesto.



# ##############################################################################################################################################################
# {{ . }}

<https://helm.sh/docs/chart_template_guide/control_structures/>

Sometimes it's useful to be able to quickly make a list inside of your template, and then iterate over that list. Helm templates have a function to make this easy: tuple. In computer science, a tuple is a list-like collection of fixed size, but with arbitrary data types. This roughly conveys the way a tuple is used.

  sizes: |-
    {{- range tuple "small" "medium" "large" }}
    - {{ . }}
    {{- end }}    

The above will produce this:

  sizes: |-
    - small
    - medium
    - large    

In addition to lists and tuples, range can be used to iterate over collections that have a key and a value (like a map or dict). We'll see how to do that in the next section when we introduce template variables.






# continua
Continua em 06:05




- Efetuando upgrade.

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto

~~~~bash
fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         2               2023-01-21 17:04:24.039505638 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 21 22:23:52 2023
NAMESPACE: default
STATUS: deployed
REVISION: 3
TEST SUITE: None
NOTES:
Instalado
fernando@debian10x64:~$


fernando@debian10x64:~$ kubectl get ingress
NAME                   CLASS           HOSTS                ADDRESS   PORTS   AGE
minhaapi-api-ingress   nginx-example   aulakubedev.com.br             80      13s
fernando@debian10x64:~$
~~~~





- No exemplo acima, o ingress criou o ingress com um Host apenas.


- Agora vamos fazer com que o ingress tenha 2 hosts, no caso, responsa a 2 endereços diferentes.
- Ajustar o campo ingress, no arquivo values.yaml

DE:

~~~~YAML
api:
  image: fabricioveronez/pedelogo-catalogo:v1
  serviceType: ClusterIP
  ingress:
  - aulakubedev.com.br

mongodb:
  tag: 4.2.8
  credentials:
    userName: mongouser
    userPassword: mongopwd
  databaseName: admin
  #existSecret: nome do secret
~~~~


- PARA:

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







- Simulando:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/005-Material-aula__primeiro-helm-chart/api-produto --set mongodb.existSecret=umsecret --dry-run --debug

~~~~bash
# Source: api-produto/templates/api-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minhaapi-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - host: aulakubedev.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
            service:
              name: minhaapi-api-service
              port:
                number: 80
  - host: api.aulakubedev.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
            service:
              name: minhaapi-api-service
              port:
                number: 80

NOTES:
Instalado
fernando@debian10x64:~$




Verificando o helm

fernando@debian10x64:~$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
minhaapi        default         3               2023-01-21 22:23:52.246703234 -0300 -03 deployed        api-produto-0.1.0       1.16.0
fernando@debian10x64:~$

~~~~






