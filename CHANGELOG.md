# Histórico de versões

## 0.3.0 — 2026-11-01

- Instalador Windows por usuário com atalhos e desinstalador, sem exigir administrador.
- Painel de atualizações no jogo e consulta das versões públicas do GitHub.
- Download mediante confirmação, verificação de tamanho e SHA-256, salvamento e reinício para aplicar.
- Atualizador separado espera o jogo fechar, troca arquivos com backup e tenta restaurar a versão anterior se houver falha.
- Partidas preservadas em AppData; o jogo retoma o save após atualizar.
- Rotinas reproduzíveis de build e publicação, com instalador e ZIP de atualização na mesma release.
- 208 verificações automatizadas, incluindo falhas de rede, hash inválido, arquivo bloqueado, restauração e caminhos externos.

## 0.2.0 — 2026-11-01

- Pedidos diplomáticos com prazo, aceite, recusa e adiamento sem gasto de ordem.
- Interesses distintos para os três senhores; troca de alimentos por ferro, carta comercial e socorro às aldeias.
- Cargas e contrapartidas reservadas ao firmar acordos e entregues no mês seguinte.
- Comércio autônomo entre regiões, usando excedentes e reservas dos senhores.
- Apoio próprio dos vassalos, audiência real e mediação autônoma em crises.
- Salvamento em formato 2, com migração de partidas da 0.1 sem reescrever o arquivo ao carregar.
- 173 verificações automatizadas, incluindo um save gerado pelo código original da versão 0.1.
- Mantidos os doze turnos, a memória de decisões e a execução local gratuita. IA e mapa ficam para etapas posteriores.

## 0.1.0 — 2026-11-01

- Primeira base jogável do Conselho Real em Godot.
- Três regiões com produção diversificada, reservas regionais e reservas reais separadas.
- Doze meses, duas ordens por turno, cinco ações e crise inicial de abastecimento.
- Consequências adiadas com origem registrada, reconciliação política e memória de ajuda no mês 10.
- Crônica, finais e salvamento local versionado com validação ao carregar.
- Testes automatizados de economia, memória, salvamento e campanhas completas.
- IA, mapa isométrico e atualizador ficam para etapas posteriores.
