#!/bin/bash



main()
{
    #remove_2_2022
    qtd_ind_status
    #max_vez_cursado
}


#função que remove que remove todas as linhas que façam parte de 2-2022
function remove_2_2022()
{
    arq="historico-alg1_SIGA_ANONIMIZADO.csv" 
    grep -v "2,2022" $arq 
}

# for i in {00..29}; do echo -n "$i "; echo $(./agenda  |   grep MEMBROS |grep "$i:OK"|wc -l) ; done 
#calculo do numero de individuos unicos para tal status
qtd_ind_status()
{ 
    arq="historico-alg1_SIGA_ANONIMIZADO.csv"
    #remove equivalencia 2019, pega colunas grr e status, tira cabeçalho, remove linhas repetidas
    grep -v "CI1055,ALGORITMOS E ESTRUTURAS DE DADOS 1,1,2019,Sim,60,0,0,Aprovado,EQUIVALENCIA"  $arq | cut -d, -f'1,10' | grep -v "matricula" | uniq -u >> qtd.csv
    for status in {"Matriculado","Aprovado","R-freq","R-nota","Cancelado"}
    do
        echo -e -n "$status " 
        grep $status --count qtd.csv
    done
    rm qtd.csv
}

#máximo de vezes que um individuo cursou antes de ser aprovado
#quantos individuos possuem o mesmo numero
max_vez_cursado()
{
    arq="historico-alg1_SIGA_ANONIMIZADO.csv"
    novo="qtd_cursado/ind.txt"
    grep -v "CI1055,ALGORITMOS E ESTRUTURAS DE DADOS 1,1,2019,Sim,60,0,0,Aprovado,EQUIVALENCIA" $arq 
    #rm $novo
}

#porcentagem aprovação e reprovação por ano
#perc_aprov_reprov_ano()
#{

#}

#media de nota de aprovados por ano e periodo
#media_nota_aprov()
#{

#}

#media de nota de reprovados por nota por ano e periodo
#media_nota_reprov()
#{

#}

#media de frequencia dos reprovados por nota
#media_freq_reprov()
#{

#}

#porcentagem de evasões total e anual
#perc_evasoes()
#{

#}

#rendimento dos anos de pandemia em relação com os anteriores
#rend_pand()
#{

#}

#rendimento dos alunos em 2022-1 em relação a pandemia e anos anteriores
#rend_after_pand()
#{

#}

main

#
#Expansão    corresponde à
#[b-e.;!]    Qualquer letra minúscula de “b” a “e”, “.”, “;” e “!”
#[!b-e]      Qualquer dígito, exceto letras minúsculas de “b” a “e”
#[A-Z0-9]    Qualquer letra maiúscula de “A” a “Z” e qualquer número de um dígito
#[a-df-i]    a, b, c, d, f, g, h, i
#[abc-]     “a”, “b”, “c”, ou “-”
#

#Expansão                        Resultado
#cat func.{c,h}                  conteúdo dos arquivos fun.c func.h
#ls rec0{1..4}.mp3               rec01.mp3 rec02.mp3 rec03.mp3 rec04.mp3
#touch 201{5..7}/ex{1..4}.txt    cria ex1.txt, ex2.txt, ex3.txt e ex4.txt
#                                nos diretórios 2015, 2016 e 2017
#echo turma{A..D}                turmaA turmaB turmaC turma D
#echo turma{A..G..2}             turmaA turmaC turmaE turma G


# man [comando] - Mostra uma página de manual para [comando] contendo
#  uma descrição detalhada de seu funcionamento, as opções que [comando]
#  pode utilizar e uma descrição detalhada do que a opção faz;
# cat - Copia entrada para saída;
# grep [PADRÃO] [arquivo] - Procura por [PADRÃO] em [arquivo];
# sort [arquivo] - Ordena as linhas de [arquivo];
# cut [arquivo] - Extrai determinadas colunas de [arquivo];
# sed - Editor para filtrar e editar arquivos;
# tr [set1] [set2] - Traduz [set1] para [set2], ou deleta [set1];
# head [arquivo] - Exibe o começo de [arquivo];
# tail [arquivo] - Exibe o fim de [arquivo];
# echo [linha] - Exibe [linha] ;
# ls [arquivo] - Lista os conteúdos de um diretório;
# cd [caminho] - troca do diretório atual para [caminho];
# wc [arquivo] - Exibe o número de linhas, palavras e bytes de [arquivo];
# pwd - Exibe posição do usuário na árvore de arquivos;
# mkdir [nome] - cria um diretório chamado [nome];
# touch [nome] - cria um arquivo chamado [nome];
# rm [arquivo] - remove [arquivo] (este arquivo é removido do sistema, não
#   existe “lixeira” para o rm);
# rmdir [diretório] - remove um diretório, desde que esteja vazio.
