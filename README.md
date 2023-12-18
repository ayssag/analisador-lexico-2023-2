# Compilador para linguagem Tiny
Projeto desenvolvido durante a disciplina de Compiladores 2023/2 da Universidade de Brasília.

## Descrição
Compilador implementado na linguagem C para a linguagem Tiny. Baseia-se na implementação apresentada no livro _Compiler Construction - Principle and Practices, Kenneth C. Louden_. 

Para o projeto final apresentado em sala de aula e disponível nesse repositório, o grupo se dedicou a implementar as funcionalidades necessárias para a execução de um algoritmo de fatorial. O código usado como exemplo se encontra em _fatorial.tiny_.

### Funcionalidades implementadas
- [x] Entrada e saída padrão
- [x] Leitura de arquivo
- [x] Operações aritméticas (soma, subtração, multiplicação, divisão)
- [x] Operadores de comparação (<,>,<=,>=)
- [x] Condicional _if_-_then_-_else_
- [x] Laço de repetição _repeat_-_until_
- [x] Condicional _if_ aninhado

### Funcionalidades não implementadas
- [x] Suporte a comentários

## Metodologia
O projeto foi desenvolvido a partir de _peer programming_, através de reuniões realizadas pelo _Discord_ utilizando a IDE do _Visual Studio Code_.  

### Participantes 
| Nome                               | Matrícula |
|------------------------------------|-----------|
| Álvaro Veloso Cavalcanti Luz       | 180115391 |
| Ayssa Giovanna de Oliveira Marques | 170100065 |
| Stefano Luppi Spósito              | 180043242 |
| Thiago Elias dos Reis              | 190126892 |

## Execução
## Preparando a TVM (Tiny Virtual Machine) do Louden para execução
```
cd ./louden
```
```
make clean
```
```
make
```
## Compilando um programa .tiny
Na pasta raiz:
```
cd ..
```
1. Compilar os analisadores léxico e sintático
```
make
```
2. Gerar código assembly
```
./a.out fatorial.tiny fatorial.asm
```
3. Executar o código gerado na TVM
```
./tm.o fatorial.asm
```


