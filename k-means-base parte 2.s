#
# IAC 2023/2024 k-means
# 
# Grupo: 47
# Campus: Alameda
#
# Autores:
# 106426, Pedro Rosa
# 109576, Jose Silvestre
# 109736, Pedro Menezes
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#.equ         N 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#.equ         N 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#.equ         N 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
.equ         N 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10


# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
centroids_antigos: .word 0,0, 10,0, 0,10
n_points:    .word N
clusters:    .zero N # mudar o numero de n_points



#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff


# Codigo
 
.text
    # Descomentar na 2a parte do projeto:
    jal ra, mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0, 1024 # numero de pontos 32*32 = 1024
    li t1, LED_MATRIX_0_BASE # endereco do primeiro ponto da matrix
    li t2, white # cor que vamos pintar a matrix
    
    cleanLoop:
        sw t2, 0(t1) # pinta de branco o ponto da matrix com o endereco a1
        addi t1, t1, 4 # passa para o pr?ximo ponto da matrix
        addi t0, t0, -1 # reduz o contador (a0)
        bne t0, x0, cleanLoop # volta caso a0 != 0
    
    jr ra # dah jump para ra
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    addi sp, sp, -24 # Atualiza o ponteiro para a ultima posicao do stack
    sw s0, 0(sp) # Guarda s0
    sw s1, 4(sp) # Guarda s1
    sw s2, 8(sp) # Guarda s2
    sw s3, 12(sp) # Guarda s3
    sw s4, 16(sp) # Guarda s4
    sw s5, 20(sp) # Guarda s5
    
    lw s0, n_points # numero de pontos
    la s1, points # endereco da lista de pontos
    la s2, colors # endereco da lista de cores
    la s3, clusters # endereco da lista de clusters
    printListaPontos:
        addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
        sw ra, 0(sp) # Guardar o endereco para onde voltar
        
        lw s4, 0(s1) # x
        lw s5, 4(s1) # y
        mv a0, s4 # a0: soma dos x
        mv a1, s5 # a1: soma dos y
        jal ra, nearestCluster
        sb a0, 0(s3) # guarda o indice no vetor
        slli a0, a0, 2 # multiplica o indice por 4
        add t0, a0, s2 # t0 fica com o endereco para a cor do centroid
        mv a0, s4 # a0: soma dos x
        mv a1, s5 # a1: soma dos y
        lw a2, 0(t0) # a2: cor
        jal ra, printPoint
    
        addi s1, s1, 8 # passa para o proximo x
        addi s0, s0, -1 # decrementa 1 ao contador
        addi s3, s3, 1 # passa para o proximo ponto
        
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        bne s0, x0, printListaPontos # se a0 = 0 acaba
    
    lw s0, 0(sp) # Recupera s0
    lw s1, 4(sp) # Recupera s1
    lw s2, 8(sp) # Recupera s2
    lw s3, 12(sp) # Recupera s3
    lw s4, 16(sp) # Recupera s4
    lw s5, 20(sp) # Recupera s5
    addi sp, sp, 24 # Dah pop na stack
    jr ra

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    addi sp, sp, -16 # Atualiza o ponteiro para a ultima posicao do stack
    sw s0, 0(sp) # Guarda s0
    sw s1, 4(sp) # Guarda s1
    sw s2, 8(sp) # Guarda s2
    sw s3, 12(sp) # Guarda s3
    
    lw s0, k # numero de centroids
    la s1, centroids # endereco da lista de centroids
    li s2, 0 # Inicializa o contador a 0
    la s3, colors # endereco da lista de cores
    printListaCentroids:
        addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
        sw ra, 0(sp) # Guardar o endereco para onde voltar
        
        lw a0, 0(s1) # x
        lw a1, 4(s1) # y
        lw a2, 0(s3) # color
        jal ra, printPoint
        
        addi s1, s1, 8 # passa para o proximo x
        addi s2, s2, 1 # incrementa 1 ao contador
        addi s3, s3, 4 # passa para a proxima cor
        
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        blt s2, s0, printListaCentroids # se a0 = 0 acaba
    
    lw s0, 0(sp) # Recupera s0
    lw s1, 4(sp) # Recupera s1
    lw s2, 8(sp) # Recupera s2
    lw s3, 12(sp) # Recupera s3
    addi sp, sp, 16 # Dah pop na stack
    jr ra

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    addi sp, sp, -44 # Atualiza o ponteiro para a ultima posicao do stack
    sw s0, 0(sp) # Guarda o valor de s0
    sw s1, 4(sp) # Guarda o valor de s1
    sw s2, 8(sp) # Guarda o valor de s2
    sw s3, 12(sp) # Guarda o valor de s3
    sw s4, 16(sp) # Guarda o valor de s4
    sw s5, 20(sp) # Guarda o valor de s5
    sw s6, 24(sp) # Guarda o valor de s6
    sw s7, 28(sp) # Guarda o valor de s7
    sw s8, 32(sp) # Guarda o valor de s8
    sw s9, 36(sp) # Guarda o valor de s9
    sw s10, 40(sp) # Guarda o valor de s10
    
    lw s0, n_points # Guarda em s0 o numero de pontos
    la s1, points # Guarda em s1 o endereco para o primeiro elemento da lista de pontos
    la s2, clusters # Guarda em s2 o enderesso para o primeiro elemento de lista clusters
    lw s3, k # Guarda em s3 o numero de centroides
    la s10, centroids # Guarda em s10 o enderesso para o primeiro elemento de lista centroids
    addi t0, s3, -1 # t0 = k - 1
    slli t0, t0, 3 # t0 = t0 * 8
    add s10, s10, t0 # s10 passa a ser o x do ultimo centroid
    calculateLoop:
        addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
        sw ra, 0(sp) # Guardar o endereco para onde voltar
        
        addi s3, s3, -1 # a3 = a3 -1 (centroid indice do centroid que vamos calcular)
        mv s4, s1 # s4 passa a ter o endereco para o primeiro elemento da lista de pontos
        mv s5, s2 # s5 passa a ter o endereco para o primeiro elemento da lista de clusters
        mv s6, s0 # s6 passa a ter o numero de pontos 
        li s7, 0 # Inizializar a soma de x a 0
        li s8, 0 # Inizializar a soma de y a 0
        li s9, 0 # Inicializar o numero de pontos do centroid a 0
        calculateLoop2:
            addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
            sw ra, 0(sp) # Guardar o endereco para onde voltar
            
            mv a0, s7 # a0: soma dos x
            mv a1, s8 # a1: soma dos y
            mv a2, s9 # a2: numero de pontos do centroid
            mv a3, s5 # a3: endereco do cluster
            mv a4, s3 # a4: indice do centroid
            mv a5, s4 # a5: endereco do ponto x
            jal ra, soma # a5: numero de pontos do centroid
            mv s7, a0 # atualiza a soma dos x
            mv s8, a1 # atualiza a soma dos y
            mv s9, a2 # atualiza o numero de pontos nesse grupo
            
            addi s4, s4, 8 # passa para o proximo ponto no vetor pontos
            addi s5, s5, 1 # passa para o proximo ponto no vetor clusters
            addi s6, s6, -1 # diminui o contador
            
            lw ra, 0(sp) # Recupera o endereco para onde voltar
            addi sp, sp, 4 # Dah pop na stack
            bne s6, x0, calculateLoop2 # acaba se s3 = 0
        div a0, s7, s9 # a0: x do centroid
        div a1, s8, s9 # a1: y do centroid
        mv a2, s9 # a2: numero de pontos do centroide
        mv a3, s10 # a3: endereco de x do centroid
        jal ra, atualizaCentroids
        addi s10, s10, -8 # passa para o proximo centroid
        
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        bne s3, x0, calculateLoop # acaba se s3 = 0
    
    lw s0, 0(sp) # Recupera o valor de s0
    lw s1, 4(sp) # Recupera o valor de s1
    lw s2, 8(sp) # Recupera o valor de s2
    lw s3, 12(sp) # Recupera o valor de s3
    lw s4, 16(sp) # Recupera o valor de s4
    lw s5, 20(sp) # Recupera o valor de s5
    lw s6, 24(sp) # Recupera o valor de s6
    lw s7, 28(sp) # Recupera o valor de s7
    lw s8, 32(sp) # Recupera o valor de s8
    lw s9, 36(sp) # Recupera o valor de s9
    lw s10, 40(sp) # Recupera o valor de s10
    addi sp, sp, 44 # Dah pop na stack
    jr ra

