# Alose_ABC
Modèle ABC d'estimation d'effectif d'aloses femelles

L'utilisateur entre un jeu de données constitué pour chaque date de la saison de reproduction du nombre de bulls détectés et de la température de l'eau. A partir de ces données, d'une gamme a priori du nombre de femelles, et de plusieurs hypothèses concernant le comportement individuel de reproduction des aloses femelles, le modèle simule les bulls générés par un certain nombre de femelles pendant la saison de reproduction, et y applique le plan d'échantillonnage réellement suivi pour la collecte de données. Les données simulées peuvent alors être comparées aux données réelles. Un algorithme ABC (Approximate Bayesian Computation) exécute ces simulations plusieurs fois avec un nombre différents de femelles, compare la dissemblence entre les données simulées et les données réelles, et produit une distribution a posteriori du nombre d'aloses femelles dans la population.

Le modèle est fourni sous la forme d'une application Shiny, exécutable en ligne ici : https://ctentelier.shinyapps.io/Alose_ABC/

Les scripts correspondants sont dans les fichiers server.R et ui.R

L'aide pour utiliser l'application est dans le fichier aide appli Alose_ABC.html

Le fichier bulls_audio_&_temperature_Nivelle_2018.csv est le fichier de données concernant l'enregistrement des bulls et de la température sur la Nivelle en amont d'Uxondoa en 2018. Il peut être utilisé comme exemple pour faire tourner le modèle et pour aider l'utilisateur à formater son propre fichier de données.

Le rapport dans lequel est présenté le modèle et l'expérience ayant servi à déterminer les paramètres décrivant le comportement individuel de reproduction est dans le fichier rapport_alose_AFB_INRA_2018_015_1.pdf


Contact : cedric.tentelier@univ-pau.fr
