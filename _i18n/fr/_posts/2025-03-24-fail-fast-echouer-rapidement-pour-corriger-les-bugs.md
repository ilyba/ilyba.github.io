---
layout: article
title:  "Fail Fast : échouer rapidement pour corriger les bugs en production"
date:   2025-03-24 08:00:00 +0100
categories: Bonnes-Pratiques Ruby Rails Architecture
---

# Introduction

La stratégie 'fail fast' consiste à détecter les erreurs le plus tôt possible dans le cycle de développement ou d'exécution d'une application, afin de les corriger immédiatement et éviter qu'elles ne causent des problèmes plus graves par la suite. Cela permet d'améliorer la stabilité et la maintenabilité du code.

Dans une application Web, la qualité de service perçue par l’utilisateur repose sur votre capacité à détecter les erreurs et à les traiter rapidement.

Dans cet article, nous verrons comment les outils de monitoring permettent d’identifier et de corriger rapidement la majorité des erreurs. Nous aborderons ensuite les stratégies pour gérer des erreurs plus complexes.

# Les outils de monitoring

Dans une application Rails, les erreurs sont envoyées dans un log et si personne ne le consulte, elles passeront inaperçues à moins qu’un utilisateur ne les signale.

C’est pourquoi il est recommandé d’utiliser des outils de monitoring dédiés comme Rollbar, AppSignal ou Sentry. Ces outils permettent de gérer efficacement vos erreurs via une interface conviviale. L’installation d’un tel outil doit être une priorité dans une nouvelle application.

Ainsi, les erreurs sont regroupées, comptabilisées et triées pour vous permettre de vous concentrer sur les plus importantes. Vous êtes averti immédiatement quand elles surviennent, ce qui permet de réagir rapidement et minimise la gêne pour les utilisateurs.

# Prioriser les correctifs

Si vous avez installé votre outil de monitoring dès le début du projet, la quantité d’erreurs à traiter devrait être suffisamment faible, vous permettant de les corriger au fur et à mesure.

La stratégie est simple : lorsqu’une erreur survient, vous recevez une notification. Si le volume est faible, il est préférable d’interrompre votre travail en cours pour consulter et corriger l’erreur sur le champ.

Lorsque le volume est plus important, il devient nécessaire de prioriser. Voici quelques questions à se poser pour cela :

## Dois-je interrompre mon travail pour traiter les erreurs ?

Si les erreurs sont trop nombreuses, les interruptions risquent de retarder d’autres correctifs ou d'empêcher l’avancement de nouvelles fonctionnalités. Dans ce cas, il est plus efficace de planifier un suivi régulier des erreurs et d’intégrer leur correction dans votre flux de travail habituel minimisant ainsi l’impact des interruptions.

Par exemple, vous pouvez prendre un moment chaque jour pour lister les nouvelles erreurs, les référencer dans votre outil de planification et ajuster leur rang dans votre flux de travail selon vos priorités parmi les autres tâches.

## Quelle est l’urgence de l’erreur ?

Pensez aux conséquences de l’erreur sur vos revenus, votre réputation ou sur l’expérience utilisateur. Y a-t-il des solutions de contournement disponibles ? Ces informations vous aideront à déterminer l'ordre de priorité des correctifs dans la liste de vos tâches.

## Passez-vous assez de temps à corriger les erreurs ?

Utilisez des indicateurs chiffrés pour suivre l'évolution des erreurs. Le nombre d'erreurs augmente-t-il ou diminue-t-il ? En analysant cette tendance, vous pourrez ajuster le temps consacré à la correction.

# Résoudre les erreurs complexes avec la stratégie de l’échec rapide

Pour la majorité des erreurs, le correctif est évident. Il s’agit souvent d’un oubli lors du développement, et les informations de l’outil de monitoring sont suffisantes pour les corriger rapidement.

Cependant, certaines erreurs sont plus difficile à interpréter. Par exemple, quand une variable ou un attribut d’un objet vaut `nil` alors que le code attend une valeur.

Cela peut arriver même quand une validation est présente dans l’application. Et ce pour plusieurs raisons. Par exemple :

- Des données ont été ajoutées ou modifiées sans validation (volontairement ou non)
- La validation a été ajoutée après l’existence de données non conformes.

