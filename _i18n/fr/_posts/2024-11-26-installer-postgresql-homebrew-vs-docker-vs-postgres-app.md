---
layout: article
title:  "Installer PostgreSQL : Homebrew vs. Docker vs. Postgres.app"
date:   2024-11-26 08:00:00 +0200
categories: PostgreSQL Homebrew Docker
---

# Introduction

L'installation de PostgreSQL peut être réalisée de plusieurs manières. Dans cet article, nous allons explorer les avantages et les inconvénients de différentes méthodes d'installation pour déterminer laquelle répondra le mieux à vos besoins spécifiques.

Comprendre les distinctions entre les installations destinées à un environnement de production et celles conçues pour le développement est crucial, chaque contexte ayant ses propres défis et priorités.

Nous débuterons des considérations générales sur les environnements de production, avant de plonger plus en détail dans les différentes alternatives d’installation dans le cadre d’un environnement de développement.

# Installer PostgreSQL en production

Choisir le bon moyen d'installer PostgreSQL dans un environnement de production est essentiel pour garantir la performance, la sécurité et la robustesse de votre application. Bien que cet aperçu ne couvre pas toutes les possibilités, il vise à clarifier vos choix et à vous guider vers l'option la plus adaptée à vos besoins spécifiques. Je vous exposerai notamment les différences entre l'utilisation de bases de données gérées et l'installation sur vos propres serveurs dédiés.

## Utiliser un service de base de données gérée

Pour de nombreux projets, notamment ceux qui démarrent, opter pour une instance de base de données gérée est souvent le choix le plus évident. Voici les avantages majeurs de cette approche :

- **Déploiement aisé :** Facile à mettre en place, souvent en un clic, sécurisé et optimisé par défaut. Aucun besoin de procédures manuelles ou techniques pour l'installation.
- **Disponibilité immédiate :** La base de données est généralement disponible après quelques dizaines de secondes.
- **Maintenance facilitée :** Les mises à jour et la maintenance sont gérées par le prestataire.
- **Intégration simplifiée :** L’URL de connexion peut être simplement ajoutée à votre application.
- **Sauvegardes automatisées :** Ce service est généralement également géré par le prestataire.
- **Fonctionnalités avancées :** Accès à des options comme la redondance.
- **Gain de temps :** Permet un focus sur le développement, surtout au démarrage du projet.

Cependant, il existe quelques inconvénients :

- **Coût croissant :** Le coût peut devenir prohibitif à mesure que vos besoins augmentent (en pratique : vous mettez à jour votre base avec des instances plus grandes et cela coute plus cher).
- **Complexité de migration :** Une fois que votre base de données sera devenue importante, la migration vers un autre prestataire sera plus complexe, plus couteuse et nécessitera une indisponibilité de votre application plus importante.
- **Contrôle limité :** Vous n’aurez pas directement la main sur le serveur et vous n’aurez pas forcément accès à toutes les options.
- **Connaissances nécessaires :** Une compréhension des détails de fonctionnement internes de la base de données restera nécessaire pour conserver de bonnes performances à mesure que le volume de données dans la base augmente.
- **Dépendance au fournisseur :** La dépendance au fournisseur, qui peut être une aide précieuse mais également un point de blocage en cas de problèmes.

Par exemple, notre entreprise a initialement opté pour un service de base de données géré. Cependant, après un incident, nous avons réalisé que le manque de contrôle rendait la migration vers un autre fournisseur (géré également) plus complexe que prévue, ce qui nous a poussés à envisager une solution gérée en interne.

En conclusion, cette solution convient pour des besoins simples. Réfléchissez à vos besoins immédiats par rapport à votre budget. À mesure que votre application évolue, considérez si le coût et le manque de contrôle justifient alternative.

## Installation sur un serveur dédié

Installer PostgreSQL sur un serveur sous votre administration est une autre option viable. Ceci peut être réalisé via Docker ou une installation classique, selon vos préférences et votre familiarité avec ces technologies. Voici quelques distinctions à prendre en compte :

- **Maintenance avec Docker :** Utiliser Docker ajoute une couche de maintenance supplémentaire, nécessitant la gestion des mises à jour de Docker en parallèle de celles de PostgreSQL.
- **Images préconfigurées :** Docker vous propose des images prêtes à l'emploi, simplifiant le processus initial par rapport à un montage manuel.
- **Confort d'utilisation :** Pour ceux moins familiers avec Docker, une installation classique pourrait être plus intuitive.
- **Intégration dans l'infrastructure existante :** Si Docker est déjà présent pour d’autres services dans votre système, intégrer PostgreSQL à travers Docker vous permettra d’harmoniser votre configuration.

Les deux approches sont comparables en termes de ressources et de sécurité. Cette solution est idéale pour les applications nécessitant des performances élevées et une configuration spécifique, par exemple si vos besoins incluent des extensions non prises en charge par des services gérés. Bien que potentiellement moins coûteuse que certains services gérés en frais de service, elle demande un investissement continu pour maintenir la sécurité et le bon fonctionnement du système. Et vous n’aurez pas de contact extérieur en cas de problème.

Cette solution est préconisée pour les entreprises en croissance disposant des ressources nécessaires à la maintenance interne. Il est crucial que votre équipe possède les compétences requises, tout en prévoyant un budget pour la formation continue. Un engagement soutenu est indispensable pour les mises à jour, la maintenance et l'optimisation régulière.

# PostgreSQL pour les développeurs

Dans mes recherches récentes sur PostgreSQL, j'ai souvent remarqué une recommandation pour l'installation via Postgres.app. Personnellement, j'ai trouvé que l'utilisation de Homebrew me convenait parfaitement.

Je vais me concentrer ici sur l'environnement Mac, bien que les concepts discutés puissent facilement être adaptés à d'autres systèmes d'exploitation. Cette réflexion vise à offrir aux développeurs une meilleure compréhension des options disponibles, et à les aider à choisir en fonction de leur environnement de travail et de leurs préférences logicielles.

## Avec Postgres.app

L'installation via Postgres.app présente plusieurs avantages notables :

- **Interface graphique :** Bien que basique, elle apporte un confort supplémentaire dans l'interaction avec les bases de données.
- **Installation autonome :** Toutes les dépendances nécessaires sont intégrées, évitant des installations supplémentaires.
- **Flexibilité des versions :** Permet d'installer et d'exécuter plusieurs versions de PostgreSQL simultanément, facilitant ainsi le test et le développement sur différentes versions.

Ainsi, pour les développeurs qui ne s'appuient pas déjà sur Homebrew, Postgres.app constitue souvent le choix le plus judicieux, simplifiant l'expérimentation et le développement.

## Avec Homebrew

L'un des [inconvénients souvent mentionnés](https://chrisrbailey.medium.com/postgres-on-mac-skip-brew-use-postgres-app-dda95da38d74) de l'installation de PostgreSQL via Homebrew réside dans le fait qu’il mette à jour automatiquement les packages. Cela pose deux problèmes majeurs : d'abord, les mises à jour des versions majeures en local peuvent entraîner une divergence par rapport à l'environnement de production, alors qu'il est essentiel de maintenir les environnements de développement et de production aussi similaires que possible. Ensuite, une mise à jour majeure peut rendre le format de stockage utilisé incompatible, empêchant ainsi le démarrage de la base de données.

Cependant, Homebrew offre des solutions simples pour éviter ce problème. Vous pouvez préciser la version majeure à utiliser avec `@` et `brew link`. Vous pouvez également fixer la version mineure si vous le souhaitez avec la commande `pin` :

```sh
brew install postgresql@17
brew pin postgresql@17
brew link postgresql@17
```

En appliquant ces commandes, vous vous assurez que votre environnement local reflète précisément la version de votre environnement de production, réduisant ainsi les problèmes de compatibilité.

En appliquant ces commandes, vous vous assurez que votre environnement local reflète précisément la version de votre environnement de production, réduisant ainsi les risques de problèmes de compatibilité. Vous éviterez également les désagréments liés aux mises à jour automatiques de Homebrew de versions majeures qui peuvent empêcher PostgreSQL de démarrer.

## Configuration dans Rails

Que vous utilisiez Homebrew ou Postgres.app, l'intégration de PostgreSQL dans une application (Rails dans l’exemple) ne nécessite aucune configuration. Les droits par défaut ne respectent pas les bonnes pratiques pour un déploiement en production, ne posent aucun problème pour du développement. Voici pour illustration un extrait de mon `database.yml`:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development
```

C’est exactement la configuration par défaut générée par Rails lors de la création de l’application, simplement en en choisissant de configurer PostgreSQL comme base de données, sans aucune modification. Après cela je peux créer la base :

```bash
rails new myapp --database=postgresql
bin/setup
```

Ensuite, la connexion à la base de données se fait simplement via :

```bash
rails db
```

Et mon application fonctionne sans rien avoir à configuré du côté de PostgreSQL. Pas d’utilisateur à créer ou quoi que ce soit.

Un point à ne pas oublier avec Postgres.app, pour utiliser les outils en ligne de commande,  [assurez-vous d'ajouter le chemin approprié à la variable `PATH` de votre shell](https://postgresapp.com/documentation/cli-tools.html).

## Avec Docker

Intégrer PostgreSQL avec Docker dans votre développement présente une alternative potentielle à considérer.

Si votre environnement est déjà basé sur Docker et que vous êtes à l'aise avec sa configuration, tout comme en production, c’est une bonne option. Cependant, cela nécessite l'installation de Docker, ce qui pourrait entraîner des problèmes de performance sur Mac. Pour éviter ces problèmes, vous pouvez utiliser une alternative comme OrbStack à la place de Docker Desktop.

L'installation via Docker sera très avantageuse si votre configuration l’utilise déjà, car elle vous permettra de démarrer tous vos services avec. Si n’avez pas particulièrement investi dans Docker, Postgres.app ou Homebrew peuvent être de meilleures alternatives.

Enfin, avec Docker, il est possible d’utiliser la configuration simplifiée d’application décrite précédemment, mais cela dépendra de la configuration avec laquelle Docker aura installé PostgreSQL.

# Conclusion

En fin de compte, le choix de la méthode d'installation de PostgreSQL doit être guidé par une analyse approfondie de vos besoins spécifiques en matière de performances, de sécurité et de gestion des ressources. Un développeur travaillant sur un petit projet n'aura pas les mêmes attentes qu'une entreprise gérant une application complexe.

Avant de prendre une décision, évaluez la croissance potentielle de votre projet. Optez pour une solution qui non seulement répond à vos besoins actuels, mais aussi s'adapte à son évolution future.

Pour les débuts de projets ou pour les développeurs individuels, une base de données gérée peut apporter un confort considérable. À l'inverse, les entreprises avec des exigences spécifiques en matière de performance et les ressources techniques nécessaires préféreront souvent une installation sur serveur dédié ou via Docker.

Il n'existe pas de solution universelle qui serait supérieure aux autres dans tous les cas. En évaluant attentivement ces facteurs, vous pouvez choisir la solution d'installation de PostgreSQL la mieux adaptée à vos environnements. Adaptez vos choix au fil du temps pour répondre aux évolutions de votre projet.
