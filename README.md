# Coroa Quebrada

Jogo individual de política medieval e causa e consequência, desenvolvido em Godot. Cada turno corresponde a um mês de um reinado frágil. Projeto pessoal em desenvolvimento, com ferramentas gratuitas e execução local.

## Protótipo 0.4.0 — Mapa do reino

Base jogável com três regiões, seis nobres, doze meses e duas ordens por mês. Cada senhor possui reservas próprias e produção diversificada. A Coroa administra suas próprias reservas, tropas e legitimidade.

Você pode enviar ajuda, comprar alimentos, exigir tributos extraordinários, negociar autonomia e recrutar soldados. Antes de confirmar, o conselho apresenta custos e efeitos conhecidos. Entregas levam um mês; reações políticas podem demorar. A crônica preserva o vínculo entre uma consequência e a ordem original.

Na versão 0.2, cada senhor apresenta pedidos com prazo. Você pode aceitar, recusar ou adiar. A Marca oferece ferro por alimentos; a Costa negocia madeira e privilégios; o Vale pede socorro às aldeias. Os senhores também compram excedentes uns dos outros quando há escassez. Vassalos têm apoio próprio à Coroa e podem financiar mediação em crises. A nova ordem **Ouvir o vassalo** aumenta esse apoio, mas pode contrariar o senhor.

Na versão 0.3, o jogo ganha instalador por usuário para Windows, atalhos, desinstalador e atualização pelo botão **Atualizações**. Ele consulta o GitHub ao abrir, oferece o download de versões mais novas e salva a partida antes de reiniciar para aplicar a atualização. Não exige conta no GitHub para jogar ou atualizar.

Na versão 0.4, o mapa isométrico é a tela principal. Clique em um território, castelo ou cartão para selecionar a região: os dados e as ordens à esquerda mudam junto. A borda dourada identifica a seleção. Use as setas com o mapa em foco para percorrer as regiões. A aba **Crônica** preserva o histórico completo.

Castelos, vilas, estradas e porto compõem a primeira representação do reino. Alimentos, lealdade e pedidos vêm da partida. Plantações refletem geada e escassez, vilas sinalizam agitação elevada e recrutamentos mostram um acampamento durante o mês. Essa é uma primeira arte geométrica, sem animação, construção livre ou movimentação de exércitos.

Esta versão **ainda não possui IA integrada, texto livre ou batalhas completas**. As decisões dos personagens são regras determinísticas, não IA generativa. Os pedidos têm três tipos fixos; personalidades e relações serão ampliadas após testar o equilíbrio.

## Jogar

