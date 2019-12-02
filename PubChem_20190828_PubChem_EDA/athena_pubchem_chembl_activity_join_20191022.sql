select * from pubchem_ana.pq_gene_compound_temp1;
select count(1) from pubchem_ana.pq_gene_compound_temp1 limit 100;

create table pubchem_ana.pq_pubchem_data_chembl_activity
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_pubchem_data_chembl_activity',parquet_compression = 'SNAPPY')
as
select d.aid,tag_no
      ,max(case when field_name = 'PUBCHEM_RESULT_TAG' then data_value else '' end) PUBCHEM_RESULT_TAG
      ,max(case when field_name = 'PUBCHEM_SID' then data_value else '' end) PUBCHEM_SID
      ,max(case when field_name = 'PUBCHEM_CID' then data_value else '' end) PUBCHEM_CID
      ,max(case when field_name = 'PUBCHEM_ACTIVITY_OUTCOME' then data_value else '' end) PUBCHEM_ACTIVITY_OUTCOME
      ,max(case when field_name = 'PUBCHEM_ACTIVITY_SCORE' then data_value else '' end) PUBCHEM_ACTIVITY_SCORE
      ,max(case when field_name = 'PUBCHEM_ACTIVITY_URL' then data_value else '' end) PUBCHEM_ACTIVITY_URL
      ,max(case when field_name = 'PUBCHEM_ASSAYDATA_COMMENT' then data_value else '' end) PUBCHEM_ASSAYDATA_COMMENT
  from pubchem_ana.pubchem_data d 
       inner join pubchem_ana.pubchem_description de on d.aid = de.aid and de.source_name = 'ChEMBL'
 group by d.aid, tag_no
;

select * from pubchem_ana.pq_pubchem_data_chembl_activity;
select count(1) tot, count(distinct aid) c_aid from pubchem_ana.pq_pubchem_data_chembl_activity;  -- 6757714	1057483
select count(1) tot, count(distinct de.aid) c_aid, count(distinct de.aid*10000000+tag_no) d_aid_tag_cnt
  from pubchem_ana.pubchem_description de   -- 6757714	1057483
       inner join pubchem_ana.pq_pubchem_data_chembl_activity a on de.aid = a.aid; -- 6757714	1057483	6757714

select count(1) tot, count(distinct de.aid) c_aid, count(distinct de.aid*10000000+tag_no) d_aid_tag_cnt
  from pubchem_ana.pubchem_description de   -- 6757714	1057483
       inner join pubchem_ana.pq_pubchem_data_chembl_activity a on de.aid = a.aid           -- 6757714	1057483	6757714
       inner join pubchem_ana.pubchem_compound c on a.pubchem_cid = cast(c.cid as varchar); -- 6715823	1053254	6715823
       
       
create table pubchem_ana.pq_pubchem_chembl_join2
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_pubchem_chembl_join2',parquet_compression = 'SNAPPY')       
as
with chembl_act as (
select act.activity_id, act.assay_id, act.doc_id,  act.standard_type, act.standard_relation, act.standard_value, act.standard_units
      ,act.activity_comment, act.data_validity_comment, act.standard_upper_value, act.standard_text_value
      ,cs.molregno, cs.standard_inchi, cs.standard_inchi_key, cs.canonical_smiles
  from chembl_ana.pq_activities act
       inner join chembl_ana.pq_compound_structures2 cs on act.molregno = cs.molregno
)
, rslt as (
select -- de.*, a.*, c.*, act.*
       de.aid,tag_no,assay_name,source_name,source_obj_id,source_date,description,comment,protocol,fields
      ,pubchem_sid,pubchem_cid,pubchem_activity_outcome,pubchem_activity_score,pubchem_activity_url,pubchem_assaydata_comment
      ,iupac_name,iupac_inchi,iupac_inchikey iupac_inchi_key, openeye_can_smiles, openeye_iso_smiles
      ,activity_id,assay_id,doc_id,standard_type,standard_relation,standard_value,standard_units,activity_comment,data_validity_comment,standard_upper_value,standard_text_value
      ,molregno,standard_inchi,standard_inchi_key,canonical_smiles
      ,row_number() over (partition by de.aid, tag_no order by tag_no) odr
  from pubchem_ana.pubchem_description de 
       inner join pubchem_ana.pq_pubchem_data_chembl_activity a on de.aid = a.aid
       inner join pubchem_ana.pubchem_compound c on a.pubchem_cid = cast(c.cid as varchar)
       left  join chembl_act act on de.source_obj_id = cast(act.assay_id as varchar) and c.iupac_inchikey = act.standard_inchi_key
 order by de.aid, a.tag_no
)
-- select min(aid), max(aid) from rslt;
select * from rslt where odr = 1 and aid > 700000;
-- select * from rslt r inner join (select distinct aid,tag_no from rslt where odr > 1 and aid < 10000) a on r.aid = a.aid and r.tag_no = a.tag_no order by r.aid, r.tag_no, odr ;
-- select count(1) tot_cnt, count(distinct aid*10000000+tag_no) d_aid_tag_cnt, count(distinct cast(aid as varchar)||pubchem_cid) d_aid_cid_cnt, count(activity_id) chembl_act_cnt, count(distinct activity_id) chembl_d_act_cnt from rslt where odr = 1
;

