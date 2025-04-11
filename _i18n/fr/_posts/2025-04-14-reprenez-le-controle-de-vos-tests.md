---
layout: article
title:  "Reprenez le contrôle des tests de votre application"
date:   2025-04-14 08:00:00 +0200
categories: Bonnes-Pratiques Ruby Rails Architecture Développement Tests
---

# Introduction

Découvrez comment transformer une application instable et peu testée en un produit robuste grâce à des pratiques de tests efficaces.

Lorsqu’on débarque sur un jeune projet de start-up, on est souvent confronté à des lacunes sur certaines bonnes pratiques. Et il n’est pas toujours évident de savoir par où commencer.

Dans cet article, après une présentation rapide du contexte, je vais vous présenter une approche efficace en quatre étapes simples pour améliorer rapidement et votre suite de tests sans compromettre la productivité : stabilisation, mise en place de bonnes pratiques, nettoyage des tests existants et optimisation.

# Au départ : peu de tests et beaucoup de bugs…

L’historique d’une application Web est toujours complexe. La base de code évolue avec ses développeurs et passe par différentes phases qui sont propres à l’histoire de chaque projet. Suivant que le projet commence avec une grande équipe d’ingénieurs expérimentés avec un budget conséquent ou qu’il démarre au contraire avec une petite équipe de développeurs fraîchement diplômés, les défis ne sont pas les mêmes.

Le projet dont je parle ici est parti avec des développeurs d’expérience intermédiaire, un projet ambitieux et un budget serré. La stratégie appliquée a donc été de privilégier un développement rapide avec un effort porté sur les tests et les bonnes pratiques, bien que limité par les contraintes.

L’application était tellement insuffisamment testée que cela affectait sa stabilité.

# Phase 1 : Agir vite pour améliorer la stabilité

De grandes parties critiques du code étaient insuffisamment couvertes. Pour corriger le problème nous avons utilisé les tests système de Rails. Le principe d’un tel test est de piloter automatiquement un navigateur. En clair, le code du test indique au navigateur la page sur laquelle naviguer et les actions à exécuter (cliquer sur des liens, remplir des formulaires) puis vérifie le résultat obtenu. Par rapport à d’autres types de tests, ces tests sont plus lents mais en contrepartie ils permettent de tester l’interactivité du site.

Dans notre cas, un de nos tests consistait à remplir un enchaînement de plusieurs formulaires afin de tester un cas d’utilisation complet. Cette approche avait l’avantage de pouvoir ajouter rapidement des tests qui couvrent une grande partie du projet.

L’approche était plutôt adaptée à la situation, mais avait tout de même des inconvénients :

Ces tests vieillissent mal : au fur et à mesure que l’application évolue et se complexifie, les tests deviennent également plus complexes et plus fragiles. Par exemple, nous avons ajouté un composant qui permet la saisie automatique des adresses, et nous saisissions beaucoup d’adresses dans nos formulaires. Ce composant est complexe et son utilisation répétée rend le test long et plus susceptible d’échouer aléatoirement. Et au bout d’un moment, le test finit par nécessiter des ajustements et des corrections constamment.

Et bien que ce type de test a été développé pour corriger une situation de départ problématique, certains développeurs s’en sont servis comme exemple pour de nouvelles fonctionnalités.

Bien que cette approche soit adaptée au départ pour résoudre rapidement une situation problématique, anticiper l’évolution du code est essentiel.

# Phase 2 : Instaurer des bonnes pratiques durables

Pendant un moment, la situation est satisfaisante, même si les tests sont plus lents qu’ils ne le devraient, et que certaines parties du code ne sont pas testées correctement, la stabilité de l’application est acceptable et la productivité de l’équipe est bonne.

Mais au bout d’un certain temps, on voit le taux d’échec en raison de tests floconneux augmenter, et parallèlement à ça, la durée des tests augmente considérablement ce qui commence à poser des problèmes de productivité.

Nous décidons donc d’être plus exigeants sur nos tests et d’appliquer ces principes :

