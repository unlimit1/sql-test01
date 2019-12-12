-- @ bigquery

-- SureChemble 구조
-- 테이블 2건 : match, map


-- match -- 4,227,188
select count(1) from `patents-public-data.ebi_surechembl.match`; -- 4,227,188
select * from `patents-public-data.ebi_surechembl.match` limit 100;
select count(1) from `patents-public-data.ebi_surechembl.match` where patent_id != publication_number; -- 1147896
select * from `patents-public-data.ebi_surechembl.match` where patent_id != publication_number limit 100; 

select count(1) cnt, count(distinct patent_id) patent_id,  count(distinct publication_number) publication_number 
  from `patents-public-data.ebi_surechembl.match`; -- 4227188	4227188	4227188
-- SQL Error [100034] [HY000]: [Simba][BigQueryJDBCDriver](100034) The job has timed out on the server. Try increasing the timeout value.


-- map -- 278,559,964
select count(1) from `patents-public-data.ebi_surechembl.map`;  -- 278,559,964
select * from `patents-public-data.ebi_surechembl.map` limit 100;
select count(1) cnt, count(distinct smiles) smiles,  count(distinct inchi_key) inchi_key, count(distinct patent_id) patent_id
  from `patents-public-data.ebi_surechembl.map` ; -- 278559964	17370957	17026275	4227188
-- SQL Error [100034] [HY000]: [Simba][BigQueryJDBCDriver](100034) The job has timed out on the server. Try increasing the timeout value.

select max(publication_date) from `patents-public-data.ebi_surechembl.map`; -- 2018-03-29

select * from `patents-public-data.ebi_surechembl.map` 
 where schembl_id = 'SCHEMBL18945'
 order by publication_date desc, patent_id desc, field desc;

select max(corpus_frequency) max_corpus, sum(cast(field_frequency as int64)) sum_field_frequency from `patents-public-data.ebi_surechembl.map` 
 where schembl_id = 'SCHEMBL18945';  -- 16888	20285

-- 결론.. 대략적으로 corpus_frequency 는 특정시점 field_frequency 의 합
select publication_date, patent_id, field, corpus_frequency, field_frequency 
      ,sum(cast(field_frequency as int64)) over (partition by schembl_id order by publication_date, patent_id, field) cum_sum_freq
  from `patents-public-data.ebi_surechembl.map` 
 where schembl_id = 'SCHEMBL18945'
 order by publication_date desc, patent_id desc, field desc;

select * from `patents-public-data.ebi_surechembl.map` 
 where patent_id = 'US-20180086841-A1'
 order by cast(corpus_frequency as int64) desc;

 

-- SureChEMBL readme 
/*
***************************************************************************
*
* Title:     SureChEMBL compound-patent map files 
* 
* SureChEMBL Release:     7
*
* Date of last update:     02/08/2016
*
***************************************************************************

The format of the files is GZipped, tab separated. Each row contains a specific compound
that has been extracted from a specific section of a specific patent document.
It contains chemistry extracted from the full text patent documents 
(including images and Complex Work Unit mol files, where available) from the WIPO, EPO and USPTO authorities.
In addition, it contains chemistry from the titles and abstracts of patent 
documents from JPO. The patent coverage in the 2 files is:

-SureChEMBL_map_20141231.txt.gz: backfile from 01-01-1960 to 31-12-2014 inclusive.
-SureChEMBL_map_20150401.txt.gz: incremental update from 01-01-2015 to 31-03-2015 inclusive (Q1 2015).
-SureChEMBL_map_20150701.txt.gz: incremental update from 01-04-2015 to 30-06-2015 inclusive (Q2 2015).
-SureChEMBL_map_20151001.txt.gz: incremental update from 01-07-2015 to 30-09-2015 inclusive (Q3 2015).
-SureChEMBL_map_20160101.txt.gz: incremental update from 01-10-2015 to 31-12-2015 inclusive (Q4 2015).
-SureChEMBL_map_20160401.txt.gz: incremental update from 01-01-2016 to 31-03-2016 inclusive (Q1 2016).
-SureChEMBL_map_20160701.txt.gz: incremental update from 01-04-2016 to 30-06-2016 inclusive (Q2 2016).


The columns are:

SCHEMBL_ID SMILES INCHI_KEY CORPUS_FREQUENCY PATENT_ID PUBLICATION_DATE FIELD FIELD_FREQUENCY

SCHEMBL_ID: Unique SureChEMBL compound identifier, e.g. SCHEMBL1001

SMILES: ChemAxon canonical kekule-based SMILES representation 

INCHI_KEY: ChemAxon-generated standard InChI key

CORPUS_FREQUENCY: Frequency of occurrence of a compound across *all* sections of *all* patent documents

PATENT_ID: Standardised representation of a patent number, e.g. WO-2014059185-A1

PUBLICATION_DATE: Patent publication date according to the respective patent authority.
The format is YYYY-MM-DD, e.g. 1979-07-15

FIELD: The field that the compound appears in. An integer value, one of:
1 - Description
2 - Claims
3 - Abstract
4 - Title
5 - Image (for patents after 2007)
6 - MOL Attachment (US patents after 2007)

FIELD_FREQUENCY: The number of times the given compound appears in the given field in the document.

The compounds and patents in this map file were preprocessed according to the following criteria:

*Compound filters:
    Must not be radical
    Must have fewer than 4 components and more than 6 carbons
    Must be organic
    Molecular weight must be between 100 and 6000

*Patent filters:
A document must have one of the following codes:
    A01, A23, A24, A61, A62B
    C05, C06, C07, C08, C09, C10, C11, C12, C13, C14
    G01N
The IPC, ECLA, IPCR, and CPC classification systems were checked for the above classification codes.

Key for top level areas:
   A=Human Necessities
   C=Chemistry
   G=Physics

Email us on surechembl-help<AT>ebi.ac.uk for questions and feedback.
 */