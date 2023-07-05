#!/bin/bash



main()
{
    arq="historico-alg1_SIGA_ANONIMIZADO.csv"
    #remove_2_2022 $arq
    #qtd_ind_status $arq
    #max_vez_cursado $arq
    #perc_aprov_reprov_ano $arq
    #media_nota_aprov $arq
    #media_nota_reprov $arq
    #media_freq_reprov $arq
    
}


#função que remove que remove todas as linhas que façam parte de 2-2022
function remove_2_2022()
{
    echo "Lista de pessoas que nao fazem parte do segundo semestre de 2022"
    arq=$1 
    grep -v "2,2022" $arq | grep -v matricula
}

# for i in {00..29}; do echo -n "$i "; echo $(./agenda  |   grep MEMBROS |grep "$i:OK"|wc -l) ; done 
#calculo do numero de individuos unicos para tal status
qtd_ind_status()
{ 
    echo "Numero de individuos unicos para cada status"
    arq=$1
    temp="temp.txt"
    #remove equivalencia 2019, pega colunas grr e status, tira cabeçalho, remove linhas repetidas, joga em temp
    grep -v "CI1055,ALGORITMOS E ESTRUTURAS DE DADOS 1,1,2019,Sim,60,0,0,Aprovado,EQUIVALENCIA" $arq | cut -d, -f'1,10' | grep -v "status" | uniq -u >> $temp
    sort -t, -k2 $temp | cut -d, -f2 | uniq -c 
    
    rm $temp
}

#máximo de vezes que um individuo cursou antes de ser aprovado
#quantos individuos possuem o mesmo numero
max_vez_cursado()
{
    echo "Numero maximo de vezes que alguem cursou ALG1 e quantos obtiveram a mesma quantidade"
    arq=$1
    temp="temp.txt"
    #remove equivalencia 2019, tira cabeçalho, pega a primeira coluna de grrs, joga em temp.txt
    grep -v "CI1055,ALGORITMOS E ESTRUTURAS DE DADOS 1,1,2019,Sim,60,0,0,Aprovado,EQUIVALENCIA" $arq | grep -v "matricula" | cut -d, -f'1' >> $temp
    
    #quantas pessoas fizeram o numero máximo de vezes
    p=$(uniq -c $temp | cut -d' ' -f7 | sort | uniq -c | tail -n1 | cut -d' ' -f7 )  
    #quantas vezes estas pessoas fizeram
    qtd=$(uniq -c $temp | cut -d' ' -f7 | sort | uniq -c | tail -n1 | cut -d' ' -f8)
    echo -e "\t$p passaram por ALG1 $qtd vezes"
    rm $temp
}

#porcentagem aprovação e reprovação por ano
perc_aprov_reprov_ano()
{
    echo "Porcentagem de aprovados e reprovados em cada ano"
    arq=$1
    temp="temp.txt"
    #remove equivalencia 2019, tira cabeçalho, ordena por ano, pega as colunas de ano e status, remove os ainda matriculados
    grep -v "CI1055,ALGORITMOS E ESTRUTURAS DE DADOS 1,1,2019,Sim,60,0,0,Aprovado,EQUIVALENCIA" $arq | grep -v "matricula" | sort -t, -k5 | cut -d, -f'5,10' | grep -v "Matriculado">> $temp
    
    #menor e maior ano obtidos nos dados
    min=$(cut -d, -f1 $temp | head -n1)
    max=$(cut -d, -f1 $temp | tail -n1)
    #calculo da porcentagem para cada ano
    for ((i=$min; i<=$max; i++))
    do
        ano='$i_taxa.txt'
        
        #joga em um arquivo PE:"2020_taxa.txt" a quantidade de aprovados, reprovados por nota, por frequencia, ou cancelados
        grep "$i" $temp | sort -t, -k2 | cut -d, -f2 >> $ano
        
        #calculo da porcentagem de aprovados e reprovados em cada ano
        aprov=$(grep -c "Aprovado" $ano)
        reprov=$(grep -cv "Aprovado" $ano)
        total=$(expr $aprov + $reprov)
        aprov=$(echo "scale = 2; $aprov * 100 / $total" | bc)
        reprov=$(echo "scale = 2; $reprov * 100 / $total" | bc)
        
        echo "$aprov% aprovados e $reprov% reprovados em $i"
        rm $ano
    done
    
    rm $temp
}

