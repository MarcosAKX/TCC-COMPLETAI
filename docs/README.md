# Documentação técnica — Completai

Retrato do projeto em **17 de agosto de 2026**. Documentos descrevem código existente; recomendações não representam funcionalidades já implementadas.

## Documentos canônicos (raiz)

| Documento | Conteúdo |
|---|---|
| [ARCHITECTURE.md](../ARCHITECTURE.md) | camadas, fluxos, decisões técnicas, dívida |
| [STRUCTURE.md](../STRUCTURE.md) | pastas, rotas, nomenclatura |
| [DESIGN.md](../DESIGN.md) | design system e regras de interface |
| [PRODUCT.md](../PRODUCT.md) | propósito, escopo, princípios de produto |

## Documentos complementares

1. [Modelo de dados](MODELO-DE-DADOS.md)
2. [Regras de negócio e segurança](REGRAS-DE-NEGOCIO-E-SEGURANCA.md)
3. [Design e interface — auditoria UX](DESIGN-E-INTERFACE.md)
4. [Qualidade, riscos e roadmap](QUALIDADE-RISCOS-E-ROADMAP.md)
5. [TAP e rastreabilidade do escopo](TAP-E-RASTREABILIDADE.md)
6. [Especificação do redesign claro](superpowers/specs/2026-08-17-redesign-claro-acolhedor-design.md)

## Resumo executivo

Completai é aplicação Flutter apoiada em Firebase Authentication e Cloud Firestore. Atende dois papéis:

- **cliente:** consulta postos de Bebedouro, compara preços, ordena resultados, favorita, avalia e denuncia;
- **posto:** cadastra perfil, mantém preços, serviços, tags e horários, consulta avaliações e envia denúncias.

Pontos críticos:

- **P0 — autorização por papel:** regras permitem que usuário autenticado crie perfil de posto no próprio UID;
- **P1 — ciclo de vida:** exclusão de documento Firestore não remove subcoleções;
- **P1 — escalabilidade:** listagem executa consulta de avaliações por posto (N+1);
- **P1 — arquitetura:** telas principais acumulam estado, regra de apresentação e coordenação de dados;
- **P1 — UX:** dashboard é megaform; identidade visual ainda genérica apesar dos tokens (ver auditoria).

## Escopo da revisão

Incluídos: `lib/`, `test/`, `firestore.rules`, `firebase.json`, `pubspec.yaml`, configurações Flutter e estrutura das plataformas. Artefatos gerados (`build/`, `.dart_tool/`) e boilerplate nativo foram inventariados, não revisados linha a linha.
