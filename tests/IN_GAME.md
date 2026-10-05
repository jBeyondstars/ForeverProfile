# Validation dans WoW Forever

Client cible observé : 1.60.1, build 70170, Interface 16001. Le client bêta évoluant, relever `/fp diagnostics` avant chaque session de vérification.

- [ ] Nouveau lancement du client : addon visible, aucune erreur Lua à la connexion, aucune modification graphique automatique.
- [ ] `/fp`, entrée Options → AddOns et raccourci d’ouverture fonctionnent ; Échap ferme fenêtre et dialogues.
- [ ] Interface à différentes résolutions et échelles UI ; texte français/anglais lisible, listes longues accessibles au défilement.
- [ ] Créer deux configurations natives différentes **après Appliquer** ; capturer chacune, puis vérifier les valeurs au retour dans les options.
- [ ] Allers-retours entre les profils : réglages détaillés, valeurs personnalisées, anticrénelage, échelle de rendu et limites FPS fidèles.
- [ ] Vérifier les réglages séparés de raid/champ de bataille et leur activation native. Tester en extérieur et en instance.
- [ ] Favoris : trois profils maximum ; poignée et fond déplacent la barre sans ouvrir la fenêtre ; le bouton FP ouvre la fenêtre et les boutons de profils les appliquent en un clic.
- [ ] Taille des favoris : curseur 60–180 % et molette sur la poignée redimensionnent boutons et texte ensemble ; taille conservée au rafraîchissement, à l’ajout/retrait d’un favori et après `/reload`.
- [ ] Verrouillage : cocher masque la poignée sans espace vide, bloque le glissement du fond et garde FP/favoris utilisables ; décocher restaure le déplacement. État conservé après `/reload` et redémarrage.
- [ ] Restauration : restitue la configuration précédant la dernière bascule ; une application déjà active ne remplace pas cette sauvegarde.
- [ ] Renommer/dupliquer ; confirmer/annuler mise à jour et suppression ; leurs effets restent distincts.
- [ ] Modifier un réglage depuis les options du jeu : le statut du profil change sans écraser sa sauvegarde.
- [ ] Avec Leatrix Plus et sa météo forcée, vérifier que tout écart est signalé comme application partielle, avec un détail lisible.
- [ ] Bascule en combat : aucun taint ; réglages refusés signalés ; effets importants toujours lisibles selon le profil choisi.
- [ ] Déterminer les options dont l’effet exige une opération supplémentaire, malgré une CVar correctement relue.
- [ ] `/reload`, déconnexion/reconnexion puis arrêt normal/redémarrage : profils, favoris et positions conservés. Restauration temporaire réinitialisée.
- [ ] Sans fenêtre ni barre visibles, absence de boucle de traitement permanente ; comparer les FPS dans une même scène.
