# Coroa Quebrada — diretrizes do projeto

Registro inicial: 1 de novembro de 2026.

Este documento reúne as decisões da conversa inicial. É a referência para desenvolver o jogo por etapas. Sugestões ainda não confirmadas estão identificadas como propostas. Mudanças futuras devem atualizar este documento.

## 1. Visão e objetivo

Jogo individual de estratégia política e narrativa, ambientado em um mundo medieval de fantasia original. O jogador assume o papel do rei de um reino unificado, mas próximo da divisão, e tenta preservar seu poder por alianças, negociações, administração e estratégia de guerra.

A experiência central é a causa e consequência: decisões alteram recursos, relações, instituições e acontecimentos futuros. Uma decisão pode resolver uma crise imediatamente e provocar outra meses depois. O reino deve lembrar do que aconteceu.

Game of Thrones é referência de intriga e disputa de poder. Age of Empires II é referência de leitura visual e perspectiva isométrica. O mundo, personagens, mapa e arte serão próprios.

O projeto começa para uso pessoal, com eventual distribuição futura. Priorizar ferramentas gratuitas, execução local e o menor custo recorrente possível. O usuário não tem experiência prévia criando jogos; explicar as decisões em linguagem acessível.

## 2. Estrutura do reino

Hierarquia inicial: rei → senhores regionais → vassalos locais → camponeses e trabalhadores. Outros cargos e instituições poderão ser acrescentados depois.

A hierarquia não determina automaticamente as lealdades. Um vassalo pode apoiar a Coroa contra seu senhor. A população pode gostar do rei e rejeitar a autoridade local. Senhores leais ao rei podem disputar terras entre si.

Cada personagem importante deve ter interesses e relações que orientem suas reações. Evitar personagens que existem apenas para concordar com o jogador.

Os recursos dos senhores não pertencem automaticamente ao rei. A Coroa possui tesouro e reservas próprios. Tributos, compras, acordos, requisições e confiscos têm efeitos econômicos e políticos distintos.

## 3. Economia regional

Decisão expressa do usuário: cada região pode produzir vários ou todos os recursos, em quantidades diferentes. Algumas podem não produzir determinado recurso por sua localização, mas podem obtê-lo e acumulá-lo por comércio.

Não usar uma divisão rígida em que cada região produz exclusivamente um recurso.

Separar produção, estoque e consumo. Uma região sem minas pode possuir reservas de ferro; uma região agrícola pode sofrer escassez depois de uma colheita ruim ou recrutamento excessivo.

Base proposta para o protótipo:

| Recurso | Função |
| --- | --- |
| Alimentos | Sustento da população e dos exércitos |
| Madeira | Construções, reparos e equipamentos |
| Ferro | Armas, ferramentas e fortificações |
| Ouro | Meio de pagamento de comércio, tributos, salários e acordos |

O ouro circula sobretudo por comércio e tributos; mineração pode existir onde fizer sentido. Uma transferência entre regiões deve descontar do remetente e creditar ao destinatário, respeitando o prazo da entrega.

Comércio inicial: compras, trocas e tributos simples. Escassez e relações políticas afetam as condições dos acordos. Distâncias, estradas e bloqueios podem afetar custo e prazo. Evitar simular um mercado excessivamente complexo na primeira versão.

## 4. Turnos mensais

Cada turno corresponde a um mês:

1. O conselho apresenta recursos, notícias, pedidos e rumores.
2. O jogador investiga e negocia, recebendo informações possivelmente incompletas.
3. O jogador escolhe opções ou escreve ordens livres.
4. O jogo apresenta a interpretação, os custos conhecidos e os prazos das ordens.
5. O mês avança: produção, consumo, ações e reações são resolvidos.
6. Consequências pendentes podem ser ativadas; a crônica registra o resultado.

Planejar um acontecimento principal por mês e desdobramentos menores. Acontecimentos podem ser favoráveis ou desfavoráveis e devem responder ao estado da partida. Nem todo mês precisa inventar uma crise independente.

Dinheiro, recursos, tempo e capacidade administrativa limitam as ações. Escrever muitas ordens em uma mensagem não elimina esses limites.

## 5. Papel da IA

A IA interpreta intenções escritas pelo jogador, propõe ações estruturadas e produz narrativa contextual. As regras do jogo validam e executam as alterações de estado.

Exemplo: “Envie comida ao norte, suspenda os impostos por três meses e exija o filho do senhor como garantia de lealdade.” A interpretação deve separar envio, política tributária temporária e exigência diplomática. Uma exigência não significa que o outro personagem aceitou.

