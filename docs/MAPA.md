# Mapa do reino — versão 0.4

Primeira representação isométrica das três regiões. O mapa é uma vista do estado da simulação, sem estado econômico próprio. Não altera as regras de comércio, guerra, posse de terras ou duração das entregas.

## Interação

- Clique no território, castelo ou cartão de uma região para selecioná-la. A borda fica dourada e o painel de dados e ordens acompanha a seleção.
- O seletor tradicional de regiões continua disponível e também atualiza o mapa.
- Com o mapa em foco, as setas percorrem as regiões.
- Passe o cursor sobre um território para ver alimentos, consumo, lealdade e agitação.
- A aba **Crônica** contém a mesma história que já existia. Avançar o mês enquanto lê a crônica também atualiza o mapa.

## Elementos visuais

Território contínuo desenhado com losangos em perspectiva isométrica. O Vale possui plantações e bosques; a Marca tem relevo montanhoso; a Costa possui porto e uma embarcação. Essas vocações visuais não limitam a produção diversificada de recursos da simulação.

Cada região tem castelo, bandeira própria, vilas e cartão com seus valores atuais. As estradas e o porto representam a geografia inicial: ainda não calculam rotas, bloqueios ou distância. Bandeiras identificam a região; não há troca de controle territorial implementada nesta versão.

| Sinal | Dado da partida |
| --- | --- |
| Borda e cartão dourados | Região selecionada |
| Círculo com ! no cartão | Pedido diplomático aberto |
| Alimentos em cor de alerta e solo mais seco | Estoque menor que consumo mensal |
| Plantações claras no Vale | Geada durante os dois primeiros meses |
| ! nas vilas | Agitação regional ≥40 |
| Acampamento de mobilização | Recrutamento confirmado naquela região durante o mês atual |

O mapa lê apenas os valores necessários e cria uma cópia de apresentação. Selecionar e explorar não consomem ordens, não geram acontecimentos e não alteram recursos. Ao iniciar, carregar ou avançar a partida, a vista recebe dados novos. O formato de salvamento permanece inalterado.

## Limites desta entrega

Arte geométrica original, desenhada pelo próprio jogo. Sem imagens externas, geração de arte por IA ou dependências novas. O desenho se adapta à área disponível; não há zoom ou arrasto nesta versão. Sem construção livre, animação de unidades, batalhas ou gerenciamento de navios. Esses elementos poderão ser desenvolvidos em etapas futuras.

## Verificação

`tests/test_map.gd` verifica cliques em castelos e cartões em três tamanhos, mar e pontos externos, seleção por teclado, sincronização com o seletor e as ordens, indicadores reais, novo reinado, isolamento da economia e atualização enquanto a crônica está aberta. São 45 verificações, além das demais suítes do jogo.
