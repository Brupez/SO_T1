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