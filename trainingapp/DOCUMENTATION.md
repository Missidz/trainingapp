# Shadow Gym - Documentation Technique

## Vue d'ensemble

Shadow Gym est une application iOS d'entraînement inspirée de l'univers Solo Leveling. Elle utilise un système de progression RPG avec niveaux, XP et quêtes pour gamifier l'expérience d'entraînement.

## Architecture de l'Application

### Structure des Fichiers

```
trainingapp/
├── trainingappApp.swift        # Point d'entrée, configuration SwiftData
├── Item.swift                  # Modèles de données (User, Workout, Exercise, Quest, etc.)
├── ContentView.swift           # Interface principale avec TabView
├── WorkoutView.swift           # Interface d'entraînement
├── ProgressViews.swift         # Système de progression et quêtes
└── NutritionViews.swift        # Interface de nutrition
```

## Modèles de Données (Item.swift)

### User - Profil Utilisateur
- **Niveau et XP** : Système RPG avec reset d'XP à chaque niveau
- **Titres progressifs** : Newbie Hunter → Fighter → Warrior → Elite Hunter → Shadow Warrior → Shadow Monarch
- **Statistiques** : Nombre total d'entraînements, date de création

### Workout - Séances d'Entraînement
- **Métadonnées** : Nom, date, durée, notes
- **Difficulté** : Easy (80% XP) → Normal (100%) → Hard (130%) → Nightmare (170%)
- **Mode Éveil** : Bonus +50% XP pour les séances spéciales
- **Calcul XP adaptatif** : Basé sur volume, durée, intensité

### Exercise - Exercices Individuels
- **Paramètres** : Nom, séries, répétitions, poids, temps de repos
- **Types** : Force (+20% XP), Cardio (normal), Flexibilité (-20%), Endurance (+10%)
- **Volume total** : Calculé pour les statistiques

### Quest - Système de Quêtes
- **Types** : Quotidiennes, hebdomadaires, mensuelles, spéciales
- **États** : En cours → Complétée → Réclamée
- **Progression automatique** : Basée sur les données d'entraînement
- **Récompenses XP** : Intégrées au système de progression

## Interface Utilisateur

### ContentView.swift - Navigation Principale
- **TabView animé** : 5 onglets (Home, Training, Nutrition, Progress, Quests)
- **Thème sombre** : Inspiré Solo Leveling avec effets lumineux
- **Animations fluides** : Transitions entre onglets

### WorkoutView.swift - Interface d'Entraînement
- **Gestion temps réel** : Chronométrage, ajout d'exercices en live
- **Configuration dynamique** : Difficulté, mode éveil, exercices
- **Prévisualisation XP** : Calcul en temps réel pendant l'entraînement
- **Sauvegarde intelligente** : Persistance avec SwiftData

### ProgressViews.swift - Progression et Quêtes
- **LevelProgressCard** : Affichage niveau, XP, titre avec animation circulaire
- **QuestsDashboard** : Onglets Daily/Weekly/Achievements
- **Tracking automatique** : Mise à jour des quêtes basée sur activité
- **Système de récompenses** : Réclamation d'XP avec validation

## Système d'XP Adaptatif

### Calcul pour les Entraînements
```swift
XP Total = (Volume de Base + Bonus Durée) × Multiplicateur Difficulté × Bonus Éveil × Facteur Intensité
```

#### Composants du Calcul :
1. **Volume de Base** : Séries × Répétitions × Facteur Poids
2. **Bonus Durée** : 50%-130% selon durée optimale (45min)
3. **Multiplicateur Difficulté** : Easy (80%) → Nightmare (170%)
4. **Bonus Éveil** : +50% pour les séances spéciales
5. **Facteur Intensité** : Volume par minute d'entraînement

### Progression des Niveaux
- **Formule** : Niveau × 100 XP pour atteindre le niveau suivant
- **Reset d'XP** : L'XP excédentaire est reportée au niveau suivant
- **Titres évolutifs** : Changent selon les paliers de niveau

## Système de Quêtes

### Quêtes Quotidiennes
- **Premier Entraînement** : 1 séance (+50 XP)
- **Volume Builder** : 50 répétitions totales (+75 XP)
- **Endurance** : 30 minutes d'entraînement (+60 XP)

### Quêtes Hebdomadaires
- **Guerrier Hebdomadaire** : 5 entraînements (+250 XP)
- **Constructeur de Force** : 1000kg total soulevé (+300 XP)
- **Consistance** : 3 jours différents d'entraînement (+200 XP)

### Tracking Automatique
- **Calculs temps réel** : Basés sur les données d'entraînement
- **Validation périodique** : Vérification quotidienne/hebdomadaire
- **États visuels** : En cours → Complétée → Réclamée

## Persistance des Données

### Configuration SwiftData
- **Modèles intégrés** : User, Workout, Exercise, Quest, Meal, FoodItem, NutritionGoals
- **Persistance garantie** : Stockage sur disque avec fallback
- **Gestion d'erreurs** : Récupération automatique en cas de corruption
- **Migration automatique** : Suppression/recréation si nécessaire

### Synchronisation Temps Réel
- **Queries SwiftData** : Mise à jour automatique des vues
- **Calculs distribués** : XP calculé à plusieurs niveaux (exercice → workout → user)
- **Consistance garantie** : Toutes les vues affichent les mêmes données

## Fonctionnalités Avancées

### Interface Adaptative
- **Presets d'entraînement** : 3×10, 4×8, 5×5, 3×12 pour configuration rapide
- **Boutons visuels** : +/- pour ajuster sets/reps facilement
- **Incréments intelligents** : Poids par pas de 2.5kg

### Design Immersif
- **Thème Solo Leveling** : Noir avec accents bleus/violets
- **Effets visuels** : Ombres, gradients, animations
- **Feedback visuel** : Barres de progression, indicateurs d'état

### Système de Debug
- **Logs détaillés** : Suivi de toutes les opérations XP
- **Reset développeur** : Réinitialisation complète des données
- **Validation temps réel** : Vérification de la cohérence des calculs

## Performance et Optimisation

### SwiftData
- **Requêtes optimisées** : @Query avec filtres spécifiques
- **Lazy loading** : Chargement à la demande des relations
- **Mise en cache** : Propriétés calculées optimisées

### Interface
- **Animations fluides** : 60 FPS avec Core Animation
- **Gestion mémoire** : Libération automatique des ressources
- **Responsive design** : Adaptation aux différentes tailles d'écran

## Tests et Validation

### Scénarios Testés
- **Création utilisateur** : Premier lancement avec profil vide
- **Calculs XP** : Validation de toutes les formules
- **Progression quêtes** : Vérification des seuils et récompenses
- **Persistance** : Données conservées entre redémarrages

### Cas d'Edge
- **Level up multiple** : XP suffisant pour plusieurs niveaux
- **Quêtes simultanées** : Plusieurs quêtes complétées en même temps
- **Données corrompues** : Récupération automatique
- **Performances** : Gestion de gros volumes de données

## Évolutions Futures

### Fonctionnalités Prévues
- **Social** : Comparaison avec amis, classements
- **Nutrition avancée** : Scan code-barres, base de données alimentaire
- **Achievements** : Système de succès débloquables
- **Statistiques avancées** : Graphiques détaillés, tendances

### Améliorations Techniques
- **CloudKit** : Synchronisation multi-appareils
- **HealthKit** : Intégration données santé iOS
- **Notifications** : Rappels d'entraînement intelligents
- **Apple Watch** : Companion app pour suivi en temps réel

---

*Documentation générée automatiquement - Shadow Gym v1.0* 