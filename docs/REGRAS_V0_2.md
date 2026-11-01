# Regras adicionais da versão 0.2

As regras econômicas de [0.1](REGRAS_V0_1.md) continuam válidas, com as seguintes adições provisórias.

## Pedidos diplomáticos

No início, cada senhor apresenta um pedido. O jogador dispõe do mês de abertura e do seguinte para responder. A expiração ocorre na abertura do terceiro mês. Cada resposta usa uma ordem; consultar e adiar não usam ordens. Recusa reduz a lealdade em 5; silêncio até a expiração reduz em 3, uma única vez.

| Região | Interesse | Pedido e resultado |
| --- | --- | --- |
| Vale do Trigo | Colheitas e população | 20 alimentos reais às aldeias; +7 lealdade e +3 apoio do vassalo na entrega. Pode gerar a lembrança de auxílio oito meses depois. |
| Marca de Ferro | Autonomia e abastecimento | 20 alimentos reais por 12 ferro regional; +7 lealdade na entrega. |
| Costa das Marés | Comércio e influência | 15 ouro reais por 10 madeira regional e uma carta comercial; +7 lealdade local e −2 dos outros senhores na entrega. |

Ouro da carta é transferido imediatamente ao senhor. Recursos físicos são retirados dos estoques ao firmar o acordo e ficam em trânsito até o próximo mês. Custos e contrapartidas são revalidados na confirmação; falta de recursos recusa a operação inteira, sem efeitos parciais. Um pedido só pode ser respondido uma vez.

Novo pedido da mesma região só pode surgir a partir de quatro meses após a abertura anterior, sem outro pedido aberto. Nesta versão, os três tipos se repetem: o sistema ainda não gera missões inéditas.

## Senhores independentes

Da abertura do mês 3 em diante, uma região com alimentos abaixo do consumo mensal e pelo menos 12 ouro pode comprar 15 alimentos por 12 ouro de outro senhor. O vendedor só aceita se, após a venda, conservar pelo menos dois meses de consumo em estoque. Há no máximo uma rota negociada por mês, na ordem Vale → Marca → Costa. A carga chega na abertura do próximo mês. Não há risco de viagem ou simulação de distância nesta etapa.

O comércio não usa recursos da Coroa nem ordens reais. O histórico informa origem, destino e entrega. A moeda da compra é transferida, não criada.

## Vassalos

Apoio inicial à Coroa: Tomás 60, Brina 45, Caio 55. É um indicador distinto da lealdade do senhor.

**Ouvir o vassalo:** transfere 10 ouro reais às reservas regionais, concede +10 de apoio ao vassalo e reduz a lealdade do senhor em 3. Usa uma ordem.

Na abertura do mês, um vassalo com apoio ≥55 e agitação regional ≥25 pode gastar 8 ouro regionais para reduzir a agitação em 6. A primeira ação pode ocorrer assim que as condições forem satisfeitas; as seguintes respeitam intervalo de três meses. Isso representa organização e mediação, não criação de alimentos. Ações são registradas na crônica.

## Salvamento e encerramento

Formato do save: 2. Inclui apoio, intervalos de ação, pedidos respondidos e cargas dos acordos. Saves da 0.1 são migrados em memória; a migração não inventa pedidos retroativos nem altera o histórico antigo. Novos pedidos passam a surgir no próximo avanço de mês. O arquivo só muda ao salvar; saves gravados pela 0.2 não abrem na 0.1.

O horizonte continua sendo doze meses. Na abertura do mês 13, entregas e expirações vencidas são resolvidas, mas novos pedidos, comércios e ações de vassalos não são iniciados. Compromissos posteriores permanecem no save, sem campanha estendida nesta etapa.
