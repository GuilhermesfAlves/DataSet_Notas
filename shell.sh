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
    #perc_evasoes $arq
    #rend_pand $arq
    rend_after_pand $arq
}


#função que remove que remove todas as linhas que façam parte de 2-2022
function remove_2_2022()
{
    echo "Lista de pessoas que nao fazem parte do segundo semestre de 2022"
    arq=$1 
    #remove ocorrencias de 2022,2, remove cabeçalho
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
    #ordena por status, deixa somente os status, e conta
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
    echo -e "ANO\tAPRO\tREPR"
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
        
        echo -e "$i\t:$aprov\t:$reprov"
        rm $ano
    done
    
    rm $temp
}

media()
{
    #parametro de arquivo trabalhado
    arq=$1
    #parametro de status que se quer buscar
    status=$2
    #parametro de tipo de dado que se quer, frequencia ou nota
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
    
    cat $temp | grep $status > $temp
 
    min=$(cut -d, -f3 $temp | head -n1)
    max=$(cut -d, -f3 $temp | tail -n1)
    
    echo "ANO  mediaANO  media1p  media2p"
    #calculo da porcentagem para cada semestre 
    mediaG=0
    for ((ano=$min; ano<=$max; ano++))
    do
        taxa1='taxa1sem.txt'
        taxa2='taxa2sem.txt'

        qtd1=$(grep -c "1,$ano" $temp) 
        qtd2=$(grep -c "2,$ano" $temp)

        grep "1,$ano" $temp | cut -d, -f1,2,4 >> $taxa1
        grep "2,$ano" $temp | cut -d, -f1,2,4 >> $taxa2

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

        #para nao dividir por 0
        if (($qtd1 != 0))
        then
            media1=$(echo "scale = 0; $soma1 / $qtd1" | bc)
        fi
        if (($qtd2 != 0))
        then
            media2=$(echo "scale = 0; $soma2 / $qtd2" | bc)
        fi

        #para nao somar com semestre sem data
        if (($media1 == 0)) && (($media2 != 0))
        then
            mediaT=$media2
        elif (($media2 == 0)) && (($media1 != 0))
        then 
            mediaT=$media1
        else
            mediaT=$(echo "scale = 1; ($media1 + $media2) / 2" | bc)
        fi       

        echo -e "$ano\t:$mediaT\t:$media1\t:$media2"
        mediaG=$(echo "scale = 2; $mediaT + $mediaG" | bc )
        rm $taxa1
        rm $taxa2
    done

    mediaG=$(echo "scale = 2; $mediaG/($max - $min + 1)" | bc )
    echo -e "\tMedia Total :$mediaG"

    rm $temp
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
perc_evasoes()
{
    echo "porcentagem de evasao total e anual"
    echo -e "ANO \t %"
    arq=$1
    temp='temp.txt'
    #remove equivalencias, remove cabeçalho, corta as linhas de anos e status, ordena
    grep -v EQUIVALENCIA $arq | grep -v matricula | cut -d, -f5,10 | sort >> $temp
    #valores minimo e maximo
    min=$(cut -d, -f1 $temp | head -n1)
    max=$(cut -d, -f1 $temp | tail -n1)
    soma=0
    total=0
    for ((i=$min; i<=$max; i++))
    do
        alun_em_ano=$(grep -c "$i" $temp)                         #quantidade de alunos em cada ano
        num=$(grep Cancelado $temp | grep -c "$i")                #quantidade de cancelados em um ano
        soma=$(expr $num + $soma)                                 #soma total de cancelados
        total=$(expr $total + $alun_em_ano)                       #quantidade total de alunos
        num=$(echo "scale = 2; $num * 100 / $alun_em_ano" | bc)   #calculo da porcentagem por ano
        echo -e "$i\t:$num"
    done
    soma=$(echo "scale = 2; $soma * 100 / $total" | bc)
    echo -e "TOTAL DE EVASOES \t :$soma"
    rm $temp
}

#rendimento dos anos de pandemia em relação com os anteriores
rend_pand()
{
    echo "rendimento dos alunos de pandemia(2020,2021) em relação com anteriores"
    arq=$1
    evas='AAevasao.txt'
    aprov='AAaprov.txt'
    reprov='AAreprov.txt'
    mn_a='AAmedia_nota_aprov.txt'
    mn_r='AAmedia_nota_reprov.txt'
    mf_r='AAmedia_freq_reprov.txt'
    perc_evasoes $arq | tail -n13 | head -n11 | cut -d. -f1 > $evas
    perc_aprov_reprov_ano $arq | tail -n12 | grep -v 2022 | cut -d: -f1,2 | cut -d. -f1 > $aprov
    perc_aprov_reprov_ano $arq | tail -n12 | grep -v 2022 | cut -d: -f1,3 | cut -d. -f1 > $reprov
    media_nota_aprov $arq | grep 20 | grep -v 2022 | cut -d: -f1,2 | cut -d. -f1 > $mn_a
    media_nota_reprov $arq | grep 20 | grep -v 2022 | cut -d: -f1,2 | cut -d. -f1 > $mn_r
    media_freq_reprov $arq | grep 20 | grep -v 2022 | cut -d: -f1,2 | cut -d. -f1  > $mf_r

    dados_pre='AAdados.txt'
    for doc in {$evas,$aprov,$reprov,$mn_a,$mn_r,$mf_r}
    do
        min=$(cut -b1-4 $doc | head -n1)
        max=$(cut -b1-4 $doc | grep -v 2020 | grep -v 2021 | tail -n1)

        soma=0
        for ((i=$min; i<=$max; i++))
        do
            num=$(grep "$i" $doc | cut -d: -f2)
            soma=$(echo "scale = 0; $soma + $num" | bc)
        done
        soma=$(echo "$soma / ($max - $min + 1) " | bc)
        echo "$soma" >> $dados_pre
    done

    dados_pand='AAdados.csv'

    for doc in {$evas,$aprov,$reprov,$mn_a,$mn_r,$mf_r}
    do
        num0=$(grep 2020 $doc | cut -d: -f2)
        num1=$(grep 2021 $doc | cut -d: -f2)
        echo "$num0,$num1" >> $dados_pand
    done
    echo -e "\tpre\t2020\t2021\t%2020\t%2021"
    n=1
    dados_tot='AAdadost.csv'
    for i in {"evas","aprov","reprov","mn_a","mn_r","mf_r"}
    do
        pre=$(head -n"$n" $dados_pre | tail -n1)
        n2020=$(head -n"$n" $dados_pand | tail -n1 | cut -d, -f1)
        n2021=$(head -n"$n" $dados_pand | tail -n1 | cut -d, -f2)
        p2020=$(echo "scale = 2; $n2020 * 100 / $pre" | bc)
        p2021=$(echo "scale = 2; $n2021 * 100 / $pre" | bc)
        echo -e "$i\t$pre\t$n2020\t$n2021\t$p2020\t$p2021"
        n=$(expr $n + 1)
    done
    rm *dados*.*
    rm AA*.txt
}

#rendimento dos alunos em 2022-1 em relação a pandemia e anos anteriores
rend_after_pand()
{
    echo "rendimento de alunos em 2022-1 e em pandemia em relacao a antes da pandemia"
    arq=$1
    evas='AAevasao.txt'
    aprov='AAaprov.txt'
    reprov='AAreprov.txt'
    mn_a='AAmedia_nota_aprov.txt'
    mn_r='AAmedia_nota_reprov.txt'
    mf_r='AAmedia_freq_reprov.txt'
    perc_evasoes $arq | grep 20 | cut -d. -f1 > $evas
    perc_aprov_reprov_ano $arq | tail -n12 | cut -d: -f1,2 | cut -d. -f1 > $aprov
    perc_aprov_reprov_ano $arq | tail -n12 | cut -d: -f1,3 | cut -d. -f1 > $reprov
    media_nota_aprov $arq | grep 20 | cut -d: -f1,2 | cut -d. -f1 > $mn_a
    media_nota_reprov $arq | grep 20 | cut -d: -f1,2 | cut -d. -f1 > $mn_r
    media_freq_reprov $arq | grep 20 | cut -d: -f1,2 | cut -d. -f1  > $mf_r

    dados_pre='AAdados.txt'
    for doc in {$evas,$aprov,$reprov,$mn_a,$mn_r,$mf_r}
    do
        min=$(cut -b1-4 $doc | head -n1)
        max=$(cut -b1-4 $doc | grep -v 2020 | grep -v 2021 | grep -v 2022 | tail -n1)

        soma=0
        for ((i=$min; i<=$max; i++))
        do
            num=$(grep "$i" $doc | cut -d: -f2)
            soma=$(echo "scale = 0; $soma + $num" | bc)
        done
        soma=$(echo "$soma / ($max - $min + 1) " | bc)
        echo "$soma" >> $dados_pre
    done

    dados_pand='AAdados.csv'

    for doc in {$evas,$aprov,$reprov,$mn_a,$mn_r,$mf_r}
    do
        num0=$(grep 2020 $doc | cut -d: -f2)
        num1=$(grep 2021 $doc | cut -d: -f2)
        echo "$num0,$num1" >> $dados_pand
    done

    dados_after='AAdadosA.csv'

    for doc in {$evas,$aprov,$reprov,$mn_a,$mn_r,$mf_r}
    do
        grep "2022" $doc | cut -d: -f2 >> $dados_after
    done

    echo -e "\tpre\t2020\t2021\t2022-1\t%2020\t%2021\t%2022-1"
    n=1
    dados_tot='AAdadost.csv'
    for i in {"evas","aprov","reprov","mn_a","mn_r","mf_r"}
    do
        pre=$(head -n"$n" $dados_pre | tail -n1)
        n2020=$(head -n"$n" $dados_pand | tail -n1 | cut -d, -f1)
        n2021=$(head -n"$n" $dados_pand | tail -n1 | cut -d, -f2)
        n2022=$(head -n"$n" $dados_after | tail -n1)
        p2020=$(echo "scale = 1; $n2020 * 100 / $pre" | bc)
        p2021=$(echo "scale = 1; $n2021 * 100 / $pre" | bc)
        p2022=$(echo "scale = 1; $n2022 * 100 / $pre" | bc)
        echo -e "$i\t:$pre\t:$n2020\t:$n2021\t:$n2022\t:$p2020\t:$p2021\t:$p2022"
        n=$(expr $n + 1)
    done
    rm *dados*.*
    rm AA*.txt
}

main
