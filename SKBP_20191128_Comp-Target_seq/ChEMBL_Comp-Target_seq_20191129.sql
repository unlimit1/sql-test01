-- @ athena

--with asy_parma as
--(
--select assay_id,
--       group_concat(concat( standard_type,':',format(standard_value,3),' ', standard_units
--		                     ,case when standard_text_value is null then '' else concat('<',standard_text_value,'>') end )
--		              separator ', ') asy_parameters 
--  from chembl_ana.assay_parameters
-- group by assay_id
--)
with base as --  Activity 정보 기본 Join ... 
(
select 
       a.assay_id a_id, act.activity_id act_id, t.tid t_id, a.doc_id, act.molregno
		,md.chembl_id c_chembl_id, cs.canonical_smiles
      ,a.chembl_id a_chembl_id, a.description, a.assay_type -- , ap.asy_parameters
      ,act.standard_type, act.standard_value, act.standard_units, act.activity_comment, act.data_validity_comment
      ,t.chembl_id t_chembl_id, t.target_type, t.pref_name target_name, t.organism
      ,pc.pubchem_activity_outcome pubchem_act_outcome, pc.comment 
  from chembl_ana.pq_assays a
       inner join chembl_ana.pq_activities act on a.assay_id = act.assay_id
       inner join chembl_ana.pq_target_dictionary t on a.tid = t.tid
       inner join chembl_ana.pq_molecule_dictionary md on act.molregno = md.molregno
       inner join chembl_ana.pq_compound_structures cs on act.molregno = cs.molregno
       -- left  join chembl_ana.asy_parma ap on act.assay_id = ap.assay_id
       left  join pubchem_ana.pq_pubchem_chembl_join pc on act.activity_id = pc.activity_id
)
select count(1) from base; -- 15367664

select * from chembl_ana.pq_component_sequences pcs;
-- component_id	component_type	accession	sequence	sequence_md5sum	description	tax_id	organism	db_source	db_version

select * from chembl_ana.pq_target_components ptc;
-- tid	component_id	targcomp_id	homologue

select target_type, count(1) cnt from chembl_ana.pq_target_dictionary group by target_type order by cnt desc;
/*SINGLE PROTEIN	7350
ORGANISM	2137
CELL-LINE	1608
PROTEIN COMPLEX	424
PROTEIN FAMILY	335
TISSUE	243
SELECTIVITY GROUP	100
PROTEIN-PROTEIN INTERACTION	80
PROTEIN COMPLEX GROUP	53
NUCLEIC-ACID	33
SMALL MOLECULE	25
UNKNOWN	19
... */

-- target 에서 sequence 로 연결... 
select t.tid, t.target_type, t.pref_name, t.organism, t.target_chembl_id, t.component_id, cs.accession, cs.sequence
  from (select -- count(1) -- 7350 --tc join-> 7352... 거의 1:1 이지만,,, 완전 1:1로 가공필...
		       td.tid, td.target_type, td.pref_name, td.organism, td.chembl_id target_chembl_id, tc.component_id 
		      , row_number() over (partition by td.tid order by tc.component_id) odr
		  from chembl_ana.pq_target_dictionary td
		       inner join chembl_ana.pq_target_components tc on td.tid = tc.tid
		 where target_type = 'SINGLE PROTEIN') t
		inner join chembl_ana.pq_component_sequences cs on t.component_id = cs.component_id
 where odr = 1 -- count : 7350 OK,  pq_component_sequences join 후에도 7350건 OK 
;

select * from chembl_ana.pq_component_sequences pcs;

-- Activity 기본과 target-sequence Join
with ts as (
select t.tid, t.target_type, t.pref_name, t.organism, t.target_chembl_id, t.component_id, cs.accession, cs.sequence
  from (select -- count(1) -- 7350 --tc join-> 7352... 거의 1:1 이지만,,, 완전 1:1로 가공필...
		       td.tid, td.target_type, td.pref_name, td.organism, td.chembl_id target_chembl_id, tc.component_id 
		      , row_number() over (partition by td.tid order by tc.component_id) odr
		  from chembl_ana.pq_target_dictionary td
		       inner join chembl_ana.pq_target_components tc on td.tid = tc.tid
		 where target_type = 'SINGLE PROTEIN') t
		inner join chembl_ana.pq_component_sequences cs on t.component_id = cs.component_id
 where odr = 1 -- count : 7350 OK,  pq_component_sequences join 후에도 7350건 OK 
), base as --  Activity 정보 기본 Join ... 
(
select 
       a.assay_id a_id, act.activity_id act_id, t.tid t_id, a.doc_id, act.molregno
		,md.chembl_id c_chembl_id, cs.canonical_smiles
      ,a.chembl_id a_chembl_id, a.description, a.assay_type -- , ap.asy_parameters
      ,act.standard_type, act.standard_value, act.standard_units, act.activity_comment, act.data_validity_comment
      ,t.chembl_id t_chembl_id, t.target_type, t.pref_name target_name, t.organism
      ,pc.pubchem_activity_outcome pubchem_act_outcome, pc.comment 
  from chembl_ana.pq_assays a
       inner join chembl_ana.pq_activities act on a.assay_id = act.assay_id
       inner join chembl_ana.pq_target_dictionary t on a.tid = t.tid
       inner join chembl_ana.pq_molecule_dictionary md on act.molregno = md.molregno
       inner join chembl_ana.pq_compound_structures cs on act.molregno = cs.molregno
       -- left  join chembl_ana.asy_parma ap on act.assay_id = ap.assay_id
       left  join pubchem_ana.pq_pubchem_chembl_join pc on act.activity_id = pc.activity_id
)
select -- count(1) -- 6,236,539
       b.c_chembl_id, b.canonical_smiles
      ,t.target_chembl_id t_chembl_id, t.pref_name target_pref_name, t.organism, t.accession, t.sequence
      ,a_chembl_id, description assay_desc, assay_type
      ,standard_type, standard_value, standard_units, activity_comment
  from base b inner join ts t on b.t_id = t.tid
 order by c_chembl_id, t_chembl_id, act_id
limit 10000
;
 
 
