# Projet dbt fdr-eaupotable

Projet de traitement du cas d'usage FDR Bornes de recharge. En DBT.

Tables ou vues de données produites (dans le schema eaupotable) :
- *_src_*_parsed (vue) : union générique des différentes tables importées de chaque collectivité, avec conversion automatique des champs
- *_src_*_translated (table) : matérialise en table, unifie _en_service et _abandonnees, corrige (0-padding des codes) et enrichit (des champs techniques : id unique global reproductible...)
- *_std_* (vue) : simple raccourci vers la précédente
- => *_std_*_labelled (vue) : l'enrichit des labels des codes

## TODO :

- enrich this README from apcom's
- clean dbt_project.yml
- canalisations_en_service :
  - clean from_csv (mapping), retest apcom, move it (& fdr_source_union, fal scripts/ ...) out of apcom project
  - schema test VOIRE sur _parsed de CHAQUE data_owner_id/FDR_SIREN, non regression test, profiles.yml accordingly
  - alternative dictionnaire des données
  - publish, without fieldPrefix (or only add it after "echange" format ?)
- reparations :
  - example / definition, _parsed/translated,
  - LATER rapprochement géographique
- OK canalisations_abandonnees : mutualiser avec canalisations_en_service ?
  - TODO Q avec ou sans "s" ?
  - TODO Q csv : wkt (car lambert) plutôt que geojson ? mais alors pas de ckan preview sauf si 2e fichier ?

scenario :
- publish :
  - OK dans org eaupotable et non apcom
  - OK pb nginx ! https://ckan.francedatareseau.fr/api/action/datastore_create', 504, '<html>\r\n<head><title>504 Gateway Time-out
    ckanapi.errors.ValidationError: {'name': ['Cette URL est déjà utilisée.'], '__type': 'Validation Error'}

  - TODO target test
  - LATER pb logs ckan contiennent toutes les données voire le font crasher (?)
  - LATER remplacer _csv.sql par pandas ou write_to_model ou par fal execute_sql() + pandas https://blog.fal.ai/populate-dbt-models-with-csv-data/ , more
- patch counts, ? avec :
  - one _parsed per data owner
  - stats / erreurs : link communes etc. pour stats générales count
  - ou / et reprendre meta en rajoutant data counts
- fin scenario

- env vars pour externaliser secret ou variables partagées entre dbt et fal / python (et docker)
- déplacer create view per data owner dans fal (flow) after OU / ET more --publish/deploy
- partager - fal scripts : fal-scripts-path: dbt_packages/dbt_engine OU dans .yml # https://docs.fal.ai/Docs/fal-cli/local-imports
- partager : fdr-engine(-dbt)/import/ckan ??

## Problèmes de données :

voir _canalisations_translated() (et _reparations_translated())