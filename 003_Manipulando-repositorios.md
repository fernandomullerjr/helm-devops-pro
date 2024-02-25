
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# push

git status
git add .
git commit -m "Curso Formação DevOps PRO - Helm - Aula 3 - Manipulando repositórios"
eval $(ssh-agent -s)
ssh-add /home/fernando/.ssh/chave-debian10-github
git push
git status





# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# ##############################################################################################################################################################
# Aula 3 - Manipulando repositórios


https://charts.helm.sh/stable/
<https://charts.helm.sh/stable/>


- Adicionar o repositório stable do Helm:
helm repo add stable https://charts.helm.sh/stable


- Para atualizar a lista deste repositório:
helm repo update

- Para listar os repositórios:
helm repo list



fernando@debian10x64:~/cursos$ helm repo add stable https://charts.helm.sh/stable
"stable" has been added to your repositories
fernando@debian10x64:~/cursos$
fernando@debian10x64:~/cursos$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
fernando@debian10x64:~/cursos$
fernando@debian10x64:~/cursos$
fernando@debian10x64:~/cursos$ helm repo list
NAME    URL
stable  https://charts.helm.sh/stable
fernando@debian10x64:~/cursos$
fernando@debian10x64:~/cursos$



- Comando para remover um repo:
helm repo remove <nome-do-repo>