### atualizaCentroids
# soma os pontos
# Argumentos:
# a0: x do centroid
# a1: y do centroid
# a2: numero de pontos do centroide
# a3: endereco de x do centroid
# Retorno: nenhum

atualizaCentroids:
    beq a2, x0, volta
    sw a0, 0(a3) # Guarda o x do centroid
    sw a1, 4(a3) # Guarda o y do centroid
    jr ra

### soma
# soma os pontos
# Argumentos:
# a0: soma dos x
# a1: soma dos y
# a2: numero de pontos do centroid
# a3: endereco do cluster
# a4: indice do centroid
# a5: endereco do ponto x
# Retorno:
# a0: nova soma dos x
# a1: nova soma dos y
# a2: novo numero de pontos do centroid

soma:
    lb t0, 0(a3) # t0 ? o clutters
    bne t0, a4, volta
    lw t1, 0(a5) # x
    lw t2, 4(a5) # y
    add a0, a0, t1 # atualiza a soma x
    add a1, a1, t2 # atualiza a soma y
    addi a2, a2, 1 # atualiza o numero de pontos do centroid
    jr ra

### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    addi sp, sp, -8 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    sw s0, 4(sp) # Guarda s0
    
    sub a0, a0, a2 # subtrai os x
    jal ra, inverso # vai para a funcao inverso
    mv s0, a0 # guarda em s0 o valor da distancia entre os x
    
    sub a0, a1, a3 # subtrai os y
    jal ra, inverso # vai para a funcao inverso
    mv t0, a0 # guarda em t0 o valor da distancia entre os y
    
    add a0, s0, t0 # a0 = (distancia x) + (distacia y)
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    lw s0, 4(sp) # Recupera o valor de s0
    addi sp, sp, 8 # Dah pop na stack
    jr ra

