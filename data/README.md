# Data acknowledgement and provenance

Data were sourced from the Australian Institute of Marine Science (AIMS).

- Dataset: [AIMS Long-Term Monitoring Program visual census fish data](https://apps.aims.gov.au/metadata/view/5be0b340-4ade-11dc-8f56-00008a07204e).
- Upstream file identified by the course: [nerp_ltmp_fish_zoning.csv](https://data.aims.gov.au/data-download/ltmp-exports/nerp_ltmp_fish_zoning.csv).
- Published file: aims_coral_trout_sites_2012.csv, copied unchanged from the supplied teaching extract.
- SHA-256: `c9601f5b2bc48f359c4b7c28c96c2ccae8cd7b6919c1773dea826f661000c075`.

According to the supplied course documentation, the extract selects the 2012 survey, sums recorded Plectropomus species within transects (zero when a surveyed transect has no such record), sums five equal-length transects per site, anonymises site identifiers and creates latitude bands: Northern north of 17.9 degrees S, Central between 17.9 and 19 degrees S, Southern south of 19 degrees S. These bands are not official AIMS management regions.

Fields: `site` (anonymous ID), `latitude_band` (Northern/Central/Southern), `zone` (Open/No-take), `coral_trout` (site-level count). There are 120 rows and no missing values. Counts refer to equal site-level effort, so the original model uses no unequal-effort offset.

The upstream file was not downloaded or regenerated during portfolio curation. The teaching transformations are documented from course material rather than independently reconstructed. Retain AIMS attribution and respect upstream/course terms. No new licence is assigned here.