create table pubchem_ana.pq_pubchem_chembl_join
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_pubchem_chembl_join',parquet_compression = 'SNAPPY')       
as
select * from pubchem_ana.pq_pubchem_chembl_join1
union all 
select * from pubchem_ana.pq_pubchem_chembl_join2
;

select * from pubchem_ana.pq_pubchem_chembl_join;

create table pubchem_ana.pq_pubchem_chembl_activity
with ( format = 'parquet', external_location = 's3://use-skcc-dat-p-hcdp/ana/pubchem/parquet/pq_pubchem_chembl_activity',parquet_compression = 'SNAPPY')       
as
select * from pubchem_ana.pq_pubchem_chembl_join order by 1,2; 
-- SQL Error [100071] [HY000]: [Simba][AthenaJDBC](100071) An error has been thrown from the AWS Athena client. Query exhausted resources at this scale factor.

select count(1), count(activity_id) from pubchem_ana.pq_pubchem_chembl_join; -- 6715823	6473515
select pubchem_activity_outcome, count(1) cnt from pubchem_ana.pq_pubchem_chembl_join group by pubchem_activity_outcome order by cnt desc;
--Unspecified	4197458
--Active	2109718
--Inactive	257418
--Inconclusive	151229

SELECT * FROM pubchem_ana.pq_pubchem_chembl_join;
SELECT count(1) FROM pubchem_ana.pq_pubchem_chembl_join;

select 
'aid' aid, 
'tag_no' tag_no, 
max(length(assay_name)) assay_name, 
max(length(source_name)) source_name, 
max(length(source_obj_id)) source_obj_id, 
'source_date' source_date, 
max(length(description)) description, 
max(length(comment)) comment, 
max(length(protocol)) protocol, 
max(length(fields)) fields, 
max(length(pubchem_sid)) pubchem_sid, 
max(length(pubchem_cid)) pubchem_cid, 
max(length(pubchem_activity_outcome)) pubchem_activity_outcome, 
max(length(pubchem_activity_score)) pubchem_activity_score, 
max(length(pubchem_activity_url)) pubchem_activity_url, 
max(length(pubchem_assaydata_comment)) pubchem_assaydata_comment, 
max(length(iupac_name)) iupac_name, 
max(length(iupac_inchi)) iupac_inchi, 
max(length(iupac_inchi_key)) iupac_inchi_key, 
max(length(openeye_can_smiles)) openeye_can_smiles, 
max(length(openeye_iso_smiles)) openeye_iso_smiles, 
'activity_id' activity_id, 
'assay_id' assay_id, 
'doc_id' doc_id, 
max(length(standard_type)) standard_type, 
max(length(standard_relation)) standard_relation, 
'standard_value' standard_value, 
max(length(standard_units)) standard_units, 
max(length(activity_comment)) activity_comment, 
max(length(data_validity_comment)) data_validity_comment, 
max(length(standard_upper_value)) standard_upper_value, 
max(length(standard_text_value)) standard_text_value, 
'molregno' molregno, 
max(length(standard_inchi)) standard_inchi, 
max(length(standard_inchi_key)) standard_inchi_key, 
max(length(canonical_smiles)) canonical_smiles, 
'odr' odr
from pubchem_ana.pq_pubchem_chembl_join;

select distinct activity_id, count(1) over (partition by activity_id) cnt from pubchem_ana.pq_pubchem_chembl_join order by cnt desc;

select * from pubchem_ana.pq_pubchem_chembl_join where activity_id in (16902165,2012791,17678306) order by activity_id, aid, tag_no;

select * from chembl_ana.pq_activities where assay_id = 1528822;
select * from pubchem_ana.pq_pubchem_chembl_join where source_obj_id = '1528822';

select * from 
(select aid, tag_no, assay_id, activity_id, row_number() over (partition by activity_id order by aid, tag_no) odr from pubchem_ana.pq_pubchem_chembl_join) a
where activity_id > 0 and odr > 1;
