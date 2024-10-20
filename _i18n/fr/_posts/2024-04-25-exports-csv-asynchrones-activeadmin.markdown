---
layout: article
title:  "Exports asynchrones dans ActiveAdmin"
date:   2024-04-25 21:37:00 +0200
categories: Rails ActiveAdmin
---

# Introduction

L'exportation de données est une fonctionnalité présente dans la plupart
des applications d'entreprise. ActiveAdmin propose une fonctionnalité d'export
par défaut, cette fonctionnalité fonctionne de manière synchrone, c'est à dire
que la génération des données se fait au moment de la demande du client.

# Le problème des exports synchrones

Cependant, lorsque le volume de données à exporter est important,
le traitement peut prendre du temps. Le serveur étant occupé il n'est pas disponible
pour traiter les demandes qui s'empilent, ce qui entraine un embouteillage.
Les performances se dégradent et les utilisateurs constatent que l'application
est lente.

Si la situation se dégrade, le bouchon devient alors trop important,
et le serveur n'est plus en mesure de les requêtes dans les délais. L'application
se met alors à renvoyer des erreurs. Si la situation continue à se détériorer,
l'application cesse alors complètement de fonctionner et devient inaccessible.

# Mise en place d'une solution asynchrone

Confrontés à ce type de problème, nous avons utilisé
la gem [`activeadmin-async_exporter`](https://github.com/rootstrap/activeadmin-async_exporter)
pour y remédier. Cette librairie permet de générer des exports de données
dans ActiveAdmin de manière asynchrone avec ActiveJob. Cependant, nous avons
dû faire des adaptations pour pouvoir utiliser cette solution.

Tout d'abord, la gem `activeadmin-async_exporter` n'est plus maintenue
par son auteur et n'était pas compatible avec notre version de Rails.
Nous avons donc du la modifier et mettre à jour ses dépendances.

Nous avons faits quelques adaptations supplémentaires afin de gérer les
paramètres avec strong_parameters et résoudre un problème
de méthode manquante due à l'utilisation de `current_user` dans notre application
alors que l'auteur gem utilise `current_admin_user`.

Contrairement à notre application, la gem n'utilise pas ActiveStorage
pour les pièces jointes. Nous avons donc également adapté cette partie.

Pour enregistrer la demande, la gem fournit un générateur pour la migration
pour créer les tables nécessaire en base de données. La gem fournit également
un générateur ActiveAdmin pour l'interface permettant de gérer les exports.
Cependant, ces générateurs ne sont pas documentés.

Nous avons donc finalement repris le code de la gem directement dans notre
application et nous l'avons personnalisé selon nos besoins.

# Publication dans une gem

Nous avons décidé de ne pas publier nos modifications sous forme d'une nouvelle gem
car le code est intégré à notre application, et cela demanderait un nouvel effort d'adaptation.
Par ailleurs, vu le peu d'activité sur cette librairie, je ne suis pas convaincu
que cette solution réponde forcément à un besoin de la communauté. Même si ça s'est
révélé très utile pour améliorer les performances de notre application.

Néanmoins si ces modifications vous intéressent, si vous avez des questions
ou des commentaires n'hésitez pas à me contacter pour en savoir plus.

# Conclusion

Cette anecdote illustre au travers d'un exemple concret le type problématique
qui peut se poser au cours de l'évolution d'une application. La solution basée
sur l'utilisation et l'adaptation d'une gem peu populaire et non maintenue
peut sembler atypique, mais cette approche suit en réalité un processus très classique
de résolution d'un problème technique.
