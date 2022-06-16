# Projet dbt fdr-eaupotable

Projet de traitement du cas d'usage FDR Bornes de recharge. En DBT.

## TODO :

- clean dbt_project.yml
- canalisations_en_service :
  - clean from_csv (mapping), retest apcom, move it (& fdr_source_union, fal scripts/ ...) out of apcom project
  - schema test, non regression test, profiles.yml accordingly
  - alternative dictionnaire des données
  - publish, without fieldPrefix (or only add it after "echange" format ?)
- reparations :
  - example / definition, _parsed/translated,
  - LATER rapprochement géographique
- canalisations_abandonnees : mutualiser avec canalisations_en_service ? avec ou sans "s" ?