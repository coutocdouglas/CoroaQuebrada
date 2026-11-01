# Regras do protótipo 0.1

Estas são escolhas iniciais de implementação para teste, abertas à revisão pelo usuário. O objetivo é validar coerência antes de ampliar o mundo.

## Territórios e personagens

| Região | Senhor | Vassalo | Alimentos/mês | Madeira/mês | Ferro/mês | Consumo de alimentos |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| Vale do Trigo | Helena Verdan | Tomás do Moinho | 38 | 9 | 0 | 30 |
| Marca de Ferro | Artur Ferren | Brina da Ponte | 16 | 12 | 18 | 24 |
| Costa das Marés | Maíra Salmar | Caio das Docas | 24 | 16 | 4 | 22 |

O Vale começa com ferro em estoque apesar de não produzi-lo: produção e acumulação são distintas. Nos meses 1 e 2, a geada reduz a produção alimentar do Vale para 12. Os nomes são provisórios. Vassalos são apresentados, mas sua autonomia será implementada depois.

## Economia e tempo

As ordens são executadas durante o mês, com custos imediatos e até duas confirmações. Encerrar o mês resolve produção e consumo regionais, rendas, tributos e manutenção real. Em seguida, o calendário avança e entregas e reações vencidas são aplicadas. A ajuda que chega no início de um mês só estará disponível para o consumo desse novo mês.

Cada região gera 8 ouro/mês de arrecadação econômica abstrata e transfere 4 à Coroa se sua lealdade for pelo menos 35. A Coroa gera 6 de renda própria. Essas rendas são fontes explícitas de moeda; compras e pactos são transferências, não fontes de ouro.

A Coroa consome `8 + arredondamento para cima(soldados / 10)` alimentos/mês. Falta de alimento causa perda de 8 de legitimidade e deserção de até 5 soldados. Falta de alimento regional causa +12 agitação, −5 lealdade e −3 legitimidade. Sem fome, a agitação cai 1 por mês.

## Ordens

| Ordem | Custo / transferência | Resultado |
| --- | --- | --- |
| Auxílio | 25 alimentos da Coroa | Entrega no próximo mês; +6 lealdade e −5 agitação; lembrança oito meses após a entrega |
| Compra | 30 alimentos regionais por ouro real | Preço responde à escassez e lealdade; senhor aceita com lealdade ≥30 e estoque ≥30; entrega no próximo mês |
| Tributo extraordinário | 20 ouro do senhor para a Coroa | −10 lealdade; se ficar abaixo de 45, resistência é agendada para dois meses depois |
| Acordo de autonomia | 20 ouro da Coroa para o senhor | +10 lealdade; em dois meses os outros senhores perdem 3 de lealdade pelo precedente |
| Recrutamento | 15 ouro e 10 ferro reais consumidos na mobilização | +10 soldados, −4 lealdade; produção regional de alimentos −6 no mês, sem acumular a penalidade por recrutamentos repetidos |

Preço de 30 alimentos: `24 + piso(max(0, 60 − estoque) / 3) + piso(max(0, 60 − lealdade) / 5)` ouro.

A resistência tributária é reavaliada no vencimento. Se a lealdade ainda estiver abaixo de 45, resulta em +10 agitação e −4 legitimidade. Melhorar a relação antes disso evita essa punição e a crônica registra a reconciliação.

A lembrança da ajuda retorna oito meses após a entrega: +4 legitimidade se a agitação local estiver abaixo de 60. Caso contrário, a crise atual impede o benefício. Ajuda no mês 1 chega no 2 e é lembrada no 10. Cada efeito referencia o número da ordem que lhe deu origem.

## Fronteira e final

Na abertura do mês 6, 30 soldados bastam para conter um ataque: +5 legitimidade. Sem eles, a Coroa perde até 25 ouro e 8 de legitimidade. É um evento introdutório fixo, não um sistema de guerra completo.

A partida termina ao resolver 12 meses ou quando a legitimidade chega a zero. A crônica pode conter eventos na abertura do mês 13: são o fechamento das consequências do último turno, sem novo mês jogável. Consequências além desse horizonte continuam no save, mas ainda não há campanha posterior para executá-las.

Os finais avaliam legitimidade e quantos senhores têm lealdade ≥45. Lealdade e agitação variam de 0 a 100. Não há aleatoriedade nesta primeira versão, facilitando conferir as cadeias de causa e consequência.
