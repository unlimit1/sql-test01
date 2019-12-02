select * from pubchem_ana.pubchem_data_aid_target;

with base as
(
select aid, count(geneid) cnt 
  from pubchem_ana.pubchem_data_aid_target
 group by aid  
)
select cnt, count(1) c_cnt from base group by cnt order by cnt;
/*0	13893
1	232712 --> 23만건의 aid 가 1개의 target 을 가지고 실험됨... 
2	12815
3	5293
4	2334
5	1216
... 천건 이상의 target 이 연결된 aid : 29건
*/

create table pubchem_ana.pq_pubchem_cid_synonym  -- Updated Rows	124802112
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_pubchem_cid_synonym',parquet_compression = 'SNAPPY') 
as select * from pubchem_ana.txt_pubchem_cid_synonym;

select * from pubchem_ana.pq_pubchem_cid_synonym order by 1,2;
select count(1) from pubchem_ana.pq_pubchem_cid_synonym;  -- 124,802,112

create table hgnc_ana.pq_hgnc_gene -- Updated Rows	43249
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/hgnc/parquet/pq_hgnc',parquet_compression = 'SNAPPY') 
as select * from hgnc_ana.txt_hgnc_gene;

select * from hgnc_ana.pq_hgnc_gene;
select count(1) from hgnc_ana.pq_hgnc_gene; -- 43249

-- ------------------------------------------------
-- 1단계 : gene 이 1개만 연결된 aid 에 대하여 먼저 처리....
--   - 1.공통 7개 컬럼 추출 sql 작성  -- resource exhausted.... 
--  - 2.gene 1개 aid sql 작성... 
--  - 3.join ...

select * from pubchem_ana.pubchem_data order by aid, tag_no, field_no limit 100;

select field_name, field_no, count(1) cnt from pubchem_ana.pubchem_data
 where field_no <= 7 
 group by field_name, field_no
 order by field_no, cnt desc 
; -- 깔끔하게 모두 241113866 OK~

create table pubchem_ana.pq_gene_compound_temp1 -- pubchem_ana.pq_gene_compound_temp1
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_gene_compound_temp1',parquet_compression = 'SNAPPY') as
with base as
(
select d.aid,tag_no
    --,max(case when field_name = 'PUBCHEM_RESULT_TAG' then data_value else '' end) PUBCHEM_RESULT_TAG
    --,max(case when field_name = 'PUBCHEM_SID' then data_value else '' end) PUBCHEM_SID
      ,max(case when field_name = 'PUBCHEM_CID' then data_value else '' end) PUBCHEM_CID
      ,max(case when field_name = 'PUBCHEM_ACTIVITY_OUTCOME' then data_value else '' end) PUBCHEM_ACTIVITY_OUTCOME
      ,max(case when field_name = 'PUBCHEM_ACTIVITY_SCORE' then data_value else '' end) PUBCHEM_ACTIVITY_SCORE
      ,max(case when field_name = 'PUBCHEM_ACTIVITY_URL' then data_value else '' end) PUBCHEM_ACTIVITY_URL
      ,max(case when field_name = 'PUBCHEM_ASSAYDATA_COMMENT' then data_value else '' end) PUBCHEM_ASSAYDATA_COMMENT
  from pubchem_ana.pubchem_data d 
       inner join (select aid, count(geneid) gene_cnt from pubchem_ana.pubchem_data_aid_target group by aid) at1 
		           on d.aid = at1.aid and at1.gene_cnt = 1
 group by d.aid, tag_no
)
select * from base;

create table pubchem_ana.pq_gene_compound_temp2
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_gene_compound_temp2',parquet_compression = 'SNAPPY') as
with cid_chembl as
(
select cast(cid as varchar) cid, array_join(array_agg(synonym), ',') c_chembl_id
  from pubchem_ana.pq_pubchem_cid_synonym 
 where synonym like 'CHEMBL%' 
 group by cid
)
,rslt as (
select  -- count(1) 
       t.geneid, hg.symbol, pubchem_cid, c.openeye_can_smiles
      ,b.aid, b.tag_no
      ,PUBCHEM_ACTIVITY_OUTCOME, PUBCHEM_ACTIVITY_SCORE
      ,c.iupac_inchikey, dd.source_name, dd.source_obj_id -- cc.c_chembl_id
  from pubchem_ana.pq_gene_compound_temp1 b
       inner join pubchem_ana.pubchem_data_aid_target t on b.aid = t.aid
       inner join hgnc_ana.pq_hgnc_gene hg on t.geneid = hg.entrez_id  -- hgnc
       inner join pubchem_ana.pubchem_compound c on b.pubchem_cid = cast(c.cid as varchar) -- 117,385,690
       inner join pubchem_ana.pubchem_description dd on b.aid = dd.aid -- 117,385,690
       --left join  pubchem_ana.pq_pubchem_cid_synonym csy on b.pubchem_cid = cast(csy.cid as varchar) and csy.synonym like 'CHEMBL%' --117,651,279
       --left join cid_chembl cc on b.pubchem_cid = cc.cid --117,385,690
 order by pubchem_cid, lower(hg.symbol), dd.source_obj_id, b.tag_no
)
-- select count(1) from rslt where symbol is null -- 0 rows OK
-- select count(1), count(c_chembl_id), count(distinct c_chembl_id) from rslt;  -- 117,385,690	112,803,245	1,000,097  ...16m 39s
select * from rslt;

select geneid, symbol, pubchem_cid, openeye_can_smiles,iupac_inchikey, c_chembl_id
      ,count(1) activity_cnt
      ,sum(case when PUBCHEM_ACTIVITY_OUTCOME = 'Active'   then 1 else 0 end ) active_cnt
      ,sum(case when PUBCHEM_ACTIVITY_OUTCOME = 'Inactive' then 1 else 0 end ) inactive_cnt
  from rslt
 group by geneid, symbol, pubchem_cid, openeye_can_smiles,iupac_inchikey, c_chembl_id
 order by c_chembl_id, lower(symbol)
;

select cast ( null as bigint);

select cast(cid as varchar) cid, array_join(array_agg(synonym), ',') 
  from pubchem_ana.pq_pubchem_cid_synonym 
 where synonym like 'CHEMBL%'
 group by cid
;

select dat.aid, geneid
  from pubchem_ana.pubchem_data_aid_target dat
       inner join (select aid, count(geneid) gene_cnt from pubchem_ana.pubchem_data_aid_target group by aid) at1 
                  on dat.aid = at1.aid and at1.gene_cnt = 1;

  