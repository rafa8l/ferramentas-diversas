import random

linguagens = ['Símbolos gráficos', 'Gestos com a mão', 'Sons sem fala', 'Fala literária', 'Desenho', 'Escrita metafórica']
dicionário = {
    'Símbolos gráficos': ['Energia', 'Rádio', 'Vaga', 'Livro'],
    'Gestos com a mão': ['Girando', 'Filmando', 'Andando à cavalo', 'Voando'],
    'Sons sem fala': ['Trem passando', 'Cortando papel', 'Pessoa pulando', 'Pedra caindo na água'],
    'Fala literária': ['Tristeza', 'Esuforia', 'Alegria', 'Tédio'],
    'Desenho': ['Espaço', 'Idade', 'Inteligência', 'Internet'],
    'Escrita metafórica': ['Futebol', 'Tênis de Mesa', 'Corrida', 'Vôlei']
}

def sortear_desafio():
    linguagem = random.choice(linguagens)
    print('    Linguagem: ', linguagem)

    palavras_possiveis = dicionário[linguagem].copy()
    desafio = random.choice(palavras_possiveis)
    palavras_possiveis.remove(desafio)
    print('      -> Palavra: ', desafio)

while True:
    entrada = input("Pressione 's' para sortear ou 'q' para sair: ")
    if entrada.lower() == 's':
        sortear_desafio()
    elif entrada.lower() == 'q':
        exit()
    else:
        print("Entrada inválida. Pressione 's' para sortear ou 'q' para sair.")