### inverso
# passa o numero para o seu inverso se for negativo
# Argumentos:
# a0: numero
# Retorno:
# a0: -a0

inverso:
    bgt a0, x0, volta # se a subtracao der um numero positivo volta para onde ficou
    neg a0, a0 # nega o a0
    
volta:
    jr ra

### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp, sp, -24 # Atualiza o ponteiro para a ultima posicao do stack
    sw s0, 0(sp) # Guarda o valor de s0
    sw s1, 4(sp) # Guarda o valor de s1
    sw s2, 8(sp) # Guarda o valor de s2
    sw s3, 12(sp) # Guarda o valor de s3
    sw s4, 16(sp) # Guarda o valor de s4
    sw s5, 20(sp) # Guarda o valor de s5
    
    lw s2, k # guarda o valor de k em a2
    la s3, centroids # guarda em a3 o primeiro endereco do vetor centroids
    mv s0, a0 # guarda o valor de a0 em s0
    mv s1, a1 # guarda o valor de a1 em s1
    li s4, 0x7FFFFFFF # inicializa s5 com o maior valor de inteiro
    li s5, 0 # inicializa o cluster index a 0

    comparaCentroids:
        addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
        sw ra, 0(sp) # Guardar o endereco para onde voltar
        
        mv a0, s0 # guarda em a0 o valor de x0 (x do ponto)
        mv a1, s1 # guarda em a1 o valor de y0 (y do ponto)
        lw a2, 0(s3) # guarda em a2 o valor de x1
        lw a3, 4(s3) # guarda em a3 o valor de y1
        jal ra, manhattanDistance
        mv a1, s2 # a1: numero de centroids que falta ver
        mv a2, s4 # a2: distancia minima
        mv a3, s5 # a3: indice antigo
        jal ra, atualizaMinimo
        mv s4, a0 # guarda em s4 a nova distancia minima
        mv s5, a1 # guarda em s5 o novo indice
    
        addi s3, s3, 8 # passa para o endereco do proximo x
        addi s2, s2, -1 # reduz o contador
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        bne s2, x0, comparaCentroids # sai do loop se s2 = 0
    mv a0, s5
    
    lw s5, 20(sp) # Recupera o valor de s5
    lw s4, 16(sp) # Recupera o valor de s4
    lw s3, 12(sp) # Recupera o valor de s3
    lw s2, 8(sp) # Recupera o valor de s2
    lw s1, 4(sp) # Recupera o valor de s1
    lw s0, 0(sp) # Recupera o valor de s0
    addi sp, sp, 24 # Dah pop na stack
    jr ra
    
