# 🏦 Détection d'Anomalies Bancaires : "Early Warning System" (SQL Server)

> **Projet de modélisation logique et de requêtage avancé en T-SQL.**
> *Ce dépôt contient la résolution d'un problème métier bancaire complexe, documentée ligne par ligne.*

## 📋 Contexte Métier
Le département de Pilotage des Risques d'une banque de détail souhaite identifier de manière proactive les clients présentant un risque de défaut imminent (Early Warning System). L'objectif est de fournir aux directeurs d'agences une liste priorisée de clients à contacter.

**La Règle de Gestion (Business Rule) :**
Un client est considéré "À Risque Critique" s'il a cumulé **au moins 2 échéances impayées consécutives** au cours des 3 derniers mois.

## 🗄️ Architecture des Données (Hypothèse)
Le système repose sur 3 tables relationnelles :
1. `Clients` (ID_Client, ID_Agence, Nom, Segment)
2. `Credits` (ID_Credit, ID_Client, EAD_Actuel) *-> EAD = Exposure At Default (Capital Restant Dû)*
3. `Echeances` (ID_Credit, Date_Echeance, Montant_Attendu, Montant_Paye)

## 🎯 Objectif Technique
Rédiger une requête SQL Server (T-SQL) unique, optimisée et sans sous-requêtes imbriquées obsolètes, qui :
1. Isole les impayés des 3 derniers mois.
2. Détecte la consécutivité des impayés via des fonctions de fenêtrage (Window Functions).
3. Calcule l'exposition totale (EAD) du client.
4. Classe les clients à contacter en priorité (ceux avec la plus forte exposition) par agence.

---
*Le code de résolution détaillé se trouve dans le fichier `early_warning_system.sql`.*
