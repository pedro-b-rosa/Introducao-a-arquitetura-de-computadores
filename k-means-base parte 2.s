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
n_points:    .word N
clusters:    .zero N # mudar o numero de n_points



#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff


# Codigo
 
.text
    # Descomentar na 2a parte do projeto:
    jal mainKMeans
    
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
    # POR IMPLEMENTAR (1a parte)
    addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    
    li a0, 1024 # numero de pontos 32*32 = 1024
    li a1, LED_MATRIX_0_BASE # endereco do primeiro ponto da matrix
    li a2, white # cor que vamos pintar a matrix
    jal ra, cleanLoop # entra no Loop para limpar ponto a ponto
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 4 # Dah pop na stack
    jr ra # dah jump para ra

### cleanLoop
# Limpa todos os pontos do ecra
# Argumentos:
# a0: numero de pontos 32*32 = 1024
# a1: endereco do primeiro ponto da matrix
# a2: cor que vamos pintar a matrix
# Retorno: nenhum

cleanLoop:
    beq a0, x0, acabaLoop # acaba o loop caso a0 = 0
    sw a2, 0(a1) # pinta de branco o ponto da matrix com o endereco a1
    addi a1, a1, 4 # passa para o pr?ximo ponto da matrix
    addi a0, a0, -1 # reduz o contador (a0)
    j cleanLoop # volta para o loop 
    
acabaLoop:
    jr ra
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # POR IMPLEMENTAR (1a e 2a parte)
    addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    
    lw a0, n_points # numero de pontos
    la a1, points # endereco da lista de pontos
    jal ra, printListaPontos
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 4 # Dah pop na stack
    jr ra 

### printListaPontos
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos:
# a0: numero de pontos
# a1: endereco da lista de pontos
# Retorno: nenhum

printListaPontos:
    beq a0, x0, acabaLoop # se a0 = 0 acaba
    addi sp, sp, -12 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    sw a0, 4(sp) # Guarda o numero de pontos que ainda falta pintar
    sw a1, 8(sp) # Guarda o endereco o x que vamos pintar
    
    lw a0, 0(a1) # x
    lw a1, 4(a1) # y
    li a2, black # cor do ponto
    jal ra, printPoint
    
    lw a0, 4(sp) # Recupera o numero de pontos que ainda falta pintar
    lw a1, 8(sp) # Recupera o endereco o x que pintamos
    addi a1, a1, 8 # passa para o proximo x
    addi a0, a0, -1 # decrementa 1 ao contador
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 12 # Dah pop na stack
    j printListaPontos # volta para o inicio do loop

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    
    lw a0, k # numero de centroids
    la a1, centroids # endereco da lista de centroids
    jal ra, printListaPontos
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 4 # Dah pop na stack
    jr ra 

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    addi sp, sp, -8 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    sw s0, 4(sp) # Guarda o valor de s0
    
    lw a0, n_points # Guarda em a0 o numero de pontos
    la a1, points # Guarda em a1 o endereco para o primeiro elemento da lista de pontos
    la a2, clusters #Guarda em a2 o enderesso para o primeiro elemento de lista clusters
    lw s3, k # Guarda em a3 o numero de centroides 
    calculateLoop:
        beq s3, x0, acabaLoop
    
        addi s3, s3, -1 # a3 = a3 -1 (centroid indice do centroid que vamos calcular)
        
    
        j calculateLoop
    
    lw s0, 4(sp) # Recupera o valor de s0
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 8 # Dah pop na stack
    jr ra 

### soma
# soma os pontos
# Argumentos:
# a0: numero de pontos
# a1: endereco da lista de pontos
# a2: endereco da lista de clusters
# Retorno:
# a0: soma dos x
# a1: soma dos y
# a2: numero de pontos desse centoide
soma:
    beq a0, x0, acabaSoma # se a0 = 0 acaba
    addi a0, a0, -1 # a0 = a0 -1
    
    lw t2, 0(a1) # x
    lw t3, 4(a1) # y
    add t0, t0, t2 # t0 = t0 + t2
    add t1, t1, t3 # t1 = t1 + t3
    addi a1, a1, 8 # passa para o proximo x
    j soma
    
acabaSoma:
    mv a0, t0 # guarda o valor da soma x no registo de retorno
    mv a1, t1 # guarda o valor da soma y no registo de retorno
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
    bgt a0, x0, acabaLoop # se a subtracao der um numero positivo volta para onde ficou
    neg a0, a0 # nega o a0
    jr ra

### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp, sp, -28 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    sw s0, 4(sp) # Guarda o valor de s0
    sw s1, 8(sp) # Guarda o valor de s1
    sw s2, 12(sp) # Guarda o valor de s2
    sw s3, 16(sp) # Guarda o valor de s3
    sw s4, 20(sp) # Guarda o valor de s4
    sw s5, 24(sp) # Guarda o valor de s5
    
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
        jal ra, atualizaMinimo
    
        addi s3, s3, 8 # passa para o endereco do proximo x
        addi s2, s2, -1 # reduz o contador
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        bne s2, x0, comparaCentroids # sai do loop se s2 = 0
    mv a0, s5
    
    lw s5, 24(sp) # Recupera o valor de s5
    lw s4, 20(sp) # Recupera o valor de s4
    lw s3, 16(sp) # Recupera o valor de s3
    lw s2, 12(sp) # Recupera o valor de s2
    lw s1, 8(sp) # Recupera o valor de s1
    lw s0, 4(sp) # Recupera o valor de s0
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 28 # Dah pop na stack
    jr ra
    
atualizaMinimo:
    bgt a0, s4, acabaLoop # se a0 > s4 entao nao troca os minimos
    mv s4, a0 # guarda em s4 a nova distancia minima
    lw t0, k # guarda o numero de centroids
    sub t1, t0, s2 # calcula o indice do centroid
    mv s5, t1 # guarda em s5 o novo indice
    jr ra
    
### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 4 # Dah pop na stack
    jr ra
