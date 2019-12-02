-- Big Query

with patents as (
SELECT publication_number, title, abstract, url, country, publication_description
  from `patents-public-data.google_patents_research.publications`
 where lower(title) like '%epilepsy%'
)
select p.*, sc.*
  from `patents-public-data.ebi_surechembl.map` sc
       inner join patents p on sc.patent_id = p.publication_number
 order by sc.publication_date desc, sc.patent_id
;

create table ohdsi_cdm_522.aaa ( col1 varchar );


CREATE TABLE ohdsi_cdm_522.care_site(
	care_site_id INT64 NOT NULL,
	place_of_service_concept_id INT64,
	location_id INT64
)


SELECT -- publication_number, title, abstract, url, country, publication_description
       *
  from `patents-public-data.google_patents_research.publications`
 where publication_number = 'US-7598279-B2'
 -- Azole compounds containing carbamoyl group and pharmaceutically useful salts thereof are described. The compounds are effective anticonvulsants which are used in the treatment of disorders of the central nervous system, especially as anxiety, depression, convulsion, epilepsy, migraine, bipolar disorder, drug abuse, smoking, ADHD, obesity, sleep disorder, neuropathic pain, stroke, cognitive impairment, neurodegeneration, stroke and muscle spasm.

 -- title -> abstract
with patents as (
SELECT publication_number, title, abstract, url, country, publication_description
  from `patents-public-data.google_patents_research.publications`
 where lower(abstract) like '%epilepsy%'
)
select count(1) -- 634372 -- p.*, sc.*
  from `patents-public-data.ebi_surechembl.map` sc
       inner join patents p on sc.patent_id = p.publication_number
 --order by sc.publication_date desc, sc.patent_id
;