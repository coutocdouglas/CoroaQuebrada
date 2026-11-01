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

Versionar o desenvolvimento no GitHub. Repositório fornecido pelo usuário: https://github.com/coutocdouglas/CoroaQuebrada.git. O usuário autorizou o envio das versões ao longo do desenvolvimento. A pasta local está vinculada a esse endereço; o primeiro envio depende de autenticação. Distribuir executáveis em Releases, mantendo ferramentas e builds fora do código-fonte versionado.

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

Ainda não implementados: IA e texto livre, atuação autônoma dos vassalos, mapa isométrico, campanhas militares completas e atualizador. Próximo passo: experimentar a primeira partida, ajustar as regras e ampliar as negociações antes da integração de IA.

O histórico inicial foi registrado em Git localmente. A publicação remota será confirmada apenas após autenticação e envio bem-sucedido ao GitHub.
