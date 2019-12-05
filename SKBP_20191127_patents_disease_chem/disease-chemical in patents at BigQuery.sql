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


-- 구글 patens 테이블 탐색
-- 다중 중첩 구조로 되어 있어 어렵군... 
SELECT * from `patents-public-data.google_patents_research.publications` where publication_number like 'US%' LIMIT 100;
SELECT * from `patents-public-data.google_patents_research.publications` where publication_number like 'JP%' LIMIT 100;
{"v":
	[ {"v":
	    {"f":
	    	[ {"v":"G01N2800/56"}
	    	 ,{"v":"false"}
	    	 ,{"v":"false"}
	    	 ,{"v":[{"v":"G01N2800/56"},{"v":"G01N2800/00"},{"v":"G01N"},{"v":"G01"},{"v":"G"}]}
	        ]
	    }
	  }
	 ,{"v":{"f":[{"v":"G01N2800/325"},{"v":"false"},{"v":"false"},{"v":[{"v":"G01N2800/325"},{"v":"G01N2800/32"},{"v":"G01N2800/00"},{"v":"G01N"},{"v":"G01"},{"v":"G"}]}]}}
	 ,{"v":{"f":[{"v":"G01N33/6893"},{"v":"true"},{"v":"false"},{"v":[{"v":"G01N33/6893"},{"v":"G01N33/68"},{"v":"G01N33/50"},{"v":"G01N33/48"},{"v":"G01N33/00"},{"v":"G01N"},{"v":"G01"},{"v":"G"}]}]}}
	 ,{"v":{"f":[{"v":"G01N2333/4703"},{"v":"false"},{"v":"false"},{"v":[{"v":"G01N2333/4703"},{"v":"G01N2333/4701"},{"v":"G01N2333/47"},{"v":"G01N2333/46"},{"v":"G01N2333/435"},{"v":"G01N2333/00"},{"v":"G01N"},{"v":"G01"},{"v":"G"}]}]}}
	 ,{"v":{"f":[{"v":"C12Q1/6883"},{"v":"true"},{"v":"true"},{"v":[{"v":"C12Q1/6883"},{"v":"C12Q1/6876"},{"v":"C12Q1/68"},{"v":"C12Q1/00"},{"v":"C12Q"},{"v":"C12"},{"v":"C"}]}]}}
	 ,{"v":{"f":[{"v":"C07K14/4747"},{"v":"true"},{"v":"false"},{"v":[{"v":"C07K14/4747"},{"v":"C07K14/4701"},{"v":"C07K14/47"},{"v":"C07K14/46"},{"v":"C07K14/435"},{"v":"C07K14/00"},{"v":"C07K"},{"v":"C07"},{"v":"C"}]}]}},{"v":{"f":[{"v":"C07K14/4716"},{"v":"true"},{"v":"false"},{"v":[{"v":"C07K14/4716"},{"v":"C07K14/4701"},{"v":"C07K14/47"},{"v":"C07K14/46"},{"v":"C07K14/435"},{"v":"C07K14/00"},{"v":"C07K"},{"v":"C07"},{"v":"C"}]}]}}
	]
}
{"v":[{"v":"bin1"},{"v":"method"},{"v":"heart"},{"v":"patient"},{"v":"idf"},{"v":"cardiac"},{"v":"patients"},{"v":"expression levels"},{"v":"expression"},{"v":"risk"}]}
{"v":[{"v":{"f":[{"v":"EP-3255432-B1"},{"v":""},{"v":""},{"v":""},{"v":""},{"v":"0"}]}},{"v":{"f":[{"v":"EP-2021799-B1"},{"v":""},{"v":""},{"v":""},{"v":""},{"v":"0"}]}}]}

SELECT count(1), count(distinct publication_number) -- 119,041,383	119,041,358 (9초)
from `patents-public-data.google_patents_research.publications`; 

-- 중첩 컬럼 뺀 컬럼들
SELECT publication_number, title, title_translated, abstract, abstract_translated, url, country, publication_description
  FROM `patents-public-data.google_patents_research.publications` limit 100;

-- 국가별 통계 (20191205)
select substr(publication_number,1,3), country, count(1) cnt
  from `patents-public-data.google_patents_research.publications`
 group by substr(publication_number,1,3), country
 order by cnt desc;
/* --105rows 4.6sec
JP-	Japan	24883058
CN-	China	22734436
US-	United States	16802823
DE-	Germany	7705275
EP-	European Patent Office	6633369
KR-	South Korea	5467347
WO-	WIPO (PCT)	4296882
GB-	United Kingdom	3756046
...
AM-	ARMENIA	5
TT-	Trinidad and Tobago	3
EM-	EUIPO	1
MO-	Macau	1*/

