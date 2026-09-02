# Regras de negócio e segurança

## Apresentação do posto no Firestore — 31/08/2026

`stationBrand` é opcional nas projeções `gas_stations/{uid}` e `public_stations/{uid}`. A ausência de capa usa fallback ilustrado; `stationBrand` ausente ou inválido é lido como “Bandeira branca”. A UI apresenta Shell, Ipiranga, Petrobras, ALE, RodOil, Bandeira branca e Outra como nomes/selo, sem logos oficiais. “Outra” exige nome entre 2 e 60 caracteres.

O contrato de `firestore.rules` para `station_covers/{stationId}` permite leitura pública e escrita/exclusão somente ao usuário autenticado que possua `gas_stations/{stationId}`. O documento aceita apenas as chaves previstas, `Blob` JPEG de até 500 KiB, tamanho coerente e timestamp de servidor.

O app normaliza JPG, PNG ou WebP de até 5 MiB para JPEG de até 500 KiB e 1280 px. Uma transação aplica a bandeira nas projeções privada e pública e cria, substitui, preserva ou remove a capa. A lista pública não lê `station_covers`; o detalhe lê a imagem separadamente e mantém o fallback caso a leitura falhe.

A solução usa apenas o Firestore disponível no plano gratuito e não depende de bucket ou Firebase Storage. As regras foram compiladas com sucesso em `--dry-run`; não houve deploy no projeto remoto.

## Regras funcionais

1. Aplicação opera com dois perfis: `client` e `gas_station`.
2. Postos públicos e cadastros de posto aceitam somente cidade `Bebedouro`.
3. Cliente pode manter uma avaliação por posto e um favorito por posto.
4. Avaliação exige nota 1–5 e comentário 3–500 caracteres.
5. Ranking usa média bayesiana com prior 4 e peso 10.
6. Status aberto/fechado deriva do horário local do dispositivo, incluindo expediente que cruza meia-noite.
7. Dados privados e públicos do posto são atualizados em batch pelo app.
8. Preços válidos ficam no intervalo `(0, 50]`.
9. Denúncias nascem com status `pending`; cliente não pode editá-las/removê-las.
10. Exclusão de conta exige confirmação e, para senha/e-mail, reautenticação.

## Matriz de acesso observada

| Recurso | Público | Cliente autenticado | Dono do UID/posto |
|---|---|---|---|
| `users/{uid}` | não | próprio documento | próprio documento |
| favoritos | não | próprios | próprios |
| `gas_stations/{uid}` | não | **pode criar no próprio UID** | lê/edita/exclui próprio |
| `public_stations/{id}` | leitura | leitura e **pode criar no próprio UID** | CRUD do próprio ID |
| reviews | leitura | cria/edita/exclui a própria | leitura |
| review reports | não | qualquer autenticado pode criar | dono lê |
| station reports | não | cliente cria/lê própria | posto lê |

Fallback global nega tudo não declarado.

## Achados de segurança

### P0 — escalada de papel por criação de documentos

`ownsDocument(uid)` verifica apenas `request.auth.uid == uid`. Criação de `gas_stations/{uid}` não exige claim administrativa, convite, aprovação ou ausência de `users/{uid}`. Usuário cliente pode criar payload de posto válido no próprio UID. Login verifica posto antes de cliente e então abre dashboard.

Criação de `public_stations/{stationId}` também exige apenas mesmo UID e schema válido; não exige existência de `gas_stations/{uid}` nem papel confiável.

**Correção recomendada:** papel em Firebase custom claims definido por ambiente confiável, ou callable/HTTP backend com Admin SDK para criar posto após verificação. Rules devem validar claim e consistência entre perfil e recurso. Não usar campo gravável pelo próprio cliente como fonte de autorização.

#### Estado e sequência de entrega aprovados

- **Hoje:** cadastro de posto não aguarda aprovação e publica os documentos imediatamente.
- **Planejado:** um usuário administrador verifica CNPJ e e-mail, aprova ou rejeita a solicitação e somente a aprovação concede o papel administrativo confiável.
- **Ordem de desenvolvimento:** concluir primeiro as telas do cliente e do posto; implementar em seguida aprovação administrativa, bloqueio de contas pendentes, rules baseadas em papel confiável e testes no Firebase Emulator.
- **Limite de entrega:** a prioridade temporária de interface não reduz a severidade P0. O sistema não deve ser declarado pronto para produção ou uso público antes da proteção e dos testes de autorização.
- **Dados de demonstração:** catálogo e logos podem ser preparados sem criar contas falsas. Qualquer carga deve ser revisável, testada no Emulator e separada do fluxo público de cadastro.

### P1 — exclusão não é recursiva

Batch em `settings_page.dart` remove documentos `users`, `gas_stations` e `public_stations`, mas Firestore não exclui subcoleções automaticamente. Podem permanecer:

- favoritos;
- reviews;
- denúncias de review;
- denúncias de posto.

**Correção recomendada:** função backend idempotente/Cloud Function que enumere e apague subcoleções, depois apague Auth; registrar estado da operação e retentar falhas. Política deve decidir se reviews são anonimizadas ou apagadas.

### P1 — restauração parcial e timestamps adulterados

Se exclusão Auth falhar, UI restaura documentos pais com timestamps novos. Subcoleções não participam do batch. Estado restaurado pode não equivaler ao anterior e auditoria temporal é perdida.

### P1 — regras de horários e listas permissivas

`validOpeningHours` valida somente chaves. Valores podem ter estrutura/tipos inesperados. `tags` e `services` limitam tamanho, mas aceitam conteúdo arbitrário. Isso pode quebrar parsing/UI ou armazenar conteúdo indevido.

### P2 — leitura pública irrestrita

Postos e reviews têm `allow read: if true`. Isso pode ser intenção do produto, mas deve constar em política de privacidade; nome do autor da review é publicamente enumerável.

### P2 — rate limiting e abuso

Rules impedem várias duplicidades pelo ID, mas não fornecem limitação temporal. Auth/Firestore App Check não foi localizado. Denúncias e criação de contas podem sofrer automação/abuso.

## Divergências entre UI/service/rules

| Tema | UI/service | Rules | Risco |
|---|---|---|---|
| telefone cliente | cadastro testa mínimo 10 | regex 10–11 | UI pode aceitar >11 e falhar só no Firestore |
| CNPJ | 14 dígitos | 14 dígitos | aceita número matematicamente inválido |
| cidade | valida Bebedouro | valida Bebedouro | consistente, mas regra de produto hard-coded |
| horários | app cria estrutura correta | interior não validado | escrita direta pode corromper formato |
| tags/serviços | opções fixas na tela | qualquer lista dentro do limite | bypass do cliente permite valores arbitrários |
| papel | app escolhe fluxo | documento próprio define papel | escalada de privilégio |

## Recomendações operacionais

1. Adicionar testes no Firebase Emulator Suite para cada allow/deny e caso de escalada.
2. Bloquear deploy se testes de rules falharem.
3. Habilitar App Check nas plataformas suportadas.
4. Mover criação/exclusão de posto e conta para backend confiável.
5. Definir retenção/anonimização de avaliações e denúncias.
6. Monitorar volume de reads, writes negadas e denúncias pendentes.
7. Remover mensagens técnicas de rules/Firestore da UI; enviar detalhes a logs protegidos.
