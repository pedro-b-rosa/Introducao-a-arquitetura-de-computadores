#
# IAC 2023/2024 k-means
# 
# Grupo:
# Campus: Alameda
#
# Autores:
# 106426, Pedro Rosa
# n_aluno, nome
# n_aluno, nome
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
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff


# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
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
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li a0, 1024 # numero de pontos 32*32 = 1024
    li a1, LED_MATRIX_0_BASE
    li a2, white
    jal ra, cleanLoop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

cleanLoop:
    beq a0, x0, acabaLoop
    sw a2, 0(a1)
    addi a1, a1, 4
    addi a0, a0, -1
    j cleanLoop
    
    
acabaLoop:
    jr ra
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # POR IMPLEMENTAR (1a e 2a parte)
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    lw a0, n_points # numero de pontos
    la a1, points # endereco da lista de pontos
    jal ra, printListaPontos
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

printListaPontos:
    beq a0, x0, acabaLoop
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    
    lw a0, 0(a1) # x
    lw a1, 4(a1) # y
    li a2, black
    jal ra, printPoint
    
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi a1, a1, 8 # passa para o proximo x
    addi a0, a0, -1
    
    lw ra, 0(sp)
    addi sp, sp, 12
    j printListaPontos

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    lw a0, k # numero de centroids
    la a1, centroids # endereco da lista de centroids
    jal ra, printListaPontos
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    lw s0, n_points # numero de pontos
    mv a0, s0
    la a1, points # endereco da lista de pontos
    li t0, 0 # inicializar os contadores a 0
    li t1, 0
    jal ra, soma
    div t0, a0, s0
    div t1, a1, s0
    la t2, centroids
    sw t0, 0(t2) # guarda o valor de x do centroid
    sw t1, 4(t2) # guarda o valor de y do centroid
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    jr ra

### soma
# soma os pontos
# Argumentos:
# a0: numero de pontos
# a1: endereco da lista de pontos
# Retorno:
# a0: soma dos x
# a1: soma dos y
soma:
    beq a0, x0, acabaSoma
    addi a0, a0, -1
    lw t2, 0(a1) # x
    lw t3, 4(a1) # y
    add t0, t0, t2
    add t1, t1, t3
    addi a1, a1, 8 # passa para o proximo x
    j soma
    
acabaSoma:
    mv a0, t0
    mv a1, t1
    jr ra
    
### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    #1. Coloca k=1 (caso nao esteja a 1)
    # POR IMPLEMENTAR (1a parte)
    la t0, k
    li t1, 1
    sw t1, 0(t1)

    #2. cleanScreen
    # POR IMPLEMENTAR (1a parte)
    jal ra, cleanScreen
    
    #3. printClusters
    # POR IMPLEMENTAR (1a parte)
    jal ra, printClusters

    #4. calculateCentroids
    # POR IMPLEMENTAR (1a parte)
    jal ra, calculateCentroids

    #5. printCentroids
    # POR IMPLEMENTAR (1a parte)
    jal ra, printCentroids

    #6. Termina
    jr ra



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra
