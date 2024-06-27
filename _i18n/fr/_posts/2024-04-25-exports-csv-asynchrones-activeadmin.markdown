---
layout: article
title:  "Des exports de données scalables et performants : activez le mode asynchrone d'ActiveAdmin"
date:   2024-04-25 21:37:00 +0200
categories: Rails ActiveAdmin
---
L'exportation de données est une fonctionnalité essentielle dans de nombreuses
applications web modernes. Dans ActiveAdmin, les exports CSV sont générés
de manière synchrone par défaut. Cependant, lorsque les données à exporter sont volumineuses,
cette approche peut entraîner un blocage prolongé des connexions HTTP,
ce qui nuit aux performances globales de l'application.

Lorsqu'une connexion reste occupée trop longtemps, cela peut épuiser
les ressources du serveur, entraînant des retards pour les utilisateurs suivants.
Si cette situation persiste et que les ressources sont complètement épuisées,
les requêtes des autres utilisateurs se retrouvent bloquées rendant
l'application inaccessible.

Pour remédier à cette situation, la gem `activeadmin-async_exporter`
a été initialement développée pour permettre la génération d'exports
de manière asynchrone via ActiveJob. Cependant, nous avons rencontré
plusieurs défis avec cette solution. Tout d'abord,
la gem activeadmin-async_exporter n'est plus maintenue
et n'est pas compatible avec les versions les plus récentes de Rails.

Lors de nos tentatives d'installation, nous avons rencontré une erreur `NameError`,
apparemment liée à des problèmes d'autoloading. De plus, la configuration des
strong_parameters n'est pas prise en compte, et la gem utilise
la méthode `current_admin_user`, alors que notre application utilise `current_user`.

Bien que ActiveAdmin permette de configurer ces aspects,
la gem `activeadmin-async_exporter` ne tient pas compte de ces configurations.

En outre, la gestion d'ActiveStorage n'est pas prise en charge par la gem,
qui utilise un autre système pour le stockage des fichiers.

Bien que la gem propose un générateur de fichiers de code pour configurer
une migration de base de données et une ressource ActiveAdmin, son utilisation
n'est pas documentée dans le README. Celui-ci mentionne simplement l'ajout de
la gem au Gemfile sans fournir de directives supplémentaires.

Face à ces limitations, nous avons décidé de reprendre le code
de la gem `activeadmin-async_exporter` dans notre application afin de
le personnaliser selon nos besoins spécifiques.

Nous n'avons pas encore publié la gem car, pour le moment, nos efforts sont concentrés
sur d'autres aspects de notre projet. Bien que le code actuel fonctionne
pour nos besoins internes, nous n'avons pas planifié de consacrer
du temps supplémentaire pour l'adapter à une éventuelle publication publique.
Nous préférons donc pour l'instant le laisser en l'état, sans toutefois exclure
définitivement la possibilité d'une publication future.

L'extraction du code nous a présenté certains défis techniques.
En particulier, le worker doit hériter de la classe ApplicationJob,
ce qui implique de placer le code dans le dossier `app/workers`.
De plus, certains aspects du code ont dû être modifiés pour assurer
sa compatibilité avec notre application.

Malgré ces difficultés, l'utilisation d'exports asynchrones
dans ActiveAdmin s'est révélée cruciale pour améliorer les performances
de notre applications. En adaptant la gem existante à nos besoins
spécifiques, nous avons pu bénéficier de cette technologie
tout en conservant un contrôle total sur son fonctionnement.

Grâce à ce processus, nous avons pu améliorer considérablement l'évolutivité
et l'efficacité de notre système, tout en offrant une expérience
plus fluide et plus réactive à nos utilisateurs.
