select count(1) from patents-public-data.ebi_chembl.activities union all
select count(1) from patents-public-data.ebi_chembl.activities_25;

select * from patents-public-data.ebi_chembl.drug_indication_26 where efo_term like '%fibrosis%';
-- > 245건의 compound 존재
select * from patents-public-data.ebi_chembl.assays_26 limit 100;
select * from patents-public-data.ebi_chembl.activities_26 limit 100;

-- select count(1) from 
( 
select mesh_heading, efo_id, efo_term, max_phase_for_ind, di.molregno
      ,md.chembl_id compound_chembl_id, cs.canonical_smiles smiles
      ,ass.assay_id, ass.description assay_desc, ass.assay_type, ass.assay_organism
      ,td.chembl_id target_chembl_id, td.pref_name target_pref_name, ass.mc_target_name, ass.mc_target_accession
      ,act.standard_relation, act.standard_type, act.standard_value, act.standard_units, act.activity_comment
  from patents-public-data.ebi_chembl.drug_indication_26 di
       inner join patents-public-data.ebi_chembl.activities_26 act on di.molregno = act.molregno
       		      inner join patents-public-data.ebi_chembl.molecule_dictionary_26 md on act.molregno = md.molregno 			
       		      inner join patents-public-data.ebi_chembl.compound_structures_26 cs on act.molregno = cs.molregno
       inner join patents-public-data.ebi_chembl.assays_26 ass on act.assay_id = ass.assay_id 
                  inner join patents-public-data.ebi_chembl.target_dictionary_26 td on ass.tid = td.tid
 where efo_term like '%fibrosis%'
 order by compound_chembl_id, assay_id
)
 ;
-- > 245건의 compound -> 181,661(181,552)건의 실험(activity) 

select * from patents-public-data.ebi_chembl.activities_26 limit 100;
select * from patents-public-data.ebi_chembl.compound_structures_26;
select * from patents-public-data.ebi_chembl.predicted_binding_domains; 
select count(1) from patents-public-data.ebi_chembl.predicted_binding_domains; --687,050
select * from patents-public-data.ebi_chembl.target_dictionary_26;