Verificar disponibilidade, custos, prazo, autoridade e reação dos envolvidos. Ordens ambíguas devem gerar esclarecimento ou contraproposta; ordens impossíveis não podem ser tratadas como executadas.

Não deixar saldos, mortes, territórios, pactos ou resultados militares dependerem apenas de texto gerado. A narrativa deve refletir o resultado validado. A IA não pode criar recursos ou apagar consequências por conveniência.

Liberdade de expressão será ampla, mas a primeira versão terá um conjunto limitado de ações executáveis. Expandir esse conjunto por etapas.

## 6. Memória, lore e coerência

Manter três registros complementares:

- Estado atual: personagens, autoridades, recursos, relações, territórios, guerras e acordos.
- Histórico permanente: eventos e decisões datados, com participantes e efeitos.
- Consequências pendentes: promessas, dívidas, ressentimentos, projetos, prazos e possíveis conspirações.

A cada turno, fornecer à IA o estado necessário e os trechos relevantes do histórico. Guardar toda a história não significa reenviar a partida inteira em toda chamada.

Distinguir fatos do mundo, crenças dos personagens e informações conhecidas pelo rei. Um rumor não se torna fato apenas por aparecer na narrativa.

Consequências devem ter origem identificável e depender das circunstâncias. Nem todo ressentimento resulta obrigatoriamente em traição. O jogador deve poder reparar danos ou piorar uma situação.

Exemplo de cadeia: ajuda real distribuída sem consultar o senhor local → fome reduzida e popularidade maior → senhor perde autoridade e dificulta tributos → outros nobres pedem garantias → população beneficiada pode apoiar a Coroa em uma crise futura.

## 7. Visual e guerra

Refinamento geográfico solicitado: evitar formato regular e regiões organizadas em grade. Conceito v4 (`outputs/ConceitoVisual-v4.png`) apresenta reino costeiro ligado a um continente, fronteiras terrestres, territórios assimétricos, baías e penínsulas. As Terras da Coroa foram propostas junto ao litoral, fora do centro. Mantém nove regiões e vista local isométrica. Geografia conceitual ainda sujeita à avaliação; não implementada.

Direção mais recente aprovada pelo usuário: ampliar o reino para nove regiões, acrescentando Bosques de Âmbar, Campos do Alazão, Pântanos de Salgueiro e Fronteira das Cinzas às cinco originais. Usar mapa geral visto de cima, com fronteiras contínuas, cores territoriais e nomes legíveis; abrir uma vista isométrica da região para explorar domínios de vassalos. Carregar detalhes por região é a direção de implementação, sem promessa de ganho de desempenho antes de medir. A produção continua diversificada em todas as regiões. Conceito v3 salvo em `outputs/ConceitoVisual-v3.png`, prompt em `outputs/ConceitoVisual-v3-prompt.txt`. Os nomes secundários de capitais e lugares sugeridos pela imagem são provisórios, não lore definida. A simulação publicada continua com três regiões; expansão e navegação ainda não implementadas. Esta decisão substitui o limite visual anterior de cinco regiões.

Revisão de direção visual: o usuário aprovou o estilo ilustrado, mas pediu escala maior e todas as cinco regiões previstas. A navegação deverá permitir zoom e arrasto, passando da visão do reino aos domínios dos vassalos de cada senhor. Terreno ilustrado com elementos interativos separados é a direção aceita. O conceito v2 em `outputs/ConceitoVisual-v2.png` mostra as cinco regiões e uma vista local do domínio de Tomás do Moinho; o nome “Domínio do Moinho” é proposta artística. A quantidade e os nomes dos demais domínios ainda serão definidos. Esta imagem demonstra a intenção visual; não é uma implementação de zoom nem amplia por si só as três regiões da simulação publicada.

Direção visual: mapa estratégico isométrico com construções simples, castelos, vilas, estradas, plantações e marcadores de exércitos.

O mapa deve refletir a partida com variações de arte preparadas: bandeiras, danos, acampamentos, plantações e construções. Não é necessário gerar um mapa novo por IA a cada mês.

Primeiro escopo sem batalhas em tempo real, milhares de unidades individuais ou construção livre. Campanhas militares mensais podem considerar abastecimento, terreno, comandantes, moral e tropas fornecidas pelos vassalos.

## 8. Mundo inicial: propostas a detalhar

Premissa aceita como direção: o novo rei herda uma união frágil, sustentada por compromissos antigos, dívidas e promessas conflitantes. A morte do predecessor abre espaço para renegociação e disputa de autoridade.

