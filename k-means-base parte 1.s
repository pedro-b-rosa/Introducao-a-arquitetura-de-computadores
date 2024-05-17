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
    li t0, 1024 # numero de pontos 32*32 = 1024
    li t1, LED_MATRIX_0_BASE # endereco do primeiro ponto da matrix
    li t2, white # cor que vamos pintar a matrix
    
    cleanLoop:
        sw t2, 0(t1) # pinta de branco o ponto da matrix com o endereco a1
        addi t1, t1, 4 # passa para o pr?ximo ponto da matrix
        addi t0, t0, -1 # reduz o contador (a0)
        bne t0, t0, cleanLoop # volta caso a0 != 0
    
    jr ra # dah jump para ra
    
acabaLoop:
    jr ra
    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    addi sp, sp, -8 # Atualiza o ponteiro para a ultima posicao do stack
    sw s0, 0(sp) # Guarda s0
    sw s1, 4(sp) # Guarda s1
    
    lw s0, n_points # numero de pontos
    la s1, points # endereco da lista de pontos
    printListaPontos:
        addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
        sw ra, 0(sp) # Guardar o endereco para onde voltar
        
        lw a0, 0(s1) # x
        lw a1, 4(s1) # y
        li a2, black # cor do ponto
        jal ra, printPoint
    
        addi s1, s1, 8 # passa para o proximo x
        addi s0, s0, -1 # decrementa 1 ao contador
        
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        bne s0, x0, printListaPontos # se a0 = 0 acaba
    
    lw s0, 0(sp) # Recupera s0
    lw s1, 4(sp) # Recupera s1
    addi sp, sp, 8 # Dah pop na stack
    jr ra 

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    addi sp, sp, -8 # Atualiza o ponteiro para a ultima posicao do stack
    sw s0, 0(sp) # Guarda s0
    sw s1, 4(sp) # Guarda s1
    
    lw s0, k # numero de centroids
    la s1, centroids # endereco da lista de centroids
    printListaCentroids:
        addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
        sw ra, 0(sp) # Guardar o endereco para onde voltar
        
        lw a0, 0(s1) # x
        lw a1, 4(s1) # y
        li a2, black # cor do ponto
        jal ra, printPoint
    
        addi s1, s1, 8 # passa para o proximo x
        addi s0, s0, -1 # decrementa 1 ao contador
        
        lw ra, 0(sp) # Recupera o endereco para onde voltar
        addi sp, sp, 4 # Dah pop na stack
        bne s0, x0, printListaPontos # se a0 = 0 acaba
    
    lw s0, 0(sp) # Recupera s0
    lw s1, 4(sp) # Recupera s1
    addi sp, sp, 8 # Dah pop na stack
    jr ra 

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    addi sp, sp, -8 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar
    sw s0, 4(sp) # Guarda s0
    
    lw s0, n_points # numero de pontos
    mv a0, s0 # copia o valor em s0 para a0
    la a1, points # endereco da lista de pontos
    li t0, 0 # inicializar os contadores a 0
    li t1, 0
    jal ra, soma
    div t0, a0, s0 # divide a soma dos x pelo numero de pontos
    div t1, a1, s0 # divide a soma dos y pelo numero de pontos
    la t2, centroids # endereco do centroid
    sw t0, 0(t2) # guarda o valor de x do centroid
    sw t1, 4(t2) # guarda o valor de y do centroid
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    lw s0, 4(sp) # Recupera o valor de s0
    addi sp, sp, 8 # Dah pop na stack
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
    
### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    addi sp, sp, -4 # Atualiza o ponteiro para a ultima posicao do stack
    sw ra, 0(sp) # Guardar o endereco para onde voltar

    #1. Coloca k=1 (caso nao esteja a 1)
    # POR IMPLEMENTAR (1a parte)
    la t0, k
    li t1, 1
    sw t1, 0(t0)

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
    
    lw ra, 0(sp) # Recupera o endereco para onde voltar
    addi sp, sp, 4 # Dah pop na stack
    #6. Termina
    jr ra