Se já usa a versão 0.3, abra **Atualizações** no próprio jogo para receber a versão 0.4 e manter sua partida. Para a primeira instalação, baixe `CoroaQuebrada-Setup-0.4.0.exe` em [Releases](https://github.com/coutocdouglas/CoroaQuebrada/releases/tag/v0.4.0), execute e abra **Coroa Quebrada** pelo menu Iniciar. A instalação padrão fica em `%LOCALAPPDATA%/Programs/CoroaQuebrada`, sem exigir administrador. Há opção de atalho na área de trabalho e desinstalação pelo Windows.

Para as próximas versões, use **Atualizações → Baixar atualização → Salvar e reiniciar**, dentro do jogo. A consulta inclui os protótipos publicados pelo autor; rascunhos, versões antigas e pacotes incompatíveis são ignorados. O download e o reinício dependem da sua confirmação. Sem internet ou se o GitHub estiver indisponível, o jogo continua funcionando. As versões 0.1 e 0.2 precisam desta instalação inicial, pois ainda não tinham atualizador.

O ZIP continua disponível para execução portátil, com seus quatro arquivos juntos. Ele é também o pacote usado pelo atualizador. Não exige conta de IA ou internet para jogar.

Pelo código-fonte:

1. Baixe a edição padrão da [Godot 4.7.2](https://github.com/godotengine/godot/releases/tag/4.7.2-stable).
2. Baixe ou clone este repositório.
3. Importe `project.godot` na Godot e pressione **F6** na cena principal ou **F5** para iniciar o projeto.

Na tela, escolha uma região e uma ordem, leia a proposta e confirme. Você pode emitir até duas ordens e então encerrar o mês. O conselho recomenda reunir 30 soldados antes do sexto mês. Ajuda alimentar chega na abertura do próximo mês, depois do consumo do mês encerrado: agir antes da escassez faz diferença.

Use o botão **Pedido aberto** da região para negociar. Aceitar ou recusar usa uma das duas ordens; **Decidir depois** não usa ordem, mas o prazo continua passando. Os termos e o prazo aparecem antes de confirmar. Role os detalhes da região para ver o interesse do senhor e o apoio do vassalo.

Partidas das versões 0.1, 0.2 e 0.3 podem ser carregadas nesta versão. A migração mantém recursos, histórico e consequências pendentes e não modifica o arquivo até você salvar. O formato continua sendo o da 0.2. O mapa reconstrói seus indicadores a partir do save. Saves no formato 2 não podem ser carregados na 0.1; faça uma cópia se quiser alternar versões. Instalar, atualizar e desinstalar preservam a pasta de partidas em AppData.

**Salvar reinado** grava um arquivo local; **Carregar reinado** recupera estado, crônica e consequências. Há um único espaço de salvamento manual nesta versão. Fechar sem salvar perde alterações recentes. Um novo reinado pede confirmação e só substitui o save quando você salvar novamente.

O save fica no diretório de dados da aplicação da Godot, normalmente `%APPDATA%/Godot/app_userdata/Coroa Quebrada/reinado.json` no Windows. Não coloque partidas ou credenciais no repositório.

## Regras e documentação

- [Diretrizes e decisões do projeto](DIRETRIZES_DO_PROJETO.md)
- [Regras da primeira versão](docs/REGRAS_V0_1.md)
- [Diplomacia e personagens da versão 0.2](docs/REGRAS_V0_2.md)
- [Instalador, atualização e publicação](docs/ATUALIZACOES.md)
- [Mapa do reino e indicadores](docs/MAPA.md)
- [Histórico de versões](CHANGELOG.md)
- [Orientações para desenvolvimento assistido](AGENTS.md)

## Verificação

Com a Godot disponível no terminal:

```text
godot --headless --path . --editor --quit
godot --headless --path . --script tests/test_kingdom.gd
godot --headless --path . --script tests/test_ui.gd
godot --headless --path . --script tests/test_politics.gd
godot --headless --path . --script tests/test_updater.gd
godot --headless --path . --script tests/test_map.gd
```

O workflow do GitHub repete os testes a cada envio. São 253 verificações: 105 da simulação, 56 da política e migração, 14 da interface, 20 da seleção e download, 45 do mapa e 13 da aplicação Windows. O teste Windows roda com `powershell -File tests/test_update_windows.ps1` e usa apenas diretórios de teste dentro de `work/`.

Além disso, `tests/test_install_windows.ps1` executa 11 verificações locais com o instalador de AppId exclusivo de teste: instala, abre o jogo, aplica o pacote real, verifica o binário resultante, inicia com retomada de save e desinstala preservando arquivos não gerenciados.

## Exportar para Windows

O preset usa os modelos oficiais de exportação da mesma versão da Godot. Extraia `windows_release_x86_64.exe` e `windows_debug_x86_64.exe` do pacote oficial para `work/tools/templates/`. Essa pasta é local e não deve ser enviada ao GitHub. Crie `outputs/` e execute:

```text
godot --headless --path . --export-release "Windows Desktop" outputs/CoroaQuebrada.exe
```

O executável inclui os dados do jogo. Para preparar instalador e ZIP completos, use `tools/build-windows.ps1 -Godot CAMINHO_DA_GODOT`, com Inno Setup 6 instalado. A rotina testa, exporta e empacota o jogo com o atualizador e os avisos de terceiros. Veja os procedimentos de publicação em [ATUALIZACOES.md](docs/ATUALIZACOES.md). O instalador ainda não tem assinatura digital.

## Próximas etapas

1. Jogar e ajustar economia, dificuldade e consequências com base nas partidas.
2. Ampliar a variedade de pedidos e relações conforme os testes do protótipo 0.2.
3. Integrar IA para propor ordens estruturadas e narrar fatos validados.
4. Detalhar e animar o mapa conforme as novas mecânicas do reino.
5. Ampliar guerra e lore; manter a distribuição com atualizações pelo aplicativo.

Godot usa licença MIT; ver [avisos de terceiros](THIRD_PARTY_NOTICES.md). A licença de distribuição do código e conteúdo próprio deste projeto ainda será definida pelo autor.
