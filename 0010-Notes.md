
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 10 - Notes"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 10 - Notes

- Adicionado o texto a baixo no lugar da palavra "instalado" no arquivo "NOTES.txt":
    /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto/templates/NOTES.txt

A release  {{ .Release.Name }} foi criada com sucesso.


- Efetuando teste para ver a mensagem do Notes:

helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto

~~~~bash
fernando@debian10x64:~$ helm upgrade minhaapi /home/fernando/cursos/helm-cursos/DevOps-Pro-Helm/009-Material-chart-novo/api-produto
Release "minhaapi" has been upgraded. Happy Helming!
NAME: minhaapi
LAST DEPLOYED: Sat Jan 28 17:45:28 2023
NAMESPACE: default
STATUS: deployed
REVISION: 10
TEST SUITE: None
NOTES:
A release  minhaapi foi criada com sucesso.
fernando@debian10x64:~$
~~~~