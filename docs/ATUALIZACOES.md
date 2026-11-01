# Instalação e atualização — versão 0.3

## Uso

Instale uma vez com o arquivo `CoroaQuebrada-Setup-0.3.0.exe`. A instalação por usuário usa `%LOCALAPPDATA%/Programs/CoroaQuebrada`, cria um atalho no menu Iniciar e registra o desinstalador. O atalho da área de trabalho é opcional. O instalador não exige direitos de administrador.

O jogo consulta versões ao abrir. O botão **Atualizações** permite consultar novamente, baixar e escolher **Salvar e reiniciar**. Download e reinício nunca ocorrem sem esse comando. As versões de teste públicas são incluídas, enquanto o projeto estiver em protótipo. Sem rede, limite de consultas do GitHub ou erro de download, o jogo continua utilizável.

Ao confirmar o reinício, o jogo salva o reinado e inicia um aplicador separado, sem janela de terminal. Esse aplicador verifica o pacote novamente, aguarda o processo do jogo terminar, prepara os quatro arquivos permitidos, troca cada arquivo mantendo backup e reabre o jogo com `--resume-save`. O jogo retoma o save. Se o salvamento falhar, ele permanece aberto e não inicia a troca.

O formato de save continua sendo 2, compatível com a versão 0.2 e com migração dos saves da 0.1. A pasta `%APPDATA%/Godot/app_userdata/Coroa Quebrada` não é alvo do instalador nem do atualizador. Desinstalar também a preserva.

## Contrato das próximas releases

- Tag numérica `vMAJOR.MINOR.PATCH`, por exemplo `v0.4.0`, e a mesma versão em `project.godot`.
- Asset `CoroaQuebrada-vMAJOR.MINOR.PATCH-Windows.zip`, com nome e URL canônica desse mesmo repositório.
- Asset deve estar concluído, com tamanho positivo de até 512 MiB e `digest` SHA-256 publicado pela API do GitHub.
- ZIP contém exatamente `CoroaQuebrada.exe`, `Atualizar.ps1`, `COMO_JOGAR.txt` e `THIRD_PARTY_NOTICES.md`, na raiz. Não incluir pastas, arquivos extras ou caminhos relativos externos.
- Também publicar `CoroaQuebrada-Setup-MAJOR.MINOR.PATCH.exe` para novas instalações e `SHA256SUMS.txt` para conferência.
- Preservar o AppId de produção do instalador e o nome de aplicação da Godot, para manter atalhos, desinstalação e localização das partidas.
- Se uma futura versão precisar mudar esse contrato, primeiro publicar uma versão intermediária compatível. Uma versão pode atualizar a seguinte usando o aplicador que já possui.

A seleção considera até as 100 releases mais recentes e escolhe a maior versão numérica compatível. Não baixa a versão instalada nem faz downgrade. A integridade é conferida contra o digest obtido por HTTPS da API do GitHub; isso não substitui assinatura digital. O instalador e os binários próprios ainda não são assinados.

## Falhas e recuperação

O aplicador rejeita pacote com hash incorreto, arquivo inesperado, entrada duplicada, tamanho excessivo ou executável inválido. Cada substituição usa uma operação de troca de arquivo no mesmo volume. Em falha tratável, ele tenta restaurar os arquivos já trocados. O diagnóstico vai para `atualizacao.log` na pasta instalada. Se a restauração também falhar, as cópias de recuperação são preservadas no diretório `.update-.../backup` indicado no diagnóstico.

Isso cobre falhas tratadas, incluindo arquivos bloqueados, mas não garante recuperação automática após queda de energia ou encerramento forçado no meio da troca. Se necessário, execute novamente o instalador oficial na mesma pasta; ele não apaga saves. Políticas locais que bloqueiem PowerShell ou a execução de aplicativos também podem impedir o atualizador; nesse caso o jogo preserva o arquivo salvo e o instalador permite reparação manual.

O programa não armazena credenciais GitHub. Para consultar e baixar assets públicos, usa apenas HTTPS. Credenciais do desenvolvedor ficam no Git Credential Manager e nunca entram nos pacotes.

## Construir e publicar

1. Atualize a versão em `project.godot`, as notas em `docs/releases/vVERSAO.md` e o changelog.
2. Execute `tools/build-windows.ps1 -Godot CAMINHO_DA_GODOT`. Requer Godot 4.7.2, seus templates Windows na pasta de trabalho e Inno Setup 6. Scripts PowerShell são mantidos em UTF-8 com BOM para compatibilidade com Windows PowerShell 5.1.
3. Teste o instalador em pasta isolada. Há o parâmetro de compilação Inno `TestInstall`, que usa AppId distinto para evitar modificar a instalação real durante testes.
4. Registre e envie o código; aguarde o workflow completo passar, incluindo o job Windows.
5. Execute `tools/publish-release.ps1 -Version VERSAO`. Ele verifica o CI do commit, publica os três assets em rascunho, confere tamanho e digest e só então torna a release pública.

O instalador é para a primeira instalação. As próximas atualizações usam o ZIP pelo próprio jogo.
