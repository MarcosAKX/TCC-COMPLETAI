# Foto de capa, bandeira e sessão do posto

> **Documento histórico:** a persistência de foto com Firebase Storage foi
> substituída por Firestore. Consulte
> `2026-08-31-station-cover-firestore-design.md` para a arquitetura ativa.

**Data:** 31/08/2026
**Status:** proposta aprovada para planejamento; ainda não implementada

## Objetivo

Permitir que o administrador configure uma única foto de capa e a bandeira do posto pela ação **Editar exibição** da prévia pública. A apresentação deve aparecer no dashboard e no perfil público, preservando a capa ilustrada atual quando não houver foto. A opção **Sair da conta** passa das configurações para o perfil administrativo do posto, abaixo de **Alterar senha**, sem mudar o fluxo do usuário comum.

## Escopo

Incluído:

- uma foto de capa ativa por posto, substituível e removível;
- seleção de Shell, Ipiranga, Petrobras, ALE, RodOil, Bandeira branca ou Outra;
- nome personalizado de até 60 caracteres quando a bandeira não estiver na lista;
- bandeira apresentada como selo textual com ícone genérico, sem logos oficiais;
- nova tela **Editar exibição**, aberta pelo lápis da prévia administrativa;
- foto e bandeira na prévia administrativa e no perfil público;
- armazenamento no Firebase Storage e metadados no Firestore;
- regras de leitura pública e escrita exclusiva do proprietário;
- logout do posto no perfil administrativo e oculto nas configurações do posto.

Fora do escopo:

- galeria, múltiplas fotos, recorte avançado ou filtros;
- logos oficiais das bandeiras;
- coordenadas, mapa real, distância ou cálculo interno de rota;
- alteração do logout do usuário comum;
- deploy de regras, criação remota do bucket, commit, push ou merge automáticos.

## Abordagem escolhida

Usar Firebase Storage para os bytes da imagem e Firestore para os campos públicos de apresentação. Guardar Base64 no Firestore foi descartado por tamanho e custo; aceitar apenas URL externa foi descartado por experiência ruim e risco de link quebrado.

Novas dependências Flutter:

- `firebase_storage`, para upload, leitura de URL e remoção;
- `image_picker`, para selecionar imagem no navegador e nos dispositivos móveis.

## Modelo de dados

Os documentos `gas_stations/{uid}` e `public_stations/{uid}` aceitam dois campos opcionais:

| Campo | Tipo | Regra |
|---|---|---|
| `coverImagePath` | string | caminho de objeto pertencente ao próprio `uid` |
| `stationBrand` | string | 2 a 60 caracteres; padrão visual “Bandeira branca” quando ausente |

Os campos são opcionais para manter compatibilidade com postos existentes. `coverImagePath` não armazena URL arbitrária. O aplicativo resolve temporariamente o download pelo SDK do Firebase Storage. Uma bandeira fora da lista conhecida é interpretada como **Outra** na edição.

## Armazenamento e substituição

Cada upload usa um novo objeto em `station_covers/{uid}/cover_<timestamp>.<extensão>`. Apesar de poder haver um objeto antigo durante a troca, somente o caminho registrado no Firestore é considerado a foto ativa.

Fluxo de substituição:

1. validar arquivo local;
2. enviar o novo objeto;
3. atualizar `coverImagePath` e `stationBrand` nos documentos privado e público em lote;
4. atualizar a interface;
5. remover o objeto anterior em melhor esforço.

Se a atualização do Firestore falhar, o novo objeto é removido em melhor esforço e a apresentação anterior continua ativa. Esse fluxo evita que uma falha de upload apague a foto válida atual e evita cache obsoleto ao usar um caminho novo.

Fluxo de remoção:

1. confirmar a ação com o administrador;
2. remover `coverImagePath` dos documentos em lote;
3. voltar imediatamente ao fallback ilustrado;
4. remover o objeto anterior em melhor esforço.

Um arquivo órfão após falha de limpeza não fica público pela interface e pode ser removido numa tentativa posterior.

## Validação e segurança

