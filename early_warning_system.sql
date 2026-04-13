/* ====================================================================================
   SCRIPT : Détection des Impayés Consécutifs & Priorisation des Appels (T-SQL)
   AUTEUR : Francesca TISNES
   SGBD   : MS SQL Server
   NIVEAU : Avancé (CTE, Window Functions, Agrégations conditionnelles)
   ==================================================================================== */

-- 1ère CTE : On cible les données récentes et on identifie les impayés purs
WITH Analyse_Echeances AS (
    SELECT 
        c.ID_Client,
        e.Date_Echeance,
        -- Un impayé est avéré si le montant payé est strictement inférieur au montant attendu
        CASE 
            WHEN e.Montant_Paye < e.Montant_Attendu THEN 1 
            ELSE 0 
        END AS Est_Impaye
    FROM 
        Echeances e
    INNER JOIN 
        Credits c ON e.ID_Credit = c.ID_Credit
    WHERE 
        -- Filtre sur les 3 derniers mois via la fonction spécifique SQL Server DATEADD()
        e.Date_Echeance >= DATEADD(MONTH, -3, GETDATE())
),

-- 2ème CTE : Utilisation de LAG() pour vérifier la consécutivité des impayés
Historique_Consecutif AS (
    SELECT 
        ID_Client,
        Date_Echeance,
        Est_Impaye,
        -- LAG permet de regarder le statut du mois précédent pour ce même client
        -- PARTITION BY isole le calcul par client, ORDER BY garantit la chronologie
        LAG(Est_Impaye, 1) OVER(PARTITION BY ID_Client ORDER BY Date_Echeance) AS Impaye_Mois_Precedent
    FROM 
        Analyse_Echeances
),

-- 3ème CTE : On isole uniquement les clients ayant déclenché l'alerte "2 mois de suite"
Clients_Alerte AS (
    SELECT DISTINCT 
        ID_Client
    FROM 
        Historique_Consecutif
    WHERE 
        Est_Impaye = 1 
        AND Impaye_Mois_Precedent = 1 -- La condition métier critique est validée ici
)

-- REQUÊTE FINALE : Jointure avec le référentiel pour calculer l'exposition et classer
SELECT 
    cl.ID_Agence,
    cl.ID_Client,
    -- On somme l'exposition totale du client (s'il a plusieurs crédits)
    SUM(cr.EAD_Actuel) AS Exposition_Totale_Risque,
    
    -- DENSE_RANK permet de classer les clients par agence, du plus risqué au moins risqué
    DENSE_RANK() OVER(
        PARTITION BY cl.ID_Agence 
        ORDER BY SUM(cr.EAD_Actuel) DESC
    ) AS Priorite_Appel_Agence

FROM 
    Clients_Alerte ca
INNER JOIN 
    Clients cl ON ca.ID_Client = cl.ID_Client
INNER JOIN 
    Credits cr ON ca.ID_Client = cr.ID_Client
GROUP BY 
    cl.ID_Agence,
    cl.ID_Client

-- Optionnel : Ne garder que le top 5 des clients à appeler par agence pour ne pas noyer le conseiller
-- (Nécessiterait d'encapsuler la requête finale dans une dernière CTE pour filtrer sur Priorite_Appel_Agence <= 5)
ORDER BY 
    cl.ID_Agence, 
    Priorite_Appel_Agence;
