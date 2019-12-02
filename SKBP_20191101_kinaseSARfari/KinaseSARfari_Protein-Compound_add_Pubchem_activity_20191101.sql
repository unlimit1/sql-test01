-- athena

select * from ana_chembl_ks.tsv_bioactivity act;
select * from ana_chembl_ks.tsv_compound;
select * from ana_chembl_ks.tsv_sequence;
select * from ana_chembl_ks.tsv_protein;


select count(1) from ana_chembl_ks.tsv_bioactivity; --503,041

with base as
(
select 
       'CHEMBL'||cast(act.compound_id as varchar) c_chembl_id, c.synonyms compound_synonyms, c.smiles
      ,act.name protein_name, s.t_seq
      ,p.* 
      ,act.assay_type, act.activity_type, act.relation, act.standard_value, act.standard_unit, act.activity_comment
      ,'CHEMBL'||cast(act.chembl_assay_id as varchar) assay_chembl_id
      ,chembl_activity_id
  from ana_chembl_ks.tsv_bioactivity act -- 503041
       inner join ana_chembl_ks.tsv_compound c on act.compound_id = c.compound_id -- 502694
       inner join ana_chembl_ks.tsv_sequence s on act.name = s.t_name  --197,775
       inner join ana_chembl_ks.tsv_protein p on act.name = p.name  --197,775
       -- left join chembl_ana.pq_activities ac on act.chembl_activity_id = ac.activity_id -- 조금 줄어들어서.. left join 으로...
)
-- select count(1) from base;
-- select name, count(1) cnt from base group by name order by cnt desc;
select * from base 
 order by c_chembl_id, protein_name, assay_chembl_id
;

select a1.standard_value, a2.standard_value, a1.*, a2.*, a3.chembl_id
  from chembl_ana.pq_activities a1
       inner join ana_chembl_ks.tsv_bioactivity a2 on a1.activity_id = a2.chembl_activity_id
       inner join chembl_ana.pq_assays a3 on a1.assay_id = a3.assay_id
 order by a1.activity_id    
;


with base as
(
select 
       'CHEMBL'||cast(act.compound_id as varchar) c_chembl_id, c.synonyms compound_synonyms, c.smiles
      ,act.name protein_name, s.t_seq
      ,p.* 
      ,act.assay_type, act.activity_type, act.relation, act.standard_value, act.standard_unit, act.activity_comment
      ,'CHEMBL'||cast(act.chembl_assay_id as varchar) assay_chembl_id
      ,chembl_activity_id
  from ana_chembl_ks.tsv_bioactivity act -- 503041
       inner join ana_chembl_ks.tsv_compound c on act.compound_id = c.compound_id -- 502694
       inner join ana_chembl_ks.tsv_sequence s on act.name = s.t_name  --197,775
       inner join ana_chembl_ks.tsv_protein p on act.name = p.name  --197,775
       -- left join chembl_ana.pq_activities ac on act.chembl_activity_id = ac.activity_id -- 조금 줄어들어서.. left join 으로...
)
, rslt as
(
select -- count(1)
       b.*, a.description assay_description
      ,regexp_extract(a.description, '(@|at) [0-9]+ (nM|uM)') cc
  from base b
       inner join chembl_ana.pq_assays a on b.assay_chembl_id = a.chembl_id
 -- where lower(activity_type) like 'inh'
)
-- select activity_type, standard_unit, cc, count(1) cnt from rslt a group by  activity_type, standard_unit, cc order by cnt desc
,rslt2 as
(
select 
       r.* 
      ,case when activity_type in ('IC50','Kd','Ki','Potency') and standard_unit = 'nM'  and standard_value <  10000                     then 'Active' 
            when activity_type in ('IC50','Kd','Ki','Potency') and standard_unit = 'nM'  and standard_value >= 10000                     then 'Inactive' 
            when activity_type in ('INH','Inhibitionb')        and standard_unit = '%'   and standard_value >     50 and cc = 'at 10 uM' then 'Active' 
            when activity_type in ('INH','Inhibitionb')        and standard_unit = '%'   and standard_value <=    50 and cc = 'at 10 uM' then 'Inactive'
            when activity_type in ('pIC50')                    and standard_unit = ''    and standard_value >      5                     then 'Active'
            when activity_type in ('pIC50')                    and standard_unit = ''    and standard_value <=     5                     then 'Inactive'
            when activity_type in ('INH','Inhibitionb')        and standard_unit = '%'   and standard_value >  9.090909 and cc = 'at 1 uM' then 'Active' 
            when activity_type in ('INH','Inhibitionb')        and standard_unit = '%'   and standard_value <= 9.090909 and cc = 'at 1 uM' then 'Inactive'
            else '' end cl  
  from rslt r
 where assay_type = 'B' -- 
)
, rslt3 as ( 
select r.* -- c_chembl_id, protein_name, activity_type t, standard_value v, standard_unit u, assay_chembl_id, cc, cl
      ,count(1) over (partition by c_chembl_id, protein_name) cnt
      ,sum(case when cl = 'Inactive' then 1 else 0 end) over (partition by c_chembl_id, protein_name) I_C 
      ,sum(case when cl = 'Active'   then 1 else 0 end) over (partition by c_chembl_id, protein_name) A_C
      ,row_number() over (partition by c_chembl_id, protein_name, cl order by assay_chembl_id desc) odr
  from rslt2 r
 where cl != '' -- 
)
-- SELECT count(1) from rslt3; -- 112234 -(at1uM추)-> 120065
select r.* -- c_chembl_id, protein_name, activity_type t, standard_value v, standard_unit u, assay_chembl_id, cc, cl, cnt, i_c, a_c, odr
      ,case when i_c > a_c and cl = 'Inactive' and r.odr = 1 then 'Y'
            when i_c < a_c and cl = 'Active'   and r.odr = 1 then 'Y'
            when i_c = a_c and cl = 'Active'   and r.odr = 1 then 'Maybe'
            else '' end uniq
      ,pc.pubchem_activity_outcome, pc.comment
  from rslt3 r
       left join pubchem_ana.pq_pubchem_chembl_join pc on r.chembl_activity_id = pc.activity_id
 order by c_chembl_id, protein_name, cl, assay_chembl_id
;

select 120065-112234; -- 7,831