media()
{
    arq=$1
    status=$2
    if [ $3 = 'freq' ]
    then
        arg=9
    elif [ $3 = 'nota' ]
    then
        arg=8
    fi
    
    temp="temp.txt"
    #remove equivalencia, tira cabeçalho, separa as colunas grr:periodo:ano:nota:status, ordena pelos anos
    grep -v EQUIVALENCIA $arq | grep -v matricula | cut -d, -f1,4,5,$arg,10 | sort -t, -k3 >> $temp
    
    temp1="temp1.txt"
    cat $temp | grep $status >> $temp1
    rm $temp
 
    min=$(cut -d, -f3 $temp1 | head -n1)
    max=$(cut -d, -f3 $temp1 | tail -n1)
    
    echo "ANO  mediaANO  media1p  media2p"
    #calculo da porcentagem para cada ano
    mediaG=0
    for ((ano=$min; ano<=$max; ano++))
    do
        taxa1='taxa1sem.txt'
        taxa2='taxa2sem.txt'

        qtd1=$(grep -c "1,$ano" $temp1) 
        qtd2=$(grep -c "2,$ano" $temp1)

        grep "1,$ano" $temp1 | cut -d, -f1,2,4 >> $taxa1
        grep "2,$ano" $temp1 | cut -d, -f1,2,4 >> $taxa2

        soma1=0
        soma2=0

        for ((j=1; j<=$qtd1; j++))
        do
            nota=$(cut -d, -f3 $taxa1 | head -n"$j" | tail -n1)
            soma1=$(expr $soma1 + $nota)
        done
        for ((j=1; j<=$qtd2; j++))
        do
            nota=$(cut -d, -f3 $taxa2 | head -n"$j" | tail -n1)
            soma2=$(expr $soma2 + $nota)
        done
        
        media1=0
        media2=0

        if (($qtd1 != 0))
        then
            media1=$(echo "scale = 0; $soma1 / $qtd1" | bc)
        fi
        if (($qtd2 != 0))
        then
            media2=$(echo "scale = 0; $soma2 / $qtd2" | bc)
        fi

        if (($media1 == 0)) && (($media2 != 0))
        then
            mediaT=$media2
        elif (($media2 == 0)) && (($media1 != 0))
        then 
            mediaT=$media1
        else
            mediaT=$(echo "scale = 1; ($media1 + $media2) / 2" | bc)
        fi       

        echo -e "$ano\t$mediaT\t$media1\t$media2"
        mediaG=$(echo "scale = 2; $mediaT + $mediaG" | bc )
        rm $taxa1
        rm $taxa2
    done

    mediaG=$(echo "scale = 2; $mediaG/($max - $min + 1)" | bc )
    echo -e "\tMedia Total: $mediaG"

    rm $temp1
}

#media de nota de aprovados por ano e periodo
media_nota_aprov()
{
    echo "Media de nota dos aprovados em cada ano, periodo e total"
    media $1 Aprovado nota
}

#media de nota de reprovados por nota por ano e periodo
media_nota_reprov()
{
    echo "Media de nota dos reprovados por nota em cada ano, periodo e total"
    media $1 R-nota nota
}

#media de frequencia dos reprovados por nota
media_freq_reprov()
{
    echo "Media de frequencia dos reprovados por nota por ano, periodo e total"
    media $1 R-nota freq
}


#porcentagem de evasões total e anual
#perc_evasoes()
#{
#    arq=$1
#    grep -v EQUIVALENCIA $arq | grep -v matricula | 
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