- Nous souhaitons augmenter la couverture de tests sans toutefois tomber dans l’extrême inverse. Les développeurs sont encouragés à être vigilants et à écrire plus de tests. Cela nous permet d’être plus confiants lorsque nous devons modifier du code existant. Au départ, cette mesure peut paraître un peu superflue, mais au fur et à mesure que le projet se complexifie, avoir une bonne couverture fonctionnelle est essentiel pour éviter les régressions.
- Nous demandons aussi de privilégier les autres types de tests aux tests systèmes. Cela permet d’améliorer facilement les performances. Par exemple, un test consistant à soumettre un formulaire et à observer le résultat peut être remplacé par un test de contrôleur. À l’exécution, c’est bien plus rapide qu’un test système.
- L’utilisation de `sleep` dans les tests est strictement interdite, et un plan d’action est établi pour supprimer sleep dans tous les tests historiques ou bien pour supprimer les tests en question.
- On réserve l’utilisation de ces tests aux composants qui utilisent le JavaScript. Et dans le même temps, on limite au maximum l’utilisation du JavaScript dans l’application.

La mise en place de ces quelques règles nous a permis rapidement de gagner en stabilité. En revanche, cela ne permet pas de résoudre les problèmes des tests existants. Et pour le futur, nous nous assurons que la quantité et la durée des tests n’augmentent pas trop rapidement avec le temps.

# Phase 3 : Nettoyage des tests existants

Une fois que les bonnes pratiques sont appliquées, il est temps de s’occuper de l’historique.

Plutôt que de conserver des tests coûteux et fragiles, il est souvent préférable de les remplacer par des tests unitaires ou d'intégration plus ciblés.

Grâce aux bonnes pratiques, la majorité des tests systèmes destinés à pallier les lacunes sont couverts par des tests plus ciblés et plus stables. Les autres couvrent souvent des fonctionnalités très stables qui ne devraient pas être amenées à changer. Dans ces deux cas, on peut donc simplement supprimer les tests originaux.

On termine notre nettoyage en identifiant les tests les plus longs et les tests redondants.

Pour trouver les tests longs, on peut utiliser la commande suivante :

```ruby
rails test -v | sort -t = -k 2 -g
```

Cette commande exécute les tests Rails en mode verbeux, trie les résultats par durée d'exécution et affiche les tests les plus longs en premier.

Pour identifier les tests redondants, il n’y a pas de commande simple, mais on peut les détecter au fur et à mesure du développement. Si une modification fait échouer plusieurs tests, il y a suspicion de redondance inutile.

Résultat, en appliquant quelques principes simples, on a gagné près de 30 % de temps sur l’exécution de la suite de tests en passant d’un peu moins de 20 minutes à moins de 15 minutes.

# Phase 4 : Une approche pragmatique pour gagner en performance

On aurait pu passer plus de temps à optimiser, mais c’est un travail de longue haleine qui nécessite un audit complet et détaillé de tous nos tests. Quand les tests peuvent être supprimés ou rapidement modifiés c’est bien. Mais parfois, cela demande un effort plus coûteux.

Dans ce cas, mieux vaut se contenter d’appliquer les bonnes pratiques énoncées plus tôt, et pour le reste, nous avons adopté des stratégies pragmatiques pour optimiser les performances :

- On a changé de prestataire pour un autre plus rapide, plus flexible et qui ne coûtait pas spécialement plus cher.
- On en a profité pour répartir le travail sur plusieurs machines exécutant les tâches en parallèle.

Résultat : on est passé d’un peu moins de 15 minutes à 6 minutes.

C’est un bon résultat, mais s’il n’est pas associé à de bonnes pratiques au moment de l’écriture, le nombre de tests va augmenter, cela nous poussera à augmenter le nombre de machines exécutant les tests en parallèle et fera grimper les coûts.

# Conclusion : une suite de tests bien maintenue

Cette approche progressive nous a permis d’atteindre une situation plus que satisfaisante malgré un point de départ problématique. En partant des urgences les plus critiques, puis en établissant des règles durables avant de corriger l’héritage problématique et de finir par un nettoyage ciblé, nous avons maximisé l’impact de nos actions sans gaspiller de temps par rapport à une approche trop systématique.

Cette méthode pragmatique et itérative est particulièrement adaptée aux projets de refactorisation massive où il est bénéfique de commencer par une approche globale pour traiter rapidement le plus gros avant d’affiner les détails. C’est une démarche simple et efficace qui peut s’appliquer à bien d’autres domaines du développement logiciel, dès qu’il s’agit de reprendre le contrôle sur une base de code un peu négligée.

Finalement, la clé reste la même : avancer par étapes, avec des gains rapides au départ et une amélioration continue sur le long terme. Cette méthode permet de reprendre progressivement le contrôle sur une base de code complexe tout en maintenant la stabilité et la productivité de l’équipe.
