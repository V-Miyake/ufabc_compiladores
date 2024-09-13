# Projeto Compiladores
Compilador utilizando ANTLR para reconhecer um código no formato IsiLanguage e traduzindo-a para C

## Vinicius Hideo Miyake

### Tipos de variáveis
- number
- realnumber
- text

### Declaração de variável
são feitas utilizando o comando declare

### Comandos reconhecidos
- (:=) Atribuição
- leia
- escreva
- se senao
- enquanto
- faca enquanto

  ### aceita expressões aritméticas
  Tem como prioridade multiplicações e divisões, depois soma e subtração.
  seu avaliador é chamado em toda vez que se encontra uma expressão, caso a expressão possua uma variável, tenha um operador relacional, ou é um ID retorna um NaN

  ### erros na verificação de variável
  - caso uma variavel tenta receber um elemento cujo tipo tenha um valor maior que o seu
  - caso a variável já foi previamente declarada
  - se a variável foi declarada e não foi utilizada
  - se a variável está sendo usada sem ter um valor inicial


 ## Descrição da IsiLanguage
 começa com a palavra reservada 'programa' seguida do nome que será dado ao programa em C
 tem um bloco de declaração das variáveis
 começa o programa entre as palavras reservadas 'inicio' e 'fim'
 neste bloco são aceito um ou mais comandos, sendo eles:
    - (:=) Atribuição
    - leia
    - escreva
  comando que possuem blocos de comando
    - se senao
    - enquanto
    - faca enquanto