On se retrouve alors avec des données invalides qui causent des bugs à divers endroits de l’application, parfois difficiles à diagnostiquer.

Par exemple, si un utilisateur est supprimé dans une application sans contrainte de base de données, ses commandes peuvent devenir orphelines. Si à un autre endroit du code on essaye de trouver l'utilisateur associé à une commande on obtiendra l’erreur classique ```undefined method `name' for nil```. Pour éviter cela, une contrainte de clé étrangère garantit que la suppression d’un utilisateur est impossible si des commandes lui sont associées. Cela empêche les incohérences et rend l’erreur explicite dès qu’elle se produit.

Dans ce cas, après avoir corrigé les données incorrectes dans la base, je recommande d’ajouter une contrainte dans la base de données pour empêcher l’apparition de telles données.

Par exemple, on peut utiliser :

- une contrainte d’intégrité (`NOT NULL`, `FOREIGN KEY`, `UNIQUE`)
- Un trigger (une action déclenchée par la base de données sous certaines conditions).

De cette façon lorsque le problème se reproduit, l’outil de monitoring affichera directement le code responsable.

L'ajout de telles contraintes peut cependant soulever des inquiétudes légitimes. Voici comment y faire face.

# Dans un environnement contraint

Lorsque je propose ce type de solutions, je fais souvent face à des réticences, et ce pour de  bonnes raisons  :

- La contrainte risque d'empêcher un traitement de fonctionner normalement et d'entraîner la perte des données envoyées pour le réaliser.
- Plutôt que de corriger le problème, on ajoute des erreurs supplémentaires.

Ces réticences sont légitimes, mais l’alternative est pire : accepter de vivre avec des erreurs. À terme, les données incorrectes se multiplieront et rendront l’application instable.

De plus, la situation est temporaire. Certes, un utilisateur devra faire face à une erreur, mais on sera ainsi capable de mettre en place rapidement un correctif définitif. Avec des données validées, on obtient la garantie que l’erreur ne se produira plus jamais dans votre application.

Si le traitement est critique, vous pouvez retirer la contrainte sitôt le problème reproduit pour minimiser l’impact. Il existe des cas où même cela est inacceptable, si vous êtes confronté à un tel cas vous pouvez accepter le traitement et faire remonter une erreur, mais cette solution sera plus complexe à mettre en œuvre quand la source de l’erreur est la base de données. Vous pouvez modifier votre trigger pour ajouter des données dans une table, avec PostgreSQL vous pouvez aussi utiliser une règle (`CREATE RULE`) avec `NOTIFY`. Vous pourrez ensuite ajouter un traitement pour faire remonter les erreurs dans l’outil de monitoring.

# Avantages de cette stratégie

Cette approche illustre bien les avantages de la stratégie "fail fast" : faire échouer le système dès qu'une condition anormale est détectée.

On l’a illustré ici avec des contraintes de bases de données, mais la stratégie peut s’appliquer aussi dans d’autres contextes, en vérifiant les pré-conditions d'une méthode au début de son exécution.

En échouant rapidement, on empêche la propagation de données invalides dans le code, évitant ainsi l'ajout de logique défensive superflue et facilitant la maintenance. L’ajout de code défensif est une mauvaise stratégie : car il est généralement impossible de connaître exhaustivement les endroits nécessitant actuellement une vérification et encore moins d’empêcher les modifications futures d’oublier de faire la vérification.

# Conclusion

Moins de bugs signifie moins de temps perdu à les corriger, ce qui libère du temps pour améliorer et faire évoluer l’application. Cette approche crée un cercle vertueux où la maintenance devient plus efficace et les nouvelles fonctionnalités plus simples à implémenter.

Bien que contre-intuitive, la stratégie d’échec rapide est une bonne pratique qui réduit les bugs et simplifie la maintenance de l’application.

Moins d’erreurs signifie moins de temps perdu à les corriger, libérant ainsi des ressources pour améliorer et faire évoluer le produit. En instaurant ce réflexe, on crée un cercle vertueux : la maintenance devient plus efficace, le code plus robuste et les nouvelles fonctionnalités plus simples à implémenter.