Nomes e detalhes abaixo são propostas, não uma lore final:

| Região | Vocação predominante, sem exclusividade |
| --- | --- |
| Terras da Coroa | Capital, administração e prestígio |
| Vale do Trigo | Agricultura e população |
| Marca de Ferro | Minas e fortalezas |
| Costa das Marés | Portos, comércio e frota |
| Altos do Véu | Santuários e conhecimento arcano |

Usar apenas três regiões no protótipo; escolher quais na etapa de definição. “A Coroa Partida” foi um título sugerido na conversa. A pasta atual se chama “Coroa Quebrada”; este documento usa esse nome de trabalho, sem presumir título definitivo.

A fantasia deve influenciar legitimidade, instituições e disputas. Sua intensidade, regras e limites ainda serão definidos.

## 9. Escopo do primeiro protótipo

- Um rei, três regiões e seis personagens importantes.
- Doze turnos mensais.
- Alimentos, madeira, ferro e ouro; tropas, legitimidade e relações políticas.
- Produção, consumo e estoques regionais e reservas próprias da Coroa.
- Tributos, ajuda alimentar, negociação, comércio, recrutamento e campanhas simples, implementados gradualmente.
- Ordens por texto com interpretação por IA, integradas após uma base de regras funcional.
- Consequências imediatas e adiadas, crônica e salvamento local.
- Mapa simples, com mudanças visuais acrescentadas depois do núcleo jogável.

Cenário inicial proposto: uma colheita ruim coincide com a necessidade de reunir tropas. O rei precisa negociar abastecimento e apoio sem romper alianças.

Critério central: uma decisão do primeiro mês deve poder voltar no décimo de maneira coerente, reconhecível e relevante para o jogador.

O horizonte de cinco anos mencionado na ideia inicial é uma possibilidade para uma versão posterior. O protótipo cobre doze meses.

## 10. Tecnologia, custos e distribuição

Direção inicial: Godot para um jogo instalável, primeiro em Windows, com arte 2D e dados salvos localmente. A escolha deve ser confirmada ao preparar o ambiente.

Avaliar IA local via Ollama conforme o hardware disponível. Ainda não foi escolhido um modelo para rodar dentro do jogo nem verificada a capacidade do computador. IA local evita cobrança por chamada externa, mas consome memória, armazenamento, processamento e energia. Verificar também a licença do modelo escolhido.

Integração com serviço pago é alternativa futura, com controle de gastos. Não depender de planos gratuitos online permanentes. Manter a lógica central testável sem uma conexão de IA ativa.

Versionar o desenvolvimento no GitHub. Repositório fornecido pelo usuário: https://github.com/coutocdouglas/CoroaQuebrada.git. O usuário autorizou o envio das versões ao longo do desenvolvimento. A pasta local está vinculada a esse endereço e a autenticação pelo Git Credential Manager foi concluída. Distribuir executáveis em Releases, mantendo ferramentas e builds fora do código-fonte versionado.

Atualização dentro do jogo é objetivo posterior: verificar versão, baixar pacote, validar o conteúdo e aplicar com um atualizador, preservando os saves. Pode exigir reiniciar o jogo, mas deve evitar reinstalação manual a cada versão. Prever versionamento e migração dos arquivos de partida.

Referências consultadas na conversa:

- Godot: https://docs.godotengine.org/en/stable/about/faq.html
- Ollama: https://docs.ollama.com/faq
- GitHub Releases: https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases

## 11. Etapas e tipo de raciocínio

Trabalhar por etapas com entregas verificáveis. Não iniciar o jogo completo de uma vez.

| Etapa | Entrega | Raciocínio recomendado |
| --- | --- | --- |
| 1. Definição | Três regiões, personagens, regras econômicas e cenário inicial | Alto; foco em projeto de sistemas |
| 2. Núcleo da simulação | Turnos, recursos, acordos, consequências e salvamento | Alto; foco em programação e consistência |
| 3. Primeira partida | Doze meses jogáveis com interface simples | Alto na integração; médio em ajustes pontuais |
| 4. IA e memória | Interpretação de ordens e narrativa ligada aos fatos | Alto; elevar em problemas difíceis de coerência |
| 5. Mapa e apresentação | Mapa isométrico e feedback visual do reino | Médio ou alto conforme a complexidade |
| 6. Validação | Partidas completas, equilíbrio e correção de falhas | Alto para revisão de sistemas; médio para ajustes simples |
| 7. Distribuição | Versão instalável, GitHub e depois atualizador | Alto nas decisões de atualização e compatibilidade |

