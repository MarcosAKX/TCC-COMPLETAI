# Completai!

Aplicação Flutter para descoberta e gestão de postos de combustível em Bebedouro. Motoristas comparam preços, status e reputação; postos mantêm dados públicos atualizados.

## Stack

Flutter · Dart · Firebase Auth · Cloud Firestore · Android (entrega principal)

## Documentação

| Documento | Descrição |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | camadas, fluxos e decisões técnicas |
| [STRUCTURE.md](STRUCTURE.md) | organização de pastas e convenções |
| [DESIGN.md](DESIGN.md) | design system e regras de interface |
| [PRODUCT.md](PRODUCT.md) | escopo, usuários e princípios de produto |
| [docs/](docs/README.md) | modelo de dados, segurança, roadmap |

## Setup rápido

```bash
flutter pub get
flutter run
```

Firebase deve estar configurado (`lib/firebase_options.dart`, `google-services.json` no Android). Plataformas com Firebase ativo: **Android** e **Web**.

## Testes

```bash
flutter analyze
flutter test
```
