# Coroa Quebrada

Jogo individual de política medieval e causa e consequência, desenvolvido em Godot. Cada turno corresponde a um mês de um reinado frágil. Projeto pessoal em desenvolvimento, com ferramentas gratuitas e execução local.

## Protótipo 0.1.0 — Conselho Real

Primeira base jogável, com três regiões, seis nobres, doze meses e duas ordens por mês. Cada senhor possui reservas próprias e produção diversificada. A Coroa administra suas próprias reservas, tropas e legitimidade.

Você pode enviar ajuda, comprar alimentos, exigir tributos extraordinários, negociar autonomia e recrutar soldados. Antes de confirmar, o conselho apresenta custos e efeitos conhecidos. Entregas levam um mês; reações políticas podem demorar. A crônica preserva o vínculo entre uma consequência e a ordem original.

Esta versão **ainda não possui IA integrada, texto livre, mapa isométrico, batalhas ou atualização automática**. Os seis nobres aparecem como senhores e vassalos, mas os vassalos ainda não tomam decisões independentes. O cenário é determinístico para testar as regras; balanceamento e variedade narrativa são provisórios.

## Jogar

Se houver pacote Windows publicado, consulte [Releases](https://github.com/coutocdouglas/CoroaQuebrada/releases). Extraia o ZIP e abra `CoroaQuebrada.exe`. Não requer conta de IA ou acesso à internet para jogar.

Pelo código-fonte:

1. Baixe a edição padrão da [Godot 4.7.2](https://github.com/godotengine/godot/releases/tag/4.7.2-stable).
2. Baixe ou clone este repositório.
3. Importe `project.godot` na Godot e pressione **F6** na cena principal ou **F5** para iniciar o projeto.

Na tela, escolha uma região e uma ordem, leia a proposta e confirme. Você pode emitir até duas ordens e então encerrar o mês. O conselho recomenda reunir 30 soldados antes do sexto mês. Ajuda alimentar chega na abertura do próximo mês, depois do consumo do mês encerrado: agir antes da escassez faz diferença.

**Salvar reinado** grava um arquivo local; **Carregar reinado** recupera estado, crônica e consequências. Há um único espaço de salvamento manual nesta versão. Fechar sem salvar perde alterações recentes. Um novo reinado pede confirmação e só substitui o save quando você salvar novamente.

O save fica no diretório de dados da aplicação da Godot, normalmente `%APPDATA%/Godot/app_userdata/Coroa Quebrada/reinado.json` no Windows. Não coloque partidas ou credenciais no repositório.

## Regras e documentação

- [Diretrizes e decisões do projeto](DIRETRIZES_DO_PROJETO.md)
- [Regras da primeira versão](docs/REGRAS_V0_1.md)
- [Histórico de versões](CHANGELOG.md)
- [Orientações para desenvolvimento assistido](AGENTS.md)

## Verificação

Com a Godot disponível no terminal:

```text
godot --headless --path . --editor --quit
godot --headless --path . --script tests/test_kingdom.gd
godot --headless --path . --quit-after 5
```

O workflow do GitHub repete os testes a cada envio. Os testes verificam transferências e entregas, limites de ordens, consequências que dependem das relações atuais, memória no mês 10, salvamento e campanhas completas.

## Exportar para Windows

O preset usa os modelos oficiais de exportação da mesma versão da Godot. Extraia `windows_release_x86_64.exe` e `windows_debug_x86_64.exe` do pacote oficial para `work/tools/templates/`. Essa pasta é local e não deve ser enviada ao GitHub. Crie `outputs/` e execute:

```text
godot --headless --path . --export-release "Windows Desktop" outputs/CoroaQuebrada.exe
```

O executável inclui os dados do jogo. Distribua junto com os avisos de terceiros. O build inicial não tem assinatura digital.

## Próximas etapas

1. Jogar e ajustar economia, dificuldade e consequências com base nas partidas.
2. Ampliar negociação e atuação própria dos personagens.
3. Integrar IA para propor ordens estruturadas e narrar fatos validados.
4. Acrescentar mapa isométrico e feedback visual.
5. Ampliar guerra, lore e distribuição com atualizações.

Godot usa licença MIT; ver [avisos de terceiros](THIRD_PARTY_NOTICES.md). A licença de distribuição do código e conteúdo próprio deste projeto ainda será definida pelo autor.