As etapas são orientação de trabalho, não estimativa de prazo. Ajustar o escopo com base nas partidas e registrar decisões novas aqui.

## 12. Escolha de modelo e preferência do usuário

Separar sempre o modelo usado nesta conversa para desenvolver o projeto do modelo incorporado ao jogo.

Recomendação registrada em 1 de novembro de 2026: GPT-6.1 Sol com raciocínio Alto como padrão de desenvolvimento. GPT-6 Astra pode ser avaliado, se disponível, para arquitetura, revisão complexa e erros difíceis. Raciocínio Médio pode bastar para pequenas alterações. Disponibilidade, nomes e condições de uso devem ser conferidos antes de novas recomendações.

Preferência expressa do usuário: avisar ANTES de uma troca de modelo recomendada. Explicar qual etapa começou, o modelo e nível sugeridos, o benefício esperado e o possível impacto no uso disponível. Não afirmar que o modelo foi trocado sem confirmação da interface ou do usuário. A escolha é feita pelo usuário na interface quando necessário.

Não recomendar troca a cada tarefa pequena. Primeiro avaliar se o modelo atual atende. Priorizar economia e evitar contratação adicional sem necessidade demonstrada.

Referências sobre modelos consultadas na conversa:

- https://learn.chatgpt.com/docs/models
- https://help.openai.com/en/articles/20001516-managing-usage-with-gpt-6-astra-in-work-and-codex

## 13. Situação ao encerrar este registro

Primeira base jogável 0.1.0 implementada em Godot 4.7.2: Conselho Real, três regiões, seis nobres apresentados, doze meses, duas ordens por mês, cinco ações, economia regional, crise de fronteira, consequências adiadas com origem, crônica e salvamento local. Regras provisórias detalhadas em `docs/REGRAS_V0_1.md`.

Testes locais cobrem economia, transferências, limites, reconciliação, lembrança da ajuda no mês 10, salvamento e campanhas completas. A interface foi renderizada e inspecionada; há um executável Windows para teste local.

Ao encerrar a versão 0.1, ainda faltavam IA e texto livre, atuação autônoma dos vassalos, mapa isométrico, campanhas militares completas e atualizador. A versão seguinte detalhada abaixo avança a negociação e a atuação dos personagens.

Atualização da etapa seguinte: versão 0.2.0 implementa interesses dos senhores, pedidos com prazo, trocas e contrapartidas, comércio autônomo entre regiões, apoio separado dos vassalos e mediação de crises por eles. Acrescenta a ordem de audiência ao vassalo e migração dos saves da 0.1. Regras detalhadas em `docs/REGRAS_V0_2.md`. Os pedidos ainda têm três tipos fixos e não há IA generativa. O mapa isométrico, guerras completas e atualizador continuam pendentes. Validação desta etapa: 173 verificações automatizadas.

Código-fonte enviado à branch `main`. Primeira versão de teste Windows publicada em https://github.com/coutocdouglas/CoroaQuebrada/releases/tag/v0.1.0, com o pacote `CoroaQuebrada-v0.1.0-Windows.zip`. Validação local: 93 verificações da simulação e 8 da interface sem falhas, além da inicialização do executável exportado.

A integração GitHub conectada permite consultar o repositório, mas retornou erro 403 ao tentar gravar. O envio foi realizado pelo Git autenticado com o Git Credential Manager, sem expor credenciais. Use esse caminho nas próximas publicações quando disponível.

Mudança de prioridade solicitada pelo usuário: antecipar o instalador e o recebimento de atualizações dentro do jogo. Versão 0.3.0 implementa instalador Windows por usuário, atalhos, desinstalador e atualização pelo painel do aplicativo. A consulta usa as releases públicas do repositório, incluindo protótipos. Download e reinício exigem clique do jogador; antes de reiniciar, a partida é salva. A aplicação usa pacote com tamanho e hash verificados, backup e tentativa de restauração em caso de falha. Saves permanecem na pasta original de dados. A próxima versão deve manter o contrato documentado em `docs/ATUALIZACOES.md` para continuar atualizando sem reinstalação manual.

Validação da distribuição 0.3: 208 verificações da rotina principal e 11 de instalação isolada, aplicação do pacote real, reinicialização e desinstalação. O instalador inicial deve ser executado uma vez por quem usa as versões 0.1 ou 0.2; as versões posteriores são oferecidas no próprio programa.