### atualizaMinimo
# Executa o algoritmo *k-means*.
# Argumentos:
# a0: distancia
# a1: numero de centroids que falta ver
# a2: distancia minima
# a3: indice antigo
# Retorno:
# a0: nova distancia minima
# a1: novo indice

atualizaMinimo:
    mv t3, a0 # Guarda 
    mv t2, a1
    mv a1, a3 # indice antigo
    mv a0, a2
    bgt t3, a2, volta # se a0 > a2 entao nao troca os minimos
    mv a0, t3
    lw t0, k # guarda o numero de centroids
    sub t1, t0, t2 # calcula o indice do centroid
    mv a1, t1 # guarda em a0 o novo indice
    jr ra
    
### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    addi sp, sp, -16 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    sw s0, 4(sp) # Guarda s0
    sw s1, 8(sp) # Guarda s1
    sw s2, 12(sp) # Guarda s2
    
    lw s0, L # numero de iteracoes
    li s1, 0
    mainLoop:
        jal ra, cleanScreen
        jal ra, printClusters
        jal ra, calculateCentroids
        jal ra, printCentroids
        jal ra, verificaIguais
        mv s2, a0
        addi s1, s1, 1
        jal ra, atualizaCentroidAntigo
        beq s2, x0, mainLoop
        bne s1, s0, mainLoop
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    lw s0, 4(sp) # Recupera s0
    lw s1, 8(sp) # Recupera s1
    lw s2, 12(sp) # Recupera s2
    addi sp, sp, 16 # Dah pop na stack
    jr ra
    
### atualizaCentroidAntigo
# atualiza o centroid antigo
# Argumentos: nenhum
# Retorno: nenhum

atualizaCentroidAntigo:
    la t0, centroids # Guarda em t0 o endereco de centroids
    la t1, centroids_antigos # Guarda em t1 o endereco de centroids_antigos
    lw t2, k # numero de centroids
    
    atualizaLoop:
        lw t3, 0(t0) # x
        sw t3, 0(t1) # x antigo
        lw t5, 4(t0) # y
        sw t5, 4(t1) # y antigo
        addi t0, t0, 8 # passa para o proximo tentar
        addi t1, t1, 8 # passa para o proximo tentar
        addi t2, t2, -1 # encrementa 1 ao contador
        bne t2, x0, atualizaLoop
        
    jr ra

### verificaIguais
# verifica se os centroids se alteraram
# Argumentos: nenhum
# Retorno: 
# a0: 1 se forem iguais e 0 se forem diferentes

verificaIguais:
    la t0, centroids # Guarda em t0 o endereco de centroids
    la t1, centroids_antigos # Guarda em t1 o endereco de centroids_antigos
    lw t2, k # numero de centroids
    slli t2, t2, 1 # k*2
    li a0, 0
    verificaLoop:
        addi t2, t2, -1 # encrementa 1 ao contador
        lw t3, 0(t0) # novo
        lw t4, 0(t1) # antigo
        addi t0, t0, 4 # passa para o proximo tentar
        addi t1, t1, 4 # passa para o proximo tentar
        bne t3, t4, volta # se nao for igual volta e devolve 0
        bne t2, x0, verificaLoop
        
    li a0, 1
    jr ra