A seleção aceita JPG, PNG ou WebP com tamanho máximo de 5 MB. A validação ocorre no cliente antes do upload e novamente nas regras do Storage por `contentType` e `size`.

Regras do Storage:

- leitura pública somente em `station_covers/{stationId}/{fileName}`;
- criação, atualização e remoção somente quando `request.auth.uid == stationId`;
- escrita limitada a imagem JPG, PNG ou WebP e menos de 5 MB;
- demais caminhos negados por padrão.

Regras do Firestore:

- adicionar os campos opcionais às listas permitidas das coleções privada e pública;
- validar `stationBrand` como string curta;
- validar `coverImagePath` como caminho dentro de `station_covers/{stationId}/`;
- permitir ao proprietário atualizar esses campos e `updatedAt`;
- continuar impedindo alterações públicas por clientes.

`firebase.json` passa a declarar `storage.rules`. A criação ou ativação do bucket e o deploy permanecem ações externas separadas.

## Interface administrativa

O tooltip e destino do lápis da prévia mudam de **Editar dados cadastrais** para **Editar exibição**.

A nova tela apresenta:

- título **Editar exibição**;
- prévia real da capa e do selo de bandeira;
- estado vazio com a ilustração atual;
- botão **Selecionar foto** ou **Substituir foto**;
- botão **Remover foto**, visível apenas quando existir foto salva ou seleção local;
- seletor de bandeira;
- campo de nome quando **Outra** estiver selecionada;
- ação principal **Salvar exibição**;
- progresso durante upload e mensagens humanas de erro.

Sair da tela com alterações pendentes exige confirmação. Controles mantêm alvo mínimo de 48 dp, reflow em 320 dp e escala de texto de até 2,0×.

## Apresentação pública

`StationVisualCover` recebe foto e bandeira opcionais:

- com foto: usa `BoxFit.cover`, sobreposição escura para contraste e conteúdo textual existente;
- sem foto ou em erro de download: usa a ilustração azul-verde atual;
- o selo mostra a bandeira selecionada com ícone de posto;
- a semântica informa foto de capa, nome, localização textual e estado aberto/fechado sem depender da imagem.

A prévia administrativa usa o mesmo widget e os mesmos dados públicos para evitar divergência.

## Logout do posto

O perfil administrativo recebe a ação **Sair da conta** logo abaixo de **Alterar senha**, em papel visual de ação destrutiva e com alvo mínimo de 48 dp. Ao tocar, o administrador confirma, a sessão é encerrada e a navegação volta ao login removendo as rotas autenticadas.

As configurações verificam o tipo da conta:

- posto: não mostram **Sair da conta**;
- usuário comum: mantêm o comportamento atual.

Excluir conta continua nas configurações para os dois tipos.

## Tratamento de erros

- arquivo inválido: explicar formatos e limite antes de enviar;
- upload falhou: manter foto anterior e permitir nova tentativa;
- atualização dos metadados falhou: limpar novo objeto em melhor esforço e manter estado anterior;
- download falhou: exibir capa ilustrada sem quebrar a tela;
- remoção do objeto antigo falhou: não reverter metadados já salvos;
- sessão expirada: impedir upload e orientar novo login.

## Testes e verificação

- teste puro de tipo, tamanho e nome de bandeira;
- teste de parsing dos novos campos opcionais e compatibilidade com documentos antigos;
- teste de widget da capa com foto, fallback e selo;
- teste responsivo da tela **Editar exibição** em 320×568, texto 2,0× e paisagem;
- teste de prévia administrativa usando foto/bandeira;
- teste do perfil do posto com logout abaixo de alterar senha;
- teste das configurações com logout visível para usuário e oculto para posto;
- teste do contrato de payload privado/público do serviço;
- análise estática, suíte Flutter completa e `git diff --check`;
- validação manual no navegador para seleção, substituição e remoção;
- validação das regras com emulador/CLI quando disponível; se indisponível, registrar explicitamente a limitação.

## Implantação

Antes de uso real, o projeto Firebase precisa ter Storage habilitado e receber `storage.rules` e `firestore.rules`. Código, configuração e regras podem ser preparados na branch isolada, mas nenhum deploy faz parte desta implementação sem nova autorização explícita.
