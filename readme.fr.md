LSLVoter
Ce script permet de faire un vote simple en tenant compte du lag et des actions simultanées.

##Installation##
Créez 4 primitives :
 - une grosse boite noire qui contientra le script
 - 3 petites boites (une pour le Oui, une pour le Non et une pour l'abstention)
 - lier ces objets en mettant la grosse boite noire en tant qu'objet maitre.
 - mettre le script dans l'objet maitre.
 - ajouter une notecard nommée : "voters" dans laquelle il y a un votant par ligne écrite comme suit :
 ```
 nom_avatar1=14481de0-8143-11e4-b4a9-0800200c9a66
 
 nom_avatar2=14481de0-8143-11e4-b4a9-0800200c9a67
 ```
 le nom de l'avatar dans la notecard sert juste à lister les absents mais les présents auront ce nom remplacé par le vrai grâce à l'uuid.
 - editer le script pour changer les textes si vous voulez et surtout changer le LISTEN_CHANNEL
 - utilisez le listen channel pour les commandes : /42 help

##Utilisation##
La personne gérant le vote (le owner de l'objet) remplit la note card puis initialise le script avec la commande "reset" (ex: /42 reset)

Le script ecrit dans le chat pour lister les membres de la notecard qui sont présents et les absents.

Le owner change le nom du vote avec "name" (ex: /42 name:etes vous pour cette idee ?)

Les utilisateurs peuvent
 - soit demander des infos sur eux avec "my" (ex: /42 my),
 - soit voter en cliquant sur une des 3 boites (vert = oui, rouge = non et blanc = abstention),
 - soit voter par le clavier avec "vote" (ex: /42 vote:Oui)
 (attention, le vote par clavier peut etre lu par tout petit malin utilisant un script)

note: tout le monde peut changer d'avis et changer de vote tant que le owner a pas cloturé le vote.

Une fois le temps écoulé, le owner avertit les votants de la fin du vote et lance un "stop" (ex: /42 stop)

La machine affiche la liste des votants, absents et non voté puis liste des codes avec le résultat des votes.

Le owner relance alors la machine avec un "reset" pour le vote suivant.
 
##Explication du code##
A chaque reset de la machine, un nouveau code est attribué à chaque votant présent. (ex: yfej4)

Quand je vote, la machine me dit quel est mon code et ce pour quoi j'ai voté (ex: yfej4:Oui)

Les utilisateurs peuvent voir leur code en utilisant "my".

A la fin du vote, tous les votes sont affichés avec chaque code,
ce qui permet à chacun de voir la valeur qui a été comptabilisée pour son vote.

Personne ne peut connaitre à qui correspond quel code à part la personne à qui il appartient.
 
