# `spacecheck.sh`
## Condições de erro
  - Diretório não existente
  - Não ser um diretório
  - Não ter permissões de erro

## Grupos de permissões
|  u  |  g  |  o  |
|:---:|:---:|:---:|
| rwx | rwx | rwx |

Caso o ficheiro seja meu, usar o grupo G.

## Relatório
  - Explicar em termos gerais a abordagem (não é explicar o código)
  - Explicar como validamos os *scripts* (i.e., usar testes)

# `spacerate.sh`
## Restrições
Perceber se os conjuntos são iguais:
- Apenas comparar quando o *regex* é o mesmo (p.e., uso da *flag* `-n`)
- Ordenar as coisas da mesma forma (dar *parse* das *flags*, nomeadamente `-r` e `-a`)

## Order by Name
du -d 1: This command lists the sizes of directories (-d 1 limits the depth to 1, so it lists only the top-level directories).
sort -k2: This command sorts the output of du based on the second field, which is the directory name. By default, sort uses whitespace as the field delimiter, so it will sort by the directory names.

## Output Limit
head -n <limit number of outputs> - it displays only the limit inserted as an argument of the output of the 'du' command in this case.
