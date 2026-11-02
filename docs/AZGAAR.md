# Integração geográfica com Azgaar

## Entrega desta etapa

Catálogo de 12 regiões em `data/world/catalog.json` e ferramenta local `tools/import-azgaar.mjs`, sem dependências externas além de Node.js 22 ou posterior. Não altera saves nem a economia da versão 0.4. A ferramenta prepara JSON geográfico para a futura vista de topo; ainda não está conectada à interface Godot.

## Preparação do mapa

1. No Azgaar, criar uma massa continental com reino costeiro, baía, ilhas e fronteiras terrestres. Evitar uma ilha quadrada ou distribuição em grade.
2. Usar um estado para o reino e 12 províncias internas. Estados vizinhos podem existir. Renomear as províncias exatamente como no catálogo. A capital real deve ficar no litoral.
3. Conferir o identificador do estado e preencher `source_state_id` no catálogo. O valor 1 é apenas configuração inicial, não identificação garantida de um mapa ainda não escolhido.
4. Ajustar capitais, povoações e rotas. Guardar o arquivo `.map` como fonte editável.
5. Em Export, escolher JSON Full. Minimal e GridCells não servem para este importador: não contêm a mesma geometria completa.
6. Executar: `node tools/import-azgaar.mjs caminho/Full.json data/world/catalog.json outputs/mundo-importado.json`.

O destino deve ser novo: a ferramenta recusa sobrescrever uma versão anterior.

## Contrato e limites

Preserva polígonos por célula, vizinhança regional, relevo, bioma, população bruta, povoações e traçados de rotas que tocam o reino. Mantém rios, culturas e religiões da fonte como dados auxiliares, ainda sem processamento próprio. Coordenadas são as coordenadas de desenho do JSON Full; não misturar com longitude/latitude de GeoJSON.

População bruta não equivale a habitantes finais: é necessário aplicar os parâmetros de escala do gerador antes de equilibrar consumo, tributos e recrutamento. Uma província é uma região de senhor; povoações não são automaticamente vassalos. Os domínios precisam de subdivisão própria posterior, com limites, governantes e vínculos.

Rotas importadas são caminhos geográficos, não vendas em execução. Podem cruzar terras estrangeiras. Custo, distância calibrada, tempo de transporte, bloqueios e estoques serão calculados pela simulação em etapa posterior. A importação não cria recursos, lealdades ou eventos.

Ainda falta selecionar/produzir o mapa definitivo de 12 províncias, testar a exportação real completa, verificar sua conectividade, desenhar a vista navegável e planejar a migração da simulação de três regiões. Não há release instalável nova nesta entrega de preparação.

## Verificação

`node --test tests/test_azgaar.mjs`: 12 cenários, com dados sintéticos pequenos seguindo o contrato oficial. Foi consultado o código `src/services/io/export-json.ts` do projeto Azgaar e baixado seu exemplo oficial `tests/fixtures/1.154.0.map` para inspeção local. O `.map` usa um formato diferente e NÃO foi convertido nem contado como uma importação Full bem-sucedida. Nenhuma geografia sintética é apresentada como um mapa real do gerador.

## Referências e licença

- https://github.com/Azgaar/Fantasy-Map-Generator/blob/master/src/services/io/export-json.ts
- https://github.com/Azgaar/Fantasy-Map-Generator/wiki/GIS-data-export
- https://github.com/Azgaar/Fantasy-Map-Generator/blob/master/LICENSE

A licença oficial é MIT e autoriza expressamente mapas e derivados, inclusive comerciais. Este adaptador foi escrito para Coroa Quebrada com base na estrutura documentada; não incorpora o gerador nem seus elementos gráficos. Registrar a fonte e os avisos aplicáveis quando o mapa final e qualquer arte externa forem incorporados. Exportação JSON não produz uma cena isométrica: essa apresentação será construída separadamente.
