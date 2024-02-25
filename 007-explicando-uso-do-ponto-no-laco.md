
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