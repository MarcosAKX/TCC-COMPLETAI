# Foto de capa do posto no Firestore

## Contexto

O projeto `completai-tcc` permanece no plano Spark. Desde 3 de fevereiro de
2026, o Cloud Storage for Firebase exige o plano Blaze, e o bucket padrão não
está provisionado. A implementação anterior baseada em `firebase_storage`
falha nesse ambiente e pode manter o upload em repetição por vários minutos.

Esta mudança substitui somente a persistência da foto de capa. A edição de
bandeira, a prévia administrativa, a apresentação pública e o logout por papel
continuam com o comportamento já aprovado.

## Objetivos

- permitir uma única foto por posto sem habilitar cobrança;
- manter a lista pública leve, sem baixar bytes de imagem;
- carregar a foto apenas na edição administrativa e no detalhe público;
- impedir espera infinita e apresentar erros acionáveis;
- manter leitura pública da capa e escrita exclusiva do posto proprietário;
- preservar compatibilidade com postos que ainda não possuem capa ou bandeira.

## Fora de escopo

- galeria com várias fotos;
- recorte manual ou editor de imagem;
- coordenadas e mapas;
- logos oficiais das bandeiras;
- migração automática de objetos do Firebase Storage, pois o bucket nunca foi
  provisionado;
- contratação do plano Blaze;
- deploy automático das regras do Firestore sem autorização separada.

## Arquitetura de dados

A bandeira continua como `stationBrand` opcional em `gas_stations/{uid}` e
`public_stations/{uid}`.

A foto passa a ocupar um documento separado:

```text
station_covers/{uid}
  stationId: string
  bytes: bytes
  contentType: "image/jpeg"
  byteSize: number
  updatedAt: timestamp
```

O documento separado evita que consultas a `public_stations` transfiram a foto
de cada resultado. Não haverá URL pública nem Base64. O SDK do Firestore entrega
o campo binário como `Blob`, convertido em `Uint8List` somente no detalhe.

O limite funcional será 500 KiB por capa, abaixo do limite rígido de 1 MiB por
documento do Firestore. `byteSize` é redundante de propósito: facilita
diagnóstico e permite validação consistente nas regras, enquanto a aplicação
continua verificando o tamanho real de `bytes`.

## Processamento da imagem

O seletor continua aceitando JPG, PNG ou WebP. Antes de persistir, a aplicação:

1. decodifica a imagem selecionada;
2. corrige a orientação quando os metadados permitirem;
3. reduz a maior dimensão para no máximo 1280 pixels, sem ampliar imagens
   menores;
4. converte o resultado para JPEG;
5. reduz progressivamente qualidade e dimensões até ficar com no máximo
   500 KiB;
6. rejeita o arquivo com mensagem clara se não for possível obter uma imagem
   válida dentro do limite.

O processamento será isolado em uma função pura, testável com bytes locais. A
prévia usa os bytes JPEG já normalizados, de modo que o que o administrador vê
é o que será salvo.

## Fluxos de leitura

### Administração

Ao abrir `Editar exibição`, o serviço lê `gas_stations/{uid}` para obter a
bandeira e tenta ler `station_covers/{uid}`. Documento ausente significa capa
de fallback, não erro.

### Área pública

A lista continua lendo somente `public_stations`; nenhuma capa é baixada. Ao
abrir um posto, o serviço busca `station_covers/{stationId}` e anexa os bytes ao
modelo usado somente pela tela de detalhe. Documento ausente, inválido ou
indisponível mantém a capa ilustrada de fallback.

## Fluxos de gravação

Salvar bandeira sem trocar foto atualiza `gas_stations/{uid}` e
`public_stations/{uid}` em transação. Se o documento público estiver ausente, a
transação o reconstrói a partir do documento privado antes de aplicar a
bandeira.

Salvar uma nova foto executa, na mesma transação:

- atualização da bandeira nas projeções privada e pública;
- criação ou substituição de `station_covers/{uid}` com os bytes normalizados.

Remover a foto exclui `station_covers/{uid}` e preserva a bandeira selecionada.
Não será mantido `coverImagePath`, pois o caminho é determinístico pelo UID.
Documentos antigos que contenham esse campo continuam legíveis, mas novas
gravações o removem das duas projeções.

Cada operação de persistência terá limite de 20 segundos na camada de UI. O
estado `isSaving` será restaurado em `finally`, inclusive em timeout ou erro de
permissão. Mensagens diferenciarão sessão expirada, permissão negada, timeout e
falha genérica.

## Segurança

As regras do Firestore terão um bloco para `station_covers/{stationId}`:

- leitura pública;
- criação, atualização e exclusão somente quando
  `request.auth.uid == stationId` e o usuário for um posto;
- chaves limitadas a `stationId`, `bytes`, `contentType`, `byteSize` e
  `updatedAt`;
- `stationId` imutável e igual ao ID do documento;
- `contentType == "image/jpeg"`;
- `bytes` do tipo binário com no máximo 500 KiB;
- `byteSize` inteiro positivo, igual ao tamanho de `bytes`;
- `updatedAt == request.time`.

`stationBrand` permanece com 2 a 60 caracteres. As regras locais serão
validadas em `dry-run`. O deploy será uma etapa externa separada e só ocorrerá
após autorização explícita do usuário.

## Dependências e limpeza

- manter `image_picker`;
- adicionar `image: ^4.9.2`, biblioteca Dart compatível com web, para
  decodificar, redimensionar e codificar JPEG;
- remover `firebase_storage`;
- remover a configuração e as regras locais exclusivas do Storage;
- regenerar somente os registradores de plugins afetados pelo `pub get`.

## Compatibilidade e falhas

- capa ausente: ilustração atual;
- bytes inválidos: fallback no detalhe e erro acionável na edição;
- documento público legado ausente: reconstrução transacional;
- regras ainda não publicadas: mensagem de permissão, sem spinner infinito;
- operação acima de 20 segundos: timeout, botão reabilitado e nenhuma alegação
  de sucesso;
- falha após selecionar uma imagem: seleção local preservada para nova
  tentativa, salvo quando o usuário a remover.

## Testes e verificação

- testes unitários da normalização de JPG, PNG e WebP;
- rejeição de bytes inválidos e garantia de saída JPEG com até 500 KiB;
- serviço: carregar sem capa, salvar somente bandeira, salvar/substituir capa,
  remover capa e reconstruir projeção pública ausente;
- UI: prévia com bytes, timeout/erro reabilitando o botão e salvamento bem
  sucedido retornando ao painel;
- público: lista sem leitura da capa e detalhe resolvendo bytes sob demanda;
- validação das regras em `firebase deploy --only firestore:rules --dry-run`;
- `flutter analyze --no-pub`, testes focados, suíte completa e
  `git diff --check`.

## Critérios de aceitação

1. O posto salva uma bandeira sem foto e retorna ao painel.
2. O posto seleciona JPG, PNG ou WebP e vê uma prévia normalizada.
3. A capa salva reaparece na edição e no detalhe público.
4. A lista pública não baixa bytes da capa.
5. A foto pode ser substituída ou removida.
6. Nenhuma operação mantém o carregamento indefinidamente.
7. O plano Blaze e o Firebase Storage não são necessários.
8. Nenhuma regra é implantada sem nova autorização explícita.
