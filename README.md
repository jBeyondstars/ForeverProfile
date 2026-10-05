# Forever Profiles

Addon pour WoW Forever **1.60.1 / Interface 16001**. Enregistre tes réglages graphiques personnalisés et passe d’une configuration à une autre depuis une fenêtre compacte, une barre de favoris ou un raccourci clavier.

## Démarrer

Copie le contenu de ce dépôt dans `Interface/AddOns/ForeverProfiles` de ton client WoW Forever. Le fichier `ForeverProfiles.toc` doit se trouver directement dans ce dossier. S’il a été ajouté pendant que WoW était ouvert, redémarre le jeu pour qu’il découvre ce nouveau dossier. Active **Forever Profiles** dans la liste des addons.

1. Configure les graphismes dans les options natives et clique sur **Appliquer**.
2. Ouvre `/fp`, puis **Enregistrer les réglages**. Nomme le profil « Haute qualité ».
3. Configure et applique tes réglages de performance dans le jeu, puis enregistre un deuxième profil.
4. Sélectionne le profil souhaité et clique sur **Appliquer le profil**.
5. Ajoute jusqu’à trois favoris et active **Afficher la barre de favoris** pour changer en un clic.

La sélection d’un profil sert à le consulter. Seul le bouton d’application change les réglages. Les créations et duplications capturent ou copient les réglages sans les appliquer. Aucun profil n’est automatiquement appliqué à la connexion.

## Fonctions

- Jusqu’à **40 profils**, avec renommage, duplication, mise à jour et suppression. Les deux dernières actions demandent confirmation.
- Configuration générale, configuration raid/champ de bataille et activation du mode raid distinct sauvegardées ensemble, lorsque ces options sont exposées par le client.
- Échelle de rendu, anticrénelage, synchronisation verticale et limites de FPS accessibles sur le client.
- Barre déplaçable de **3 favoris** : fais glisser sa poignée ou son fond pour la déplacer. Le bouton **FP** ouvre la fenêtre principale.
- Case **Verrouiller la barre** dans `/fp` : fixe la position et masque la poignée de déplacement. Les boutons restent utilisables. Décoche-la pour déplacer à nouveau la barre ; le verrouillage est conservé entre les sessions.
- Taille de la barre réglable de **60 à 180 %** dans la fenêtre principale, ou avec la molette sur la poignée. Boutons et texte changent de taille ensemble. Position et taille sont conservées entre les sessions.
- **Largeur et hauteur indépendantes** dans `/fp` : largeur de 160 à 1 000, hauteur de 28 à 120. Les boutons se répartissent dans la barre sans étirer le texte. Les dimensions sont définies avant l’échelle globale ; elles sont conservées entre les sessions. **Largeur auto** rétablit l’adaptation au nombre de favoris. Si l’écran est trop petit, chaque dimension est limitée séparément à l’espace disponible.
- **Restaurer les réglages précédents** revient à l’état capturé avant la dernière bascule. Cette sauvegarde temporaire reste disponible pendant la session ; `/reload` ou un redémarrage l’efface.
- États **Actif**, **Modifié**, **Appliqué partiellement** calculés à partir des valeurs actuelles. Après un échec partiel, les écarts sont affichés dans le profil, avec leur cause en infobulle.
- Fenêtre déplaçable, adaptation aux petits écrans et fermeture par Échap.
- Français sur un client `frFR`, anglais sur les autres clients.
- Raccourcis configurables dans **Options → Raccourcis clavier → Forever Profiles** : fenêtre, trois favoris et restauration. Entrée dans **Options → AddOns** également disponible.

## Commandes

| Commande | Action |
| --- | --- |
| `/fp` ou `/foreverprofiles` | Ouvrir / fermer la fenêtre |
| `/fp save Haute qualité` | Enregistrer les réglages actuels sous ce nom |
| `/fp apply Haute qualité` | Appliquer le profil nommé |
| `/fp restore` | Restaurer l’état précédant la dernière bascule |
| `/fp quick` | Afficher / masquer la barre de favoris |
| `/fp list` | Afficher les profils et leurs états |
| `/fp diagnostics` | Afficher la version et le nombre d’options accessibles |

## Stockage et compatibilité

Les profils et positions sont enregistrés dans `ForeverProfilesDB`, une SavedVariable commune aux personnages du compte sur cette installation. WoW écrit ces données lors d’un `/reload` ou d’une déconnexion normale. Un arrêt brutal peut perdre les derniers changements.

Le moteur utilise une liste explicite d’options graphiques, des valeurs bornées et une vérification après toutes les écritures, puis une seconde vérification différée. Il ignore les options absentes lors d’une capture et signale celles devenues indisponibles lors d’une application. Les réglages repris par un autre addon, notamment la météo de Leatrix Plus, peuvent donc apparaître comme différents.

Les options de résolution, moniteur, plein écran, moteur graphique, GPU et HDR sont hors du périmètre de cette version. Les CVar expérimentales et les réglages directs de résolution/cascades des ombres ne sont pas écrits. Aucun preset « minimum » n’est imposé : les profils restituent tes choix, y compris les effets de combat.

Les changements en combat sont tentés via les API ordinaires ; les refus du client sont signalés. Ils ne sont pas appliqués silencieusement plus tard. Un réglage relu correctement prouve la valeur de configuration, mais une éventuelle nécessité de rechargement du moteur graphique doit encore être qualifiée dans le client Forever.

## Développement et vérification

- `Init.lua` : version, traductions et intitulés des raccourcis.
- `Graphics.lua` : catalogue, capture, validation, application, comparaison et résumé.
- `Profiles.lua` : stockage versionné et opérations sur les profils.
- `UI.lua` : fenêtre, dialogues et barre de favoris.
- `Core.lua` : cycle de vie, orchestration, restauration, commandes et intégration aux options.
- `Bindings.xml` : raccourcis, découverts automatiquement par le chargeur dédié du jeu. Ce fichier utilise la racine `<Bindings>` sans namespace UI et ne doit pas être ajouté au TOC.

Depuis le dossier du dépôt, exécute `python tests/run.py`. Le runner nécessite Python et `lupa` avec son runtime Lua 5.1 (`python -m pip install lupa`). Il vérifie la syntaxe Lua 5.1, les fichiers du TOC, les raccourcis XML et le comportement dans un client simulé. Aucune configuration du jeu n’est modifiée par les tests. L’aperçu optionnel (`--preview chemin.png`) utilise aussi Pillow et les polices Windows.

La validation réelle de l’affichage, des effets graphiques, du combat et de la persistance du client reste à effectuer avec [la checklist en jeu](tests/IN_GAME.md).
