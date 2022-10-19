# Projet dbt fdr-eaupotable

Projet de traitement du cas d'usage FDR Bornes de recharge. En DBT.

See Install, build & run and FAQ / Gotchas in fdr-france-data-reseau.

Regular (incremental) run :
```bash
dbt run --target prod/test --select eaupot.src tag:incremental
```

## Provides

Tables ou vues de données produites (dans le schema eaupotable) :
- *_src_*_parsed : union générique des différentes tables importées de chaque collectivité, avec conversion automatique des champs
- *_src_*_translated : unifie _en_service et _abandonnees, corrige (0-padding des codes) et enrichit
(des labels des codes, des champs techniques : id unique global reproductible...)
- => *_std_*(_unified), (incrémental donc table) : matérialise en incrémental (table) la précédente, avec index. NB. labelled est un raccourci vers ceux-ci pour
rétrocompatibilité.
- *_std_*_linked (incrémental donc table) : résultat du rapprochement géographique avec les communes ou pour les
réparations avec les canalisations à moins de 5m
- => *_std_*_enriched : les enrichit
  - des communes (avec leur population),
  - et pour les reparations de leurs canalisations
connnues (eaupotrep_supportIncident) ou sinon de la plus proche à moins de 5m (18s pour 50k reparations avec
350k canalisations)


## Problèmes de données :

Duplicates Grand Annecy

  
## TODO :

- canalisations_en_service :
  - schema test VOIRE sur _parsed de CHAQUE data_owner_id/FDR_SIREN voire avec vue pour chacun, voir déjà
eaupot_src_canalisations_en_service_parsed_errors
  - non regression test
  - publish, without fieldPrefix (or only add it after "echange" format ?)


## OBSOLETE scenario :

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

- déplacer create view per data owner dans fal (flow) after OU / ET more --publish/deploy
- partager - fal scripts : fal-scripts-path: dbt_packages/dbt_engine OU dans .yml # https://docs.fal.ai/Docs/fal-cli/local-imports
- partager : fdr-engine(-dbt)/import/ckan ??