Próxima prioridade aprovada: antecipar o mapa antes da IA. Versão 0.4.0 acrescenta mapa isométrico selecionável das três regiões, construções e estradas, painel de decisões sincronizado, indicadores da partida e crônica em outra aba. A arte inicial é geométrica e original. O mapa é somente uma vista: não altera a economia, as regiões produtoras ou os prazos de entrega. Detalhes em `docs/MAPA.md`. Mantém saves e atualização compatíveis com 0.3. A rotina principal passa a 253 verificações, além das 11 da instalação isolada.

Etapa seguinte planejada: integração com Gemini para ordens por texto, com Flash Lite para interpretação e tarefas simples e Flash para conversas e narrativa mais complexas. Os identificadores exatos dos modelos e a disponibilidade gratuita serão conferidos na configuração; o usuário já usa essa combinação em outro jogo. Chaves devem ser configuradas localmente, sem inclusão no código, saves de partida ou GitHub. A integração ainda não está implementada na 0.4.

Antes da implementação do mapa, foi indicada a configuração GPT-6.1 Sol com raciocínio Alto para desenvolver o projeto. O usuário pediu indicação de modelo antes de cada etapa, mesmo quando não houver recomendação de troca.

Revisão após a 0.4: o usuário rejeitou a qualidade visual do mapa. Foi acordado pausar a integração de IA e criar uma imagem de referência da tela antes de implementar a reformulação. Primeiro conceito gerado com ImageGen integrado, disponível localmente em `outputs/ConceitoVisual-v1.png`, com o prompt em `outputs/ConceitoVisual-v1-prompt.txt`. A proposta usa terreno orgânico, edifícios detalhados em perspectiva isométrica, mapa ocupando a maior parte da tela, barra de recursos compacta e painel contextual à direita. É uma direção artística para avaliação; ainda não foi aprovada nem implementada. O jogo publicado permanece na 0.4.

## 14. Direção atual do mundo — 2 de novembro de 2026

Decisão do usuário: expandir o reino para 12 regiões na história e usar o Azgaar Fantasy Map Generator como ferramenta de criação da geografia. Esta decisão substitui os totais anteriores de cinco ou nove regiões no mundo planejado. A versão publicada continua com três regiões; a ampliação ainda precisa ser implementada e ter a compatibilidade dos saves planejada.

Visão geral de topo, com camadas selecionáveis para política, comércio, reservas e situação militar. Reservas, produção e consumo devem ser distintos. Rotas precisam indicar origem, destino e mercadorias, e futuramente prazo, risco e bloqueios conforme regras implementadas. Vista isométrica ao explorar regiões e domínios de vassalos.

Usar o Azgaar na criação do mundo e avaliar uma exportação de dados antes de definir o importador. O jogo deverá funcionar com os dados locais preparados, sem depender de acessar o site durante a partida. Verificar os termos de reutilização e atribuições dos elementos efetivamente aproveitados durante essa avaliação. Preservar a geografia ao aplicar o estilo visual; imagens geradas não devem redefinir fronteiras, rios ou conexões aprovadas.

Nove regiões já propostas: Terras da Coroa, Vale do Trigo, Marca de Ferro, Costa das Marés, Altos do Véu, Bosques de Âmbar, Campos do Alazão, Pântanos de Salgueiro e Fronteira das Cinzas.

Três nomes adicionais propostos, ainda sujeitos a revisão do usuário:

- Ilhas do Farol: arquipélago, pilotagem marítima e influência sobre a entrada da grande baía; dependência de abastecimento continental pode alimentar disputas.
- Passos da Vigília: vales e passagens de montanha, fortalezas e cobrança de pedágios sobre as conexões entre interior e litoral.
- Baixadas de Prata: colinas e bacias fluviais com cidades mercantis e algumas minas de prata; credores locais podem financiar a Coroa em troca de concessões.

Essas identidades não tornam a produção exclusiva. Todas as regiões podem produzir diversos recursos em quantidades diferentes e acumular outros por comércio. Prata é uma característica de ambientação, não um novo recurso jogável aprovado. Número de vassalos, casas governantes, limites, posições e relações serão definidos na preparação do mapa; não ficam estabelecidos por esses nomes.
Preparação Azgaar implementada: catálogo de 12 regiões e importador Node.js para JSON Full, com validação de territórios, geometria, povoações e rotas. Documentação em docs/AZGAAR.md. Doze testes sintéticos passaram, além dos 240 testes Godot existentes. Ainda não foi importado um mapa Full real nem conectada esta estrutura à interface; o jogo publicado permanece 0.4.0. Próxima necessidade: produzir o mapa fonte com as 12 províncias e validar sua exportação completa.
