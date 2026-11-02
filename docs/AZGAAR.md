# Atlas do reino — versão 0.5

O jogo agora abre um atlas de topo com as 12 regiões. A geografia foi gerada no Azgaar 1.156.0 (semente 20261102, modelo peninsula, 1600 × 1000) e adaptada dentro da sessão do gerador. A fonte editável foi reaberta no Azgaar e conferida: 12 províncias ativas e capital em Porto da Coroa.

## Navegação

- Clique em um território ou na lista para selecioná-lo.
- Use a roda do mouse ou os botões − e + para aproximar; arraste para mover.
- Reenquadrar ou Home restaura a vista inicial. O limite é 6×.
- Territórios: fronteiras, sedes e identificação numérica ligada à lista; nomes aparecem ao aproximar ou selecionar.
- Caminhos terrestres e marítimos: destaca os trajetos que tocam a região selecionada. Dourado indica terra, azul indica mar. São caminhos geográficos; não representam remessas ativas.
- Reservas conhecidas: mostra cobertura alimentar calculada a partir de estoque e consumo reais. Regiões sem simulação ficam cinza, sem valores inventados.
- Governar esta região abre o conselho para Vale, Marca ou Costa. Voltar ao conselho mantém a região previamente selecionada. O botão Atlas do reino permite retornar.

## Dados e limites

São 12 regiões, 68 povoações e 62 caminhos importados que tocam o reino. Os 227 rios desenhados pertencem ao mapa completo, incluindo terras externas. A capital real fica em um porto. Todas as regiões são alcançáveis no grafo combinado de fronteiras terrestres e caminhos gerados, incluindo ligação marítima das Ilhas do Farol.

Esta entrega acrescenta navegação e contexto geográfico. A simulação econômica continua com três regiões. A extensão da economia para 12 regiões, os governantes adicionais, domínios de vassalos, remessas com prazo/bloqueio e cenas isométricas detalhadas ainda precisam de implementação. Saves e o contrato do atualizador permanecem compatíveis.

## Fontes reproduzíveis

- `data/world/source/azgaar-full.json`: exportação Full real pelo botão oficial do gerador.
- `data/world/source/coroa-quebrada.map.gz`: fonte editável, descompactável para `.map` e carregável no Azgaar. É um arquivo de autoria do mundo, não um save de partida.
- `data/world/catalog.json`: identificadores estáveis das 12 regiões.
- `tools/import-azgaar.mjs`: valida e adapta Full JSON.
- `tools/prepare-atlas.mjs`: gera `kingdom.json` e `atlas.json`; executar com Node 22 ou posterior a partir da raiz do projeto.
- `atlas.json` contém a geometria preparada, capitais, vizinhança, caminhos e hash da fonte. Apenas esse arquivo geográfico entra no executável.

Adaptação territorial: províncias originais 3→1, 14→2, 15→13 e 16→6; as 12 restantes receberam os nomes do catálogo. A ilha principal de Farol foi reunida na província 13 e seu porto incluído no reino. A capital passou ao povoado 94, Porto da Coroa. As divisões seguem a geometria gerada; os nomes restantes de povoações são provisórios. A correspondência visual entre terreno e vocações regionais ainda poderá ser refinada durante o equilíbrio do mundo.

## Validação

15 testes Node cobrem contrato, entradas inválidas, importação real, hash da fonte, capitais e conectividade. O novo teste Godot cobre 48 verificações de seleção em três tamanhos, zoom, reenquadramento, reservas, isolamento do estado e retorno ao conselho. O executável exportado deve confirmar `ATLAS_EXPORT_OK`, garantindo a presença dos dados no pacote.

## Licença

Azgaar é distribuído sob MIT, com autorização expressa para mapas e derivados. O aviso completo está em `THIRD_PARTY_NOTICES.md` e `data/world/source/AZGAAR-LICENSE.txt`.

Referências: https://github.com/Azgaar/Fantasy-Map-Generator/wiki/GIS-data-export e https://github.com/Azgaar/Fantasy-Map-Generator/blob/master/src/services/io/export-json